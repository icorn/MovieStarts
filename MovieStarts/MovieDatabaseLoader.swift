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


class MovieDatabaseLoader : MovieDatabaseParent, MovieDatabaseProtocol {

	required init(recordType: String, viewForError: UIView?) {
		super.init(recordType: recordType)

		self.viewForError = viewForError
		queryKeys = [Constants.dbIdTmdbId, Constants.dbIdOrigTitle, Constants.dbIdPopularity, Constants.dbIdVoteAverage, Constants.dbIdVoteCount, Constants.dbIdProductionCountries, Constants.dbIdImdbId, Constants.dbIdDirectors, Constants.dbIdActors, Constants.dbIdHidden, Constants.dbIdGenreIds, Constants.dbIdCharacters, Constants.dbIdId, Constants.dbIdTrailerIdsEN, Constants.dbIdPosterUrlEN, Constants.dbIdSynopsisEN, Constants.dbIdRuntimeEN, Constants.dbIdRatingImdb, Constants.dbIdRatingTomato, Constants.dbIdTomatoImage, Constants.dbIdTomatoURL, Constants.dbIdRatingMetacritic]

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
				
				executeQueryOperation(queryOperation, onOperationQueue: operationQueue)
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
	internal func executeQueryOperation(queryOperation: CKQueryOperation, onOperationQueue operationQueue: NSOperationQueue) {
		let prefsCountryString = (NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue

		if let country = MovieCountry(rawValue: prefsCountryString) {
			queryOperation.desiredKeys = self.queryKeys + country.languageQueryKeys + country.countryQueryKeys
		}
		else {
			NSLog("executeQueryOperationAllMovies: Error getting country for country-code \(prefsCountryString)")
		}
		
		queryOperation.database = cloudKitDatabase
		queryOperation.qualityOfService = NSQualityOfService.UserInitiated
		queryOperation.recordFetchedBlock = self.recordFetchedCallback
		
/*
		queryOperation.recordFetchedBlock = { [unowned self] (record : CKRecord) -> Void in
			self.allCKRecords.append(record)
			self.updateIndicator?(counter: self.allCKRecords.count)
		}
*/
		queryOperation.queryCompletionBlock = { [unowned self] (cursor: CKQueryCursor?, error: NSError?) -> Void in
			if let cursor = cursor {
				// some objects are here, ask for more
				let queryCursorOperation = CKQueryOperation(cursor: cursor)
				self.executeQueryOperation(queryCursorOperation, onOperationQueue: operationQueue)
			}
			else {
				// download finished (with error or not)
				self.queryOperationFinished(error)
			}
		}
		
		// Add the operation to the operation queue to execute it
		operationQueue.addOperation(queryOperation)
	}
	
	
	/**
		Adds the record to an array to save it for later processing.
		This function is called when a new record was fetched from the CloudKit database.
		- parameter record:	The record from the CloudKit database
	*/
	internal func recordFetchedCallback(record: CKRecord) {
		self.allCKRecords.append(record)
		self.updateIndicator?(counter: self.allCKRecords.count)
	}
	
	
	/**
		This function is called when all records have been fetched from the CloudKit database.
		MovieRecord objects are generated and saved.
		- parameter error:	The error object
	*/
	internal func queryOperationFinished(error: NSError?) {
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
}
