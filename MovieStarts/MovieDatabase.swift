//
//  Database.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 14.02.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation
import CloudKit
import UIKit


class MovieDatabase : DatabaseParent {
	
	var moviesPlistPath: String?
	var moviesPlistFile: String?
	var loadedMovieRecordArray: [MovieRecord]?
	var viewForError: UIView?
	
	var completionHandler: ((movies: [MovieRecord]?) -> ())?
	var errorHandler: ((errorMessage: String) -> ())?
	var showIndicator: (() -> ())?
	var stopIndicator: (() -> ())?
	var updateIndicator: ((counter: Int) -> ())?
	var finishHandler: (() -> ())?
	
	var addNewMovieHandler: ((movie: MovieRecord) -> ())?
	var updateMovieHandler: ((movie: MovieRecord) -> ())?
	var removeMovieHandler: ((movie: MovieRecord) -> ())?
	var updateThumbnailHandler: ((tmdbId: Int) -> ())?
	
	var allCKRecords: [CKRecord] = []
	var updatedCKRecords: [CKRecord] = []

	let queryKeys = [Constants.dbIdTmdbId, Constants.dbIdOrigTitle, Constants.dbIdPopularity, Constants.dbIdVoteAverage, Constants.dbIdVoteCount, Constants.dbIdProductionCountries, Constants.dbIdImdbId, Constants.dbIdDirectors, Constants.dbIdActors, Constants.dbIdHidden, Constants.dbIdGenreIds, Constants.dbIdCharacters, Constants.dbIdId, Constants.dbIdTrailerIdsEN, Constants.dbIdPosterUrlEN, Constants.dbIdSynopsisEN, Constants.dbIdRuntimeEN, Constants.dbIdRatingImdb, Constants.dbIdRatingTomato, Constants.dbIdTomatoImage, Constants.dbIdTomatoURL, Constants.dbIdRatingMetacritic]

	init(recordType: String, viewForError: UIView?) {
		self.viewForError = viewForError
		super.init(recordType: recordType)
		
		let fileUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(Constants.movieStartsGroup)

		if let fileUrl = fileUrl, fileUrlPath = fileUrl.path {
			moviesPlistPath = fileUrlPath
		}
        else {
            NSLog("Error getting url for app-group.")
			var errorWindow: MessageWindow?

			if let viewForError = viewForError {
				dispatch_async(dispatch_get_main_queue()) {
					errorWindow = MessageWindow(parent: viewForError, darkenBackground: true, titleStringId: "InternalError", textStringId: "NoAppGroup", buttonStringIds: ["Close"], handler: { (buttonIndex) -> () in
						errorWindow?.close()
					})
				}
			}
        }
		
		if let saveMoviesPlistPath = self.moviesPlistPath {
			if saveMoviesPlistPath.hasSuffix("/") {
				moviesPlistFile = saveMoviesPlistPath + recordType + ".plist"
			}
			else {
				moviesPlistFile = saveMoviesPlistPath + "/" + recordType + ".plist"
			}
		}
	}
	
	
	/**
		Checks if there is a database file on the device.
		- returns: TRUE if there is a file, FALSE otherwise
	*/
	func isDatabaseOnDevice() -> Bool {
		if let moviesPlistFile = moviesPlistFile {
			if (NSFileManager.defaultManager().fileExistsAtPath(moviesPlistFile)) {
				return true
			}
		}
		
		return false
	}
	

	// MARK: - Functions for reading all movies
	
	
	/**
		If a local database exists, this method reads the movies from the local database. Otherwise, it gets all movies from the cloud.

		- parameter completionHandler:	The handler which is called after all movies are read
		- parameter errorHandler:		The handler which is called if an error occurs
		- parameter showIndicator:		Callback which is called to show a progress indicator
		- parameter stopIndicator:		Callback which is called to stop the progress indicator
		- parameter updateIndicator:	Callback which is called to update the progress indicator with a new progress
	*/
	func getAllMovies(	completionHandler: (movies: [MovieRecord]?) -> (),
						errorHandler: (errorMessage: String) -> (),
						showIndicator: (() -> ())?,
						stopIndicator: (() -> ())?,
						updateIndicator: ((counter: Int) -> ())?,
						finishHandler: (() -> ())?)
	{
		self.completionHandler 	= completionHandler
		self.errorHandler 		= errorHandler
		self.showIndicator		= showIndicator
		self.stopIndicator		= stopIndicator
		self.updateIndicator	= updateIndicator
		self.finishHandler		= finishHandler
		
		let prefsCountryString = (NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
		guard let country = MovieCountry(rawValue: prefsCountryString) else { return }

		if let moviesPlistFile = moviesPlistFile {
			// try to load movies from device
			if let loadedDictArray = NSArray(contentsOfFile: moviesPlistFile) as? [NSDictionary] {
				// successfully loaded movies from device
				loadedMovieRecordArray = MovieDatabaseHelper.dictArrayToMovieRecordArray(loadedDictArray, country: country)
				
				if loadedMovieRecordArray != nil {
					cleanUpExistingMovies(&(loadedMovieRecordArray!))
				}
				
				completionHandler(movies: loadedMovieRecordArray)
			}
			else {
				// movies are not on the device: get them from the cloud
				
				UIApplication.sharedApplication().networkActivityIndicatorVisible = true
				
				dispatch_async(dispatch_get_main_queue()) {
					showIndicator?()
				}

				// get all movies which started a month ago or later
				let compareDate = NSDate().dateByAddingTimeInterval(-30 * 24 * 60 * 60)
				let predicate = NSPredicate(format: "(%K > %@) AND (hidden == 0)", argumentArray: [country.databaseKeyRelease, compareDate])
				let query = CKQuery(recordType: self.recordType, predicate: predicate)
				
				let queryOperation = CKQueryOperation(query: query)
				let operationQueue = NSOperationQueue()
				
				executeQueryOperationAllMovies(queryOperation, onOperationQueue: operationQueue)
			}
		}
		else {
			NSLog("No group folder found")
			errorHandler(errorMessage: "*** No group folder found")
		}
	}
	
	
	/**
		Sends a new CloudKit query to get new records.
	
		- parameter queryOperation:		The query operation containing the predicates
		- parameter onOperationQueue:	The queue for the query operation
	*/
	func executeQueryOperationAllMovies(queryOperation: CKQueryOperation, onOperationQueue operationQueue: NSOperationQueue) {
		let prefsCountryString = (NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue

		if let country = MovieCountry(rawValue: prefsCountryString) {
			queryOperation.desiredKeys = self.queryKeys + country.languageQueryKeys + country.countryQueryKeys
		}
		else {
			NSLog("executeQueryOperationAllMovies: Error getting country for country-code \(prefsCountryString)")
		}
		
		queryOperation.database = cloudKitDatabase
		queryOperation.qualityOfService = NSQualityOfService.UserInitiated

		queryOperation.recordFetchedBlock = { [unowned self] (record : CKRecord) -> Void in
			self.allCKRecords.append(record)
			self.updateIndicator?(counter: self.allCKRecords.count)
		}

		queryOperation.queryCompletionBlock = { [unowned self] (cursor: CKQueryCursor?, error: NSError?) -> Void in
			if let cursor = cursor {
				// some objects are here, ask for more
				let queryCursorOperation = CKQueryOperation(cursor: cursor)
				self.executeQueryOperationAllMovies(queryCursorOperation, onOperationQueue: operationQueue)
			}
			else {
				// download finished (with error or not)
				self.queryOperationFinishedAllMovies(error)
			}
		}
		
		// Add the operation to the operation queue to execute it
		operationQueue.addOperation(queryOperation)
	}
	
	
	/**
		This function is called when all records have been fetched from the CloudKit database.
		MovieRecord objects are generated and saved.
	
		- parameter error:	The error object
	*/
	func queryOperationFinishedAllMovies(error: NSError?) {
		if let error = error {
			if let saveStopIndicator = self.stopIndicator {
				dispatch_async(dispatch_get_main_queue()) {
					saveStopIndicator()
				}
			}
			
			self.errorHandler?(errorMessage: "Error querying records: Code=\(error.code) Domain=\(error.domain) Error: (\(error.localizedDescription))")
			var errorWindow: MessageWindow?
			
			if let viewForError = viewForError {
				dispatch_async(dispatch_get_main_queue()) {
					errorWindow = MessageWindow(parent: viewForError, darkenBackground: true, titleStringId: "iCloudError", textStringId: "iCloudQueryError", buttonStringIds: ["Close"], error: error,
					handler: { (buttonIndex) -> () in
						errorWindow?.close()
					})
				}
			}
			
			// Reset read-array. User might try downloading again.
			allCKRecords = []
			
			return
		}
		else {
			// received all records from the cloud
			
			var movieRecordArray: [MovieRecord] = []
			let prefsCountryString = (NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
			let country = MovieCountry(rawValue: prefsCountryString)
			
			if let country = country {
				// generate array of MovieRecord objects and store the thumbnail posters to "disc"
				for ckRecord in self.allCKRecords {
					let newRecord = MovieRecord(country: country)
					newRecord.initWithCKRecord(ckRecord)
					movieRecordArray.append(newRecord)
				}
			}
			else {
				NSLog("No MovieCountry object for country \(prefsCountryString)")
			}
			
			if (movieRecordArray.isEmpty) {
				if let saveStopIndicator = self.stopIndicator {
					dispatch_async(dispatch_get_main_queue()) {
						saveStopIndicator()
					}
				}
				
				self.errorHandler?(errorMessage: "First start: No records found in Cloud.")
				
				var errorWindow: MessageWindow?
				
				if let viewForError = viewForError {
					dispatch_async(dispatch_get_main_queue()) {
						errorWindow = MessageWindow(parent: viewForError, darkenBackground: true, titleStringId: "NoRecordsInCloudTitle",
							textStringId: "NoRecordsInCloudText", buttonStringIds: ["Close"], handler: { (buttonIndex) -> () in
								errorWindow?.close()
						})
					}
				}
				
				return
			}
			
			// Get all thumbnails
			
			let targetPath = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(Constants.movieStartsGroup)?.path
			let sourcePath = Constants.imageBaseUrl + PosterSizePath.Small.rawValue
			
			if let country = country, targetPath = targetPath {
				for movieRecord in movieRecordArray {
					let posterUrl = movieRecord.posterUrl[country.languageArrayIndex]
					let tmdbId = movieRecord.tmdbId
					
					if NSFileManager.defaultManager().fileExistsAtPath(targetPath + Constants.thumbnailFolder + posterUrl) {
						// don't load the thumbnail if it's already here
						continue
					}

					if let sourceUrl = NSURL(string: sourcePath + posterUrl) {
						let task = NSURLSession.sharedSession().downloadTaskWithURL(sourceUrl,
							completionHandler: { [unowned self] (location: NSURL?, response: NSURLResponse?, error: NSError?) -> Void in
							if let error = error {
								NSLog("Error getting thumbnail: \(error.description)")
							}
							else if let receivedPath = location?.path {
								// move received thumbnail to target path where it belongs and update the thumbnail in the table view
								do {
									try NSFileManager.defaultManager().moveItemAtPath(receivedPath, toPath: targetPath + Constants.thumbnailFolder + posterUrl)
									if let tmdbId = tmdbId {
										self.updateThumbnailHandler?(tmdbId: tmdbId)
									}
								}
								catch let error as NSError {
									if ((error.domain == NSCocoaErrorDomain) && (error.code == NSFileWriteFileExistsError)) {
										// ignoring, because it's okay it it's already there
									}
									else {
										NSLog("Error moving poster: \(error.description)")
									}
								}
							}
						})
						
						task.resume()
					}
				}
			}

			let userDefaults = NSUserDefaults(suiteName: Constants.movieStartsGroup)
			userDefaults?.setObject(NSDate(), forKey: Constants.prefsLatestDbSuccessfullUpdate)
			userDefaults?.synchronize()
			
			// finish movies
			if let completionHandler = self.completionHandler, errorHandler = self.errorHandler {
				loadGenreDatabase({ [unowned self] () -> () in
					self.writeMovies(movieRecordArray, updatedMoviesAsRecordArray: self.allCKRecords, completionHandler: completionHandler, errorHandler: errorHandler)
				})
			}
			else {
				if let saveStopIndicator = self.stopIndicator {
					dispatch_async(dispatch_get_main_queue()) {
						saveStopIndicator()
					}
				}
				self.errorHandler?(errorMessage: "One of the handlers is nil!")
				
				var errorWindow: MessageWindow?
				
				if let viewForError = viewForError {
					dispatch_async(dispatch_get_main_queue()) {
						errorWindow = MessageWindow(parent: viewForError, darkenBackground: true, titleStringId: "InternalErrorTitle", textStringId: "InternalErrorText", buttonStringIds: ["Close"],
							handler: { (buttonIndex) -> () in
								errorWindow?.close()
							}
						)
					}
				}
				return
			}
		}
	}
	
	
	/**
		Reads the movie database from local file and returns it.
	
		- returns: All movies as array of MovieRecord objects, or nil on error
	*/
	func readDatabaseFromFile() -> [MovieRecord]? {
		let prefsCountryString = (NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
		guard let country = MovieCountry(rawValue: prefsCountryString) else { return nil }

		if let moviesPlistFile = moviesPlistFile {
			// try to load movies from device
			if let loadedDictArray = NSArray(contentsOfFile: moviesPlistFile) as? [NSDictionary] {
				// successfully loaded movies from device
				return MovieDatabaseHelper.dictArrayToMovieRecordArray(loadedDictArray, country: country)
			}
		}
		
		return nil
	}
	
	
	// MARK: - Functions for reading only updated movies

	
	/**
		Checks if there are new or updates movies in the cloud and gets them.
	*/
	func getUpdatedMovies(	allMovies: [MovieRecord],
							country: MovieCountry,
							addNewMovieHandler: (movie: MovieRecord) -> (),
							updateMovieHandler: (movie: MovieRecord) -> (),
							removeMovieHandler: (movie: MovieRecord) -> (),
							completionHandler: (movies: [MovieRecord]?) -> (),
							errorHandler: (errorMessage: String) -> ())
	{
		self.addNewMovieHandler = addNewMovieHandler
		self.updateMovieHandler = updateMovieHandler
		self.removeMovieHandler = removeMovieHandler
		self.completionHandler  = completionHandler
		self.errorHandler		= errorHandler
		
		self.loadedMovieRecordArray = allMovies
		
		let userDefaults = NSUserDefaults(suiteName: Constants.movieStartsGroup)
		let latestModDate: NSDate? = userDefaults?.objectForKey(Constants.prefsLatestDbModification) as? NSDate
		
		if let modDate: NSDate = latestModDate {
			let minReleaseDate = NSDate(timeIntervalSinceNow: 60 * 60 * 24 * -1 * Constants.maxDaysInThePast)
			
			NSLog("Getting records after modification date \(modDate) and after releasedate \(minReleaseDate)")
			
			UIApplication.sharedApplication().networkActivityIndicatorVisible = true
			
			// get records modified after the last modification of the local database
			let predicateModificationDate = NSPredicate(format: "(%K > %@) AND (modificationDate > %@)", argumentArray: [country.databaseKeyRelease, minReleaseDate, modDate])
			let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [predicateModificationDate])
			
			let query = CKQuery(recordType: self.recordType, predicate: predicate)
			let queryOperation = CKQueryOperation(query: query)

			let operationQueue = NSOperationQueue()
			executeQueryOperationUpdatedMovies(queryOperation, onOperationQueue: operationQueue)
		}
		else {
			NSLog("ERROR: mo last mod.data of db")
		}
	}
	
	
	/**
		Sends a new CloudKit query to get more updated records.
	
		- parameter queryOperation:		The query operation containing the predicates
		- parameter onOperationQueue:	The queue for the query operation
	*/
	func executeQueryOperationUpdatedMovies(queryOperation: CKQueryOperation, onOperationQueue operationQueue: NSOperationQueue) {
		let prefsCountryString = (NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
		
		if let country = MovieCountry(rawValue: prefsCountryString) {
			queryOperation.desiredKeys = self.queryKeys + country.languageQueryKeys + country.countryQueryKeys
		}
		else {
			NSLog("executeQueryOperationUpdatedMovies: Error getting country for country-code \(prefsCountryString)")
		}
		
		queryOperation.database = cloudKitDatabase
		queryOperation.qualityOfService = NSQualityOfService.UserInitiated
		
		queryOperation.recordFetchedBlock = { (record : CKRecord) -> Void in
			self.recordFetchedUpdatedMoviesCallback(record)
		}
		
		queryOperation.queryCompletionBlock = { (cursor: CKQueryCursor?, error: NSError?) -> Void in
			if let cursor = cursor {
				// some objects are here, ask for more
				let queryCursorOperation = CKQueryOperation(cursor: cursor)
				self.executeQueryOperationUpdatedMovies(queryCursorOperation, onOperationQueue: operationQueue)
			}
			else {
				// download finished (with error or not)
				self.queryOperationFinishedUpdatedMovies(error)
			}
		}
		
		// Add the operation to the operation queue to execute it
		operationQueue.addOperation(queryOperation)
	}
	

	/**
		Adds the record to an array to save it for later processing.
		This function is called when a new updated record was fetched from the CloudKit database.
	
		- parameter record:	The record from the CloudKit database
	*/
	func recordFetchedUpdatedMoviesCallback(record: CKRecord) {
		
		let prefsCountryString = (NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
		guard let country = MovieCountry(rawValue: prefsCountryString) else { NSLog("recordFetchedUpdatedMoviesCallback: Corrupt countrycode \(prefsCountryString)"); return }
			
		let newMovieRecord = MovieRecord(country: country)
		newMovieRecord.initWithCKRecord(record)
		var movieAlreadyExists: Bool = false
		
		if let existingMovieRecords = loadedMovieRecordArray {
			for existingMovieRecord in existingMovieRecords {
				if (existingMovieRecord.id == newMovieRecord.id) {
					movieAlreadyExists = true
					break
				}
			}
		}
		
		if (movieAlreadyExists) {
			self.updateMovieHandler?(movie: newMovieRecord)
		}
		else {
			self.addNewMovieHandler?(movie: newMovieRecord)
		}
		
		updatedCKRecords.append(record)
	}
	
	
	/**
		This function is called when all updated records have been fetched from the CloudKit database.
		MovieRecord objects are generated and save.
	
		- parameter error:	The error object
	*/
	func queryOperationFinishedUpdatedMovies(error: NSError?) {
		if let error = error {
			// there was an error
			self.errorHandler?(errorMessage: "Error querying updated records: \(error.code) (\(error.description))")
			return
		}
		else {
			// received records from the cloud
			let userDefaults = NSUserDefaults(suiteName: Constants.movieStartsGroup)
			userDefaults?.setObject(NSDate(), forKey: Constants.prefsLatestDbSuccessfullUpdate)
			userDefaults?.synchronize()

			if (updatedCKRecords.count > 0) {
				// generate an array of MovieRecords
				var updatedMovieRecordArray: [MovieRecord] = []
					
				let prefsCountryString = (NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
				guard let country = MovieCountry(rawValue: prefsCountryString) else { NSLog("queryOperationFinishedUpdatedMovies: Corrupt countrycode \(prefsCountryString)"); return }
					
				for ckRecord in self.updatedCKRecords {
					let newRecord = MovieRecord(country: country)
					newRecord.initWithCKRecord(ckRecord)
					updatedMovieRecordArray.append(newRecord)
				}
					
				// merge both arrays (the existing movies and the updated movies)
				if (self.loadedMovieRecordArray != nil) {
					MovieDatabaseHelper.joinMovieRecordArrays(&(self.loadedMovieRecordArray!), updatedMovies: updatedMovieRecordArray)
				}
			}
			
			// delete all movies which are too old
			if (loadedMovieRecordArray != nil) {
				cleanUpExistingMovies(&loadedMovieRecordArray!)
			}
			
			if (updatedCKRecords.count > 0) {
				// we have updated records: also update genre-database, then clean-up posters
				loadGenreDatabase({ () -> () in
					self.cleanUpPosters()
					self.writeMoviesToDevice()
				})
			}
			else {
				// clean up posters
				cleanUpPosters()
				self.writeMoviesToDevice()
			}
		}
	}
	
	
	// MARK: - Private helper functions
	
	
	/**
		Writes the movies and the modification date to file.
	
		- parameter allMovieRecords:			The array with all movies. This will be written to file.
		- parameter updatedMoviesAsRecordArray:	The array with all updated movies (only used to find out latest modification date)
		- parameter completionHandler:			The handler which is called upon completion
		- parameter errorHandler:				The handler which is called if an error occurs
	*/
	private func writeMovies(allMovieRecords: [MovieRecord], updatedMoviesAsRecordArray: [CKRecord], completionHandler: (movies: [MovieRecord]?) -> (), errorHandler: (errorMessage: String) -> ()) {

		// write it to device
		
		if let filename = self.moviesPlistFile {
			if ((MovieDatabaseHelper.movieRecordArrayToDictArray(allMovieRecords) as NSArray).writeToFile(filename, atomically: true) == false) {
				if let saveStopIndicator = self.stopIndicator {
					dispatch_async(dispatch_get_main_queue()) {
						saveStopIndicator()
					}
				}
				
				errorHandler(errorMessage: "*** Error writing movies-file")
				var errorWindow: MessageWindow?
				
				if let viewForError = viewForError {
					dispatch_async(dispatch_get_main_queue()) {
						errorWindow = MessageWindow(parent: viewForError, darkenBackground: true, titleStringId: "InternalErrorTitle", textStringId: "ErrorWritingFile", buttonStringIds: ["Close"],
							handler: { (buttonIndex) -> () in
								errorWindow?.close()
							}
						)
					}
				}
				
				return
			}
		}
		else {
			errorHandler(errorMessage: "*** Filename for movies-list is broken")
			return
		}
		
		// and store the latest modification-date of the records
		if (updatedMoviesAsRecordArray.count > 0) {
			MovieDatabaseHelper.storeLastModification(updatedMoviesAsRecordArray)
		}
		
		// success
		dispatch_async(dispatch_get_main_queue()) {
			self.finishHandler?()
		}
		
		completionHandler(movies: allMovieRecords)
	}

	
	/**
		Checks if there are movies which are too old and removes them.
	
		- parameter existingMovies:	The array of existing movies to check
	*/
	private func cleanUpExistingMovies(inout existingMovies: [MovieRecord]) {
		let compareDate = NSDate(timeIntervalSinceNow: 60 * 60 * 24 * -1 * Constants.maxDaysInThePast) // 30 days ago
		let oldNumberOfMovies = existingMovies.count
		var removedMovies = 0
		
		print("Cleaning up old movies...")
		
		let prefsCountryString = (NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
		
		if let country = MovieCountry(rawValue: prefsCountryString) {

			for index in (0 ..< existingMovies.count).reverse() {
				let releaseDate = existingMovies[index].releaseDate[country.countryArrayIndex]
				
				if releaseDate.compare(compareDate) == NSComparisonResult.OrderedAscending {
					// movie is too old
					removeMovieHandler?(movie: existingMovies[index])
					print("   '\(existingMovies[index].origTitle)' (\(releaseDate)) removed")
					existingMovies.removeAtIndex(index)
				}
			}

			removedMovies = oldNumberOfMovies - existingMovies.count

			if (removedMovies > 0) {
				// udpate the watch
				WatchSessionManager.sharedManager.sendAllFavoritesToWatch(true, sendThumbnails: false)
			}
		}

		print("Clean up over, removed \(removedMovies) movies from local file. Now we have \(existingMovies.count) movies.")
	}


	/**
		Deleted unneeded poster files from the device, and reads missing poster files from the CloudKit database to the device.
	*/
	private func cleanUpPosters() {
		let pathUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(Constants.movieStartsGroup)
		
		if let basePath = pathUrl?.path, movies = loadedMovieRecordArray {
			deleteUnneededPosters(basePath, movies: movies)
			downloadMissingPosters(basePath, movies: movies)
			deleteUnneededYoutubeImages(basePath, movies: movies)
		}
	}

	/**
		Tries to write the movies to the device.
	*/
	private func writeMoviesToDevice() {
		if let completionHandler = completionHandler, errorHandler = errorHandler, loadedMovieRecordArray = loadedMovieRecordArray {
			writeMovies(loadedMovieRecordArray, updatedMoviesAsRecordArray: updatedCKRecords, completionHandler: completionHandler, errorHandler: errorHandler)
		}
		else {
			errorHandler?(errorMessage: "One of the handlers is nil!")
		}
	}
	

	/**
		Checks for all poster files if they are still needed and delete them if not.

		- parameter basePath:	The local basepath for all images
		- parameter movies:		The array with all movie records
	*/
	private func deleteUnneededPosters(basePath: String, movies: [MovieRecord]) {
		
		var filenames: [AnyObject]?
		do {
			filenames = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(basePath + Constants.thumbnailFolder)
		} catch let error as NSError {
			NSLog("Error getting thumbnail folder: \(error.description)")
			filenames = nil
		}
		
		if let posterfilenames = filenames {
			for posterfilename in posterfilenames {
				var found = false
				
				if let posterfilenameString = posterfilename as? String {
					for movie in movies {
                        if (found == false) {
                            for posterUrl in movie.posterUrl {
                                if ((posterUrl.characters.count > 3) &&
                                    (posterfilenameString == posterUrl.substringFromIndex(posterUrl.startIndex.advancedBy(1))))
                                {
                                    found = true
                                    break
                                }
                            }
                        }
					}
					
					if (found == false) {
						// posterfile is not in any database record anymore: delete poster(s)
						print("Deleting unneeded poster image \(posterfilenameString)")

						do {
							try NSFileManager.defaultManager().removeItemAtPath(basePath + Constants.thumbnailFolder + "/" + posterfilenameString)
						} catch let error as NSError {
							NSLog("Error removing thumbnail: \(error.description)")
						}
						do {
							try NSFileManager.defaultManager().removeItemAtPath(basePath + Constants.bigPosterFolder + "/" + posterfilenameString)
						} catch {
							// this happens all the time, when no hi-res poster was loaded
							// NSLog("Error removing poster: \(error.description)")
						}
					}
				}
			}
		}
	}
	
	
	/**
		Checks for all youtube-titles-images if they are still needed and delete them if not.
	
		- parameter basePath:	The local basepath for all images
		- parameter movies:		The array with all movie records
	*/
	private func deleteUnneededYoutubeImages(basePath: String, movies: [MovieRecord]) {
		
		var filenames: [AnyObject]?
		do {
			filenames = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(basePath + Constants.trailerFolder)
		} catch let error as NSError {
			NSLog("Error getting trailer folder: \(error.description)")
			filenames = nil
		}
		
		if let trailerfilenames = filenames {
			for trailerfilename in trailerfilenames {
				var found = false
				
				if let trailerfilenameString = trailerfilename as? String {
					for movie in movies {
						for trailerIdsForCountry in movie.trailerIds {
							for trailerId in trailerIdsForCountry {
								if (trailerId.characters.count > 0) {
									if (trailerfilenameString.beginsWith(trailerId)) {
										found = true
										break
									}
								}
							}
						}
					}

					if (found == false) {
						// trailerfile is not in any database record anymore: delete trailer-image
						
						print("Deleting unneeded trailer image \(trailerfilenameString)")

						do {
							try NSFileManager.defaultManager().removeItemAtPath(basePath + Constants.trailerFolder + "/" + trailerfilenameString)
						} catch let error as NSError {
							NSLog("Error removing trailer image: \(error.description)")
						}
					}
				}
			}
		}
	}
	
	
	/**
		Loads missing poster files and downloads them.
	
		- parameter basePath:	The local basepath for all images
		- parameter movies:		The array with all movie records
	*/
	private func downloadMissingPosters(basePath: String, movies: [MovieRecord]) {
		
		let prefsCountryString = (NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
		let sourcePath = Constants.imageBaseUrl + PosterSizePath.Small.rawValue

		guard let country = MovieCountry(rawValue: prefsCountryString) else { return }
		
		for movie in movies {
			var posterUrl = movie.posterUrl[country.languageArrayIndex]
			
			if (posterUrl.characters.count == 0) {
				// if there is no poster in wanted language, try the english one
				posterUrl = movie.posterUrl[MovieCountry.England.languageArrayIndex]
			}
			
			if ((posterUrl.characters.count > 0) && (NSFileManager.defaultManager().fileExistsAtPath(basePath + Constants.thumbnailFolder + posterUrl) == false)) {
				// poster file is missing
				
				if let sourceUrl = NSURL(string: sourcePath + posterUrl) {
					let task = NSURLSession.sharedSession().downloadTaskWithURL(sourceUrl,
						completionHandler: { (location: NSURL?, response: NSURLResponse?, error: NSError?) -> Void in
						if let error = error {
							NSLog("Error getting missing thumbnail: \(error.description)")
						}
						else if let receivedPath = location?.path {
							// move received thumbnail to target path where it belongs and update the thumbnail in the table view
							do {
								try NSFileManager.defaultManager().moveItemAtPath(receivedPath, toPath: basePath + Constants.thumbnailFolder + posterUrl)
								if let tmdbId = movie.tmdbId {
									self.updateThumbnailHandler?(tmdbId: tmdbId)
								}
							}
							catch let error as NSError {
								if ((error.domain == NSCocoaErrorDomain) && (error.code == NSFileWriteFileExistsError)) {
									// ignoring, because it's okay it it's already there
								}
								else {
									NSLog("Error moving missing poster: \(error.description)")
								}
							}
						}
					})
					
					task.resume()
				}
			}
		}
	}
	

	/**
		Loads the genre database.
	
		- parameter genresLoadedHandler: This handler is called after the genres are read, even if an error occured.
	*/
	private func loadGenreDatabase(genresLoadedHandler: (() -> ())) {
		
		let genreDatabase = GenreDatabase(
			finishHandler: { (genres) -> () in
				genresLoadedHandler()
			},
			errorHandler: { (errorMessage) -> () in
				NSLog("Error reading genres from the Cloud: \(errorMessage)")
				genresLoadedHandler()
			}
		)
		
		genreDatabase.readGenresFromCloud()
	}

}

