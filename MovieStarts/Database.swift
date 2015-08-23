//
//  Database.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 14.02.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation
import CloudKit


class Database {
	
	var recordType: String
	var moviesPlistPath: String?
	var moviesPlistFile: String?
//	var loadedDictArray: [NSDictionary]?
	var loadedMovieRecordArray: [MovieRecord]?
	
	var totalNumberOfRecordsFromCloud: Int?

	var cloudKitContainer: CKContainer
	var cloudKitDatabase: CKDatabase
	
	var completionHandler: ((movies: [MovieRecord]?) -> ())?
	var errorHandler: ((errorMessage: String) -> ())?
	var showIndicator: ((updating: Bool, showProgress: Bool) -> ())?
	var stopIndicator: (() -> ())?
	var updateIndicator: ((progress: Float) -> ())?
	
	var addNewMovieHandler: ((movie: MovieRecord) -> ())?
	var updateMovieHandler: ((movie: MovieRecord) -> ())?
	
	var allCKRecords: [CKRecord] = []
	var updatedCKRecords: [CKRecord] = []

	let userDefaults = NSUserDefaults(suiteName: Constants.MOVIESTARTS_GROUP)
	let desiredQueryKeysForUpdate = [Constants.DB_ID_TMDB_ID, Constants.DB_ID_TITLE, Constants.DB_ID_ORIG_TITLE, Constants.DB_ID_RUNTIME, Constants.DB_ID_VOTE_AVERAGE, Constants.DB_ID_SYNOPSIS,
		Constants.DB_ID_RELEASE, Constants.DB_ID_GENRES, Constants.DB_ID_CERTIFICATION, Constants.DB_ID_POSTER_URL, Constants.DB_ID_PRODUCTION_COUNTRIES,
		Constants.DB_ID_IMDB_ID, Constants.DB_ID_DIRECTORS, Constants.DB_ID_ACTORS, Constants.DB_ID_TRAILER_NAMES, Constants.DB_ID_TRAILER_IDS,
		Constants.DB_ID_ASSET, Constants.DB_ID_HIDDEN]
	let desiredQueryKeysForAll = [Constants.DB_ID_TMDB_ID, Constants.DB_ID_TITLE, Constants.DB_ID_ORIG_TITLE, Constants.DB_ID_RUNTIME, Constants.DB_ID_VOTE_AVERAGE, Constants.DB_ID_SYNOPSIS,
		Constants.DB_ID_RELEASE, Constants.DB_ID_GENRES, Constants.DB_ID_CERTIFICATION, Constants.DB_ID_POSTER_URL, Constants.DB_ID_PRODUCTION_COUNTRIES,
		Constants.DB_ID_IMDB_ID, Constants.DB_ID_DIRECTORS, Constants.DB_ID_ACTORS, Constants.DB_ID_TRAILER_NAMES, Constants.DB_ID_TRAILER_IDS,
		Constants.DB_ID_ASSET, Constants.DB_ID_HIDDEN, Constants.DB_ID_POSTER_ASSET]

	
	init(recordType: String) {
		self.recordType = recordType
		var fileUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(Constants.MOVIESTARTS_GROUP)

		if ((fileUrl != nil) && (fileUrl!.path != nil)) {
			self.moviesPlistPath = fileUrl!.path!
		}
        else {
            // TODO error handling
            println("Error getting url for app-group.")
        }
		
		self.cloudKitContainer = CKContainer(identifier: Constants.CLOUDKIT_CONTAINER_ID)
		self.cloudKitDatabase = cloudKitContainer.publicCloudDatabase
	}
	
	
	/**
		If a local database exists, this method reads the movies from the local database. Otherwise, it gets all movies from the cloud.

		:param: completionHandler	The handler which is called after all movies are read
		:param: errorHandler		The handler which is called if an error occurs
		:param: showIndicator		Callback which is called to show a progress indicator
		:param: stopIndicator		Callback which is called to stop the progress indicator
		:param: updateIndicator		Callback which is called to update the progress indicator with a new progress
	*/
	func getAllMovies(	completionHandler: (movies: [MovieRecord]?) -> (),
						errorHandler: (errorMessage: String) -> (),
						showIndicator: ((updating: Bool, showProgress: Bool) -> ())?,
						stopIndicator: (() -> ())?,
						updateIndicator: ((progress: Float) -> ())?)
	{
		self.completionHandler 	= completionHandler
		self.errorHandler 		= errorHandler
		self.showIndicator		= showIndicator
		self.stopIndicator		= stopIndicator
		self.updateIndicator	= updateIndicator
		
		if let saveMoviesPlistPath = self.moviesPlistPath {
			// try to load movies from device
			self.moviesPlistFile = saveMoviesPlistPath.stringByAppendingPathComponent(self.recordType + ".plist")
			var loadedDictArray = NSArray(contentsOfFile: moviesPlistFile!) as? [NSDictionary]

			if let loadedDictArray = loadedDictArray {
				
				// successfully loaded movies from device
				
				loadedMovieRecordArray = DatabaseHelper.dictArrayToMovieRecordArray(loadedDictArray)
				

				
/*
				// Should we search for updated movies?

				var getUpdatesFlag = true
				var latestUpdate: NSDate? = userDefaults?.objectForKey(Constants.PREFS_LATEST_DB_UPDATE_CHECK) as NSDate?
				
				if let saveLatestUpdate: NSDate = latestUpdate {
					var daysSinceLastUpdate = abs(Int(saveLatestUpdate.timeIntervalSinceNow)) / 60 / 60 / 24
					
					if (daysSinceLastUpdate < Constants.DAYS_TILL_DB_UPDATE) {
						getUpdatesFlag = false
					}
				}

				if (getUpdatesFlag) {
					// get updates from the cloud
					var latestModDate: NSDate? = userDefaults?.objectForKey(Constants.PREFS_LATEST_DB_MODIFICATION) as! NSDate?

					if let saveModDate: NSDate = latestModDate {

						println("Getting records after modification date \(saveModDate)")
						
						if let saveShowIndicator = self.showIndicator {
							dispatch_async(dispatch_get_main_queue()) {
								saveShowIndicator(updating: true, showProgress: false)
							}
						}
						
						var predicate = NSPredicate(format: "modificationDate > %@", argumentArray: [saveModDate])
						var query = CKQuery(recordType: self.recordType, predicate: predicate)
						
						let queryOperation = CKQueryOperation(query: query)
						queryOperation.recordFetchedBlock = recordFetchedUpdatedMoviesCallback
						queryOperation.queryCompletionBlock = queryCompleteUpdatedMoviesCallback
						queryOperation.desiredKeys = desiredQueryKeysForUpdate
						self.cloudKitDatabase.addOperation(queryOperation)
					}
				}
				else {
					// no updates wanted, just return the stuff from the file
*/
					completionHandler(movies: loadedMovieRecordArray)
/*
				}
*/
			}
			else {
				// movies are not on the device: get them from the cloud
				
				// first get number of records for nice progress display

				var recordId = CKRecordID(recordName: Constants.RECORD_ID_RESULT_USA)
				
				self.cloudKitDatabase.fetchRecordWithID(recordId, completionHandler: { (record: CKRecord!, error: NSError!) in
					
					if (error != nil) {
						
						// TODO error 1 wenn nicht in iCloud eingeloggt (checken)
						
						println("Error getting number of records: \(error!.code) (\(error!.localizedDescription))")
					}
					else if (record != nil) {
						self.totalNumberOfRecordsFromCloud = record!.objectForKey(Constants.DB_ID_NUMBER_OF_RECORDS) as? Int
					}

					if let saveShowIndicator = self.showIndicator {
						dispatch_async(dispatch_get_main_queue()) {
							saveShowIndicator(updating: false, showProgress: self.totalNumberOfRecordsFromCloud != nil)
						}
					}
					
					let predicate = NSPredicate(value: true)
					let query = CKQuery(recordType: self.recordType, predicate: predicate)
					
					let queryOperation = CKQueryOperation(query: query)
					queryOperation.recordFetchedBlock = self.recordFetchedAllMoviesCallback
					queryOperation.queryCompletionBlock = self.queryCompleteAllMoviesCallback
					queryOperation.resultsLimit = 10
					queryOperation.desiredKeys = self.desiredQueryKeysForAll
					self.cloudKitDatabase.addOperation(queryOperation)
				})
			}
		}
		else {
			println("No group folder found")
			errorHandler(errorMessage: "No group folder found")
		}
	}

	
	/**
		Checks if there are new or updates movies in the cloud and gets them.
	*/
	func getUpdatedMovies(allMovies: [MovieRecord], addNewMovieHandler: (movie: MovieRecord) -> (), updateMovieHandler: (movie: MovieRecord) -> ()) {
		self.addNewMovieHandler = addNewMovieHandler
		self.updateMovieHandler = updateMovieHandler
		self.loadedMovieRecordArray = allMovies
		
		var latestModDate: NSDate? = userDefaults?.objectForKey(Constants.PREFS_LATEST_DB_MODIFICATION) as! NSDate?
		
		if let saveModDate: NSDate = latestModDate {
			
			println("Getting records after modification date \(saveModDate)")
/*
			if let saveShowIndicator = self.showIndicator {
				dispatch_async(dispatch_get_main_queue()) {
					saveShowIndicator(updating: true, showProgress: false)
				}
			}
*/
			var predicate = NSPredicate(format: "modificationDate > %@", argumentArray: [saveModDate])
			var query = CKQuery(recordType: self.recordType, predicate: predicate)
			
			let queryOperation = CKQueryOperation(query: query)
			queryOperation.recordFetchedBlock = recordFetchedUpdatedMoviesCallback
			queryOperation.queryCompletionBlock = queryCompleteUpdatedMoviesCallback
			queryOperation.desiredKeys = desiredQueryKeysForUpdate
			self.cloudKitDatabase.addOperation(queryOperation)
		}
		else {
			println("ERROR: mo last mod.data of db")
		}
	}
	
	
	/**
		Writes the movies and the modification date to file.
	
		:param: allMovieRecords				The array with all movies
		:param: updatedMoviesAsRecordArray	The array with all updated movies (used to find out latest modification date)
		:param: completionHandler			The handler which is called upon completion
		:param: errorHandler				The handler which is called if an error occurs
	*/
	func writeMovies(allMovieRecords: [MovieRecord], updatedMoviesAsRecordArray: [CKRecord], completionHandler: (movies: [MovieRecord]?) -> (), errorHandler: (errorMessage: String) -> ()) {

		// write it to device
		
		if let filename = self.moviesPlistFile {
			if ((DatabaseHelper.movieRecordArrayToDictArray(allMovieRecords) as NSArray).writeToFile(filename, atomically: true) == false) {
				if let saveStopIndicator = self.stopIndicator {
					dispatch_async(dispatch_get_main_queue()) {
						saveStopIndicator()
					}
				}
				
				errorHandler(errorMessage: "Error writing movies-file")
				return
			}
		}
		else {
			errorHandler(errorMessage: "Filename for movies-list is broken")
			return
		}
		
		// and store the latest modification-date of the records
		if (updatedMoviesAsRecordArray.count > 0) {
			DatabaseHelper.storeLastModification(updatedMoviesAsRecordArray)
		}
		
		// success
		if let saveStopIndicator = self.stopIndicator {
			dispatch_async(dispatch_get_main_queue()) {
				saveStopIndicator()
			}
		}
		
		completionHandler(movies: allMovieRecords)
	}
	
	
	// MARK: - callbacks for getting all movies


	/**
		Adds the record to an array to save it for later processing.
		This function is called when a new record was fetched from the CloudKit database.
	
		:param: record	The record from the CloudKit database
	*/
	func recordFetchedAllMoviesCallback(record: CKRecord!) {
		self.allCKRecords.append(record)
		
		if let saveRecordNumber = self.totalNumberOfRecordsFromCloud {
			if ((self.allCKRecords.count % 5 == 0) || (self.allCKRecords.count == saveRecordNumber)) {
				var percent = Float(self.allCKRecords.count) / Float(saveRecordNumber)
				percent = (percent > 1.0) ? 1.0 : percent
				
				if let saveUpdateIndicator = self.updateIndicator {
					dispatch_async(dispatch_get_main_queue()) {
						saveUpdateIndicator(progress: percent)
					}
				}
			}
		}
	}
	
	
	/**
		Checks if all movies are read or if there are more pages of movies to read from the CloudKit database.
		If all movies are here, MovieRecord objects are generated and save.
		This function is called when all records (or at least all records from a page) have been fetched from the CloudKit database.
	
		:param: cursor	The paging cursor used to find out if there are more pages of movies to load
		:param: error	The error object
	*/
	func queryCompleteAllMoviesCallback(cursor: CKQueryCursor!, error: NSError!) {
		if (cursor == nil) {
			// all objects are here!

			if (error != nil) {
				if let saveStopIndicator = self.stopIndicator {
					dispatch_async(dispatch_get_main_queue()) {
						saveStopIndicator()
					}
				}
				
				// TODO: Error-Code 1 heißt u. a., dass der User nicht in iCloud eingeloggt ist
				
				self.errorHandler?(errorMessage: "Error querying records: \(error!.code) (\(error!.localizedDescription))")
				return
			}
			else {
				// received all records from the cloud
				
				var movieRecordArray: [MovieRecord] = []

				// generate array of MovieRecord objects and store the thumbnail posters to "disc"
				for ckRecord in self.allCKRecords {
					movieRecordArray.append(MovieRecord(ckRecord: ckRecord))
					movieRecordArray.last?.storeThumbnailPoster(ckRecord.objectForKey(Constants.DB_ID_POSTER_ASSET) as? CKAsset)
				}
				
				if (movieRecordArray.isEmpty) {
					if let saveStopIndicator = self.stopIndicator {
						dispatch_async(dispatch_get_main_queue()) {
							saveStopIndicator()
						}
					}
					
					self.errorHandler?(errorMessage: "Error reading assets")
					return
				}
				
				userDefaults?.setObject(NSDate(), forKey: Constants.PREFS_LATEST_DB_UPDATE_CHECK)
				userDefaults?.synchronize()
				
				// finish movies
				if ((self.completionHandler != nil) && (self.errorHandler != nil)) {
					self.writeMovies(movieRecordArray, updatedMoviesAsRecordArray: self.allCKRecords, completionHandler: self.completionHandler!, errorHandler: self.errorHandler!)
				}
				else {
					if let saveStopIndicator = self.stopIndicator {
						dispatch_async(dispatch_get_main_queue()) {
							saveStopIndicator()
						}
					}
					self.errorHandler?(errorMessage: "One of the handlers is nil!")
					return
				}
			}
		}
		else {
			// some objects are here, ask for more
			let queryOperation = CKQueryOperation(cursor: cursor)
			queryOperation.recordFetchedBlock = recordFetchedAllMoviesCallback
			queryOperation.queryCompletionBlock = queryCompleteAllMoviesCallback
			queryOperation.desiredKeys = desiredQueryKeysForAll
			self.cloudKitDatabase.addOperation(queryOperation)
		}
	}
	

	// MARK: - callbacks for getting updated movies
	
	
	/**
		Adds the record to an array to save it for later processing.
		This function is called when a new updated record was fetched from the CloudKit database.
	
		:param: record	The record from the CloudKit database
	*/
	func recordFetchedUpdatedMoviesCallback(record: CKRecord!) {

		var newMovieRecord = MovieRecord(ckRecord: record)
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
//			println("Updated movie: \(newMovieRecord.title!)")
			self.updateMovieHandler?(movie: newMovieRecord)
		}
		else {
//			println("New movie: \(newMovieRecord.title!)")
			self.addNewMovieHandler?(movie: newMovieRecord)
		}
	}

	
	/**
		Checks if all updated movies are read or if there are more pages of movies to read from the CloudKit database.
		If all movies are here, MovieRecord objects are generated and save.
		This function is called when all updated records (or at least all records from a page) have been fetched from the CloudKit database.
	
		:param: cursor	The paging cursor used to find out if there are more pages of movies to load
		:param: error	The error object
	*/
	func queryCompleteUpdatedMoviesCallback(cursor: CKQueryCursor!, error: NSError!) {
		if (cursor == nil) {
			// all updated records are here!

			
			
			
			
/*
			if (error != nil) {
				// there was an error
				
				if let saveStopIndicator = self.stopIndicator {
					dispatch_async(dispatch_get_main_queue()) {
						saveStopIndicator()
					}
				}
				self.errorHandler?(errorMessage: "Error querying updated records: \(error!.code) (\(error!.localizedDescription))")
				return
			}
			else {
				// received records from the cloud
				
				userDefaults?.setObject(NSDate(), forKey: Constants.PREFS_LATEST_DB_UPDATE_CHECK)
				userDefaults?.synchronize()
				
				if (updatedCKRecords.count > 0) {
					// generate an array of MovieRecords
					var updatedMovieRecordArray: [MovieRecord] = []
					
					for ckRecord in updatedCKRecords {
						updatedMovieRecordArray.append(MovieRecord(ckRecord: ckRecord))
					}
					
					// merge both arrays (the existing movies and the updated movies)
					DatabaseHelper.joinMovieRecordArrays(&(loadedMovieRecordArray!), updatedMovies: updatedMovieRecordArray)
				}

				// delete all movies which are too old

				cleanUpExistingMovies(&loadedMovieRecordArray!)
				
				// clean up posters
				
				cleanUpPosters()
			}
*/
			
		}
		else {
			// some objects are here, ask for more
			let queryOperation = CKQueryOperation(cursor: cursor)
			queryOperation.recordFetchedBlock = recordFetchedUpdatedMoviesCallback
			queryOperation.queryCompletionBlock = queryCompleteUpdatedMoviesCallback
			queryOperation.desiredKeys = desiredQueryKeysForUpdate
			cloudKitDatabase.addOperation(queryOperation)
		}
	}
	
	
	// MARK: - cleaning up posters

	
	/**
		Deleted unneeded poster files from the device, and reads missing poster files from the CloudKit database to the device.
	*/
	private func cleanUpPosters() {
		
		var pathUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(Constants.MOVIESTARTS_GROUP)
		
		if let pathUrl = pathUrl, basePath = pathUrl.path, movies = loadedMovieRecordArray {
			var error : NSErrorPointer = nil
			var filenames = NSFileManager.defaultManager().contentsOfDirectoryAtPath(basePath + Constants.THUMBNAIL_FOLDER, error: error)
			
			// first check for all poster files if they are still needed
			
			if let posterfilenames = filenames {
				for posterfilename in posterfilenames {
					var found = false
					
					for movie in movies {
						if let posterUrl = movie.posterUrl where count(posterUrl) > 3 {
							
							if ((posterfilename as! String) == posterUrl.substringWithRange(Range<String.Index>(start: advance(posterUrl.startIndex, 1), end: posterUrl.endIndex))) {
								found = true
								break
							}
						}
					}
					
					if !found {
						
						// posterfile is not in any database record anymore: delete poster(s)
						
						println("Deleting unneeded poster image \(posterfilename as! String)")
						NSFileManager.defaultManager().removeItemAtPath(basePath + Constants.THUMBNAIL_FOLDER + "/" + (posterfilename as! String), error: error)
						NSFileManager.defaultManager().removeItemAtPath(basePath + Constants.BIG_POSTER_FOLDER + "/" + (posterfilename as! String), error: error)
					}
				}
			}
			
			// second: check for missing poster files and download them

			var idsOfMissindPosters : [Int] = []
			
			for movie in movies {
				if let posterUrl = movie.posterUrl {
					if (NSFileManager.defaultManager().fileExistsAtPath(basePath + Constants.THUMBNAIL_FOLDER + posterUrl) == false) {
						// poster file is missing
						idsOfMissindPosters.append(movie.tmdbId!)
					}
				}
			}

			if (idsOfMissindPosters.count > 0) {

				// download missing posters
				
				var predicate = NSPredicate(format: "tmdbId IN %@", argumentArray: [idsOfMissindPosters])
				var query = CKQuery(recordType: self.recordType, predicate: predicate)
				let queryOperation = CKQueryOperation(query: query)
				queryOperation.recordFetchedBlock = recordFetchedMissingPostersCallback
				queryOperation.queryCompletionBlock = queryCompleteMissingPostersCallback
				queryOperation.desiredKeys = [Constants.DB_ID_POSTER_ASSET, Constants.DB_ID_TMDB_ID]
				self.cloudKitDatabase.addOperation(queryOperation)
				
				println("Loading \(idsOfMissindPosters.count) missing posters.")
			}
			else {
				// no posters missing
				downloadsFinished()
			}
		}
	}
	
	
	/**
		Adds the poster record to an array to save it for later processing.
		This function is called when a new poster record was fetched from the CloudKit database.
	
		:param: record	The record from the CloudKit database
	*/
	func recordFetchedMissingPostersCallback(record: CKRecord!) {
		
		// poster fetched: store it to disk
		
		var tmdbIdToFind: Int = record.objectForKey(Constants.DB_ID_TMDB_ID) as! Int
		
		if let movies = loadedMovieRecordArray {
			for movie in movies {
				if let tmdbId = movie.tmdbId where tmdbId == tmdbIdToFind {
					movie.storeThumbnailPoster(record.objectForKey(Constants.DB_ID_POSTER_ASSET) as? CKAsset)
				}
			}
		}
	}

	
	/**
		Is called when all missing poster files have been fetched from the CloudKit database.
	
		:param: cursor	The paging cursor used to find out if there are more pages of movies to load
		:param: error	The error object
	*/
	func queryCompleteMissingPostersCallback(cursor: CKQueryCursor!, error: NSError!) {
		if (cursor == nil) {
			if (error != nil) {
				if let saveStopIndicator = self.stopIndicator {
					dispatch_async(dispatch_get_main_queue()) {
						saveStopIndicator()
					}
				}
				
				// TODO: Error-Code 1 heißt u. a., dass der User nicht in iCloud eingeloggt ist
				
				self.errorHandler?(errorMessage: "Error querying posters: \(error!.code) (\(error!.localizedDescription))")
				return
			}
			else {
				// no errors
				downloadsFinished()
			}
		}
		else {
			// some objects are here, ask for more
			let queryOperation = CKQueryOperation(cursor: cursor)
			queryOperation.recordFetchedBlock = recordFetchedMissingPostersCallback
			queryOperation.queryCompletionBlock = queryCompleteMissingPostersCallback
			queryOperation.desiredKeys = [Constants.DB_ID_POSTER_ASSET, Constants.DB_ID_TMDB_ID]
			self.cloudKitDatabase.addOperation(queryOperation)
		}
	}
	
	
	// MARK: - private helper functions

	
	/**
		Checks if there are movies which are too old and removes them.
	
		:param: existingMovies	The array of existing movies to check
	*/
	private func cleanUpExistingMovies(inout existingMovies: [MovieRecord]) {
		
		var compareDate = NSDate(timeIntervalSinceNow: 60 * 60 * 24 * -1 * Constants.MAX_DAYS_IN_THE_PAST) // 30 days ago
		var oldNumberOfMovies = existingMovies.count
		
		println("Cleaning up old movies...")
		
		for (var index = existingMovies.count-1; index >= 0; index--) {
			var releaseDate = existingMovies[index].releaseDate
			
			if let saveDate = releaseDate {
				if (saveDate.compare(compareDate) == NSComparisonResult.OrderedAscending) {
					// movie is too old
					println("   '\(existingMovies[index].title)' (\(saveDate)) removed")
					existingMovies.removeAtIndex(index)
				}
			}
		}
		
		println("Clean up over, removed \(oldNumberOfMovies - existingMovies.count) movies from local file. Now we have \(existingMovies.count) movies.")
	}

	
	/**
		Tries to write the movies to the device.
	*/
	private func downloadsFinished() {
		// finish movies
		if ((completionHandler != nil) && (errorHandler != nil)) {
			writeMovies(loadedMovieRecordArray!, updatedMoviesAsRecordArray: updatedCKRecords, completionHandler: completionHandler!, errorHandler: errorHandler!)
		}
		else {
			if let saveStopIndicator = stopIndicator {
				dispatch_async(dispatch_get_main_queue()) {
					saveStopIndicator()
				}
			}
			errorHandler?(errorMessage: "One of the handlers is nil!")
			return
		}

	}
}
