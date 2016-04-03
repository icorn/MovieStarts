//
//  MovieMigrationDatabase.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 27.03.16.
//  Copyright © 2016 Oliver Eichhorn. All rights reserved.
//

import Foundation
import CloudKit
import UIKit


class MovieMigrationDatabase : DatabaseParent {

	var moviesPlistPath: String?
	var moviesPlistFile: String?
	var loadedMovieRecordArray: [MovieRecord]?
	var viewForError: UIView?

	var completionHandler: ((movies: [MovieRecord]?) -> ())?
	var errorHandler: ((errorMessage: String) -> ())?
	var updateMovieHandler: ((movie: MovieRecord) -> ())?
	var stopIndicator: (() -> ())?
	var finishHandler: (() -> ())?

	var updatedCKRecords: [CKRecord] = []

	let queryKeys = [Constants.dbIdRatingImdb, Constants.dbIdRatingTomato, Constants.dbIdTomatoImage, Constants.dbIdTomatoURL, Constants.dbIdRatingMetacritic]

	
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
		Update records after software update with new database fields.
	*/
	func getMigrationMovies(country: MovieCountry,
	                        updateMovieHandler: (movie: MovieRecord) -> (),
	                        completionHandler: (movies: [MovieRecord]?) -> (),
	                        errorHandler: (errorMessage: String) -> ())
	{
		self.updateMovieHandler = updateMovieHandler
		self.completionHandler  = completionHandler
		self.errorHandler		= errorHandler
		
		self.loadedMovieRecordArray = readDatabaseFromFile()
		
		let minReleaseDate = NSDate(timeIntervalSinceNow: 60 * 60 * 24 * -1 * Constants.maxDaysInThePast)
		
		NSLog("Getting records for migration after releasedate \(minReleaseDate)")
		
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		
		// get new database fields for current records
		let migrationPredicate = NSPredicate(format: "(%K > %@)", argumentArray: [country.databaseKeyRelease, minReleaseDate])
		let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [migrationPredicate])
		
		let query = CKQuery(recordType: self.recordType, predicate: predicate)
		let queryOperation = CKQueryOperation(query: query)
		
		let operationQueue = NSOperationQueue()
		executeQueryOperationMigrationMovies(queryOperation, onOperationQueue: operationQueue)
	}
	
	
	/**
		Sends a new CloudKit query to get more records.
	
		- parameter queryOperation:		The query operation containing the predicates
		- parameter onOperationQueue:	The queue for the query operation
	*/
	func executeQueryOperationMigrationMovies(queryOperation: CKQueryOperation, onOperationQueue operationQueue: NSOperationQueue) {
		
		queryOperation.desiredKeys = self.queryKeys
		queryOperation.desiredKeys?.append(Constants.dbIdTmdbId)
		queryOperation.database = cloudKitDatabase
		queryOperation.qualityOfService = NSQualityOfService.UserInitiated
		queryOperation.resultsLimit = 10
		
		queryOperation.recordFetchedBlock = { (record : CKRecord) -> Void in
			self.recordFetchedMigrationMoviesCallback(record)
		}
		
		queryOperation.queryCompletionBlock = { (cursor: CKQueryCursor?, error: NSError?) -> Void in
			if let cursor = cursor {
				// some objects are here, ask for more
				let queryCursorOperation = CKQueryOperation(cursor: cursor)
				self.executeQueryOperationMigrationMovies(queryCursorOperation, onOperationQueue: operationQueue)
			}
			else {
				// download finished (with error or not)
				self.queryOperationFinishedMigrationMovies(error)
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
	func recordFetchedMigrationMoviesCallback(record: CKRecord) {
		
		let prefsCountryString = (NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
		guard let country = MovieCountry(rawValue: prefsCountryString) else { NSLog("recordFetchedMigrationMoviesCallback: Corrupt countrycode \(prefsCountryString)"); return }
		
		let newMovieRecord = MovieRecord(country: country)
		newMovieRecord.initWithCKRecord(record)
		
		if let existingMovieRecords = loadedMovieRecordArray {
			for existingMovieRecord in existingMovieRecords {
				if (existingMovieRecord.id == newMovieRecord.id) {
					self.updateMovieHandler?(movie: newMovieRecord)
					updatedCKRecords.append(record)
					break
				}
			}
		}
	}
	
	
	/**
		This function is called when all updated records have been fetched from the CloudKit database.
		MovieRecord objects are generated and save.
	
		- parameter error:	The error object
	*/
	func queryOperationFinishedMigrationMovies(error: NSError?) {
		if let error = error {
			// there was an error
			self.errorHandler?(errorMessage: "Error querying updated records: \(error.code) (\(error.description))")
			return
		}
		else if let existingRecords = self.loadedMovieRecordArray {
			// received records from the cloud
			
			if (updatedCKRecords.count > 0) {
				let prefsCountryString = (NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
				guard let country = MovieCountry(rawValue: prefsCountryString) else {
					NSLog("queryOperationFinishedMigrationMovies: Corrupt countrycode \(prefsCountryString)");
					return
				}
				
				// update the existing movies
				for updateCKRecord in self.updatedCKRecords {
					let updateMovieRecord = MovieRecord(country: country)
					updateMovieRecord.initWithCKRecord(updateCKRecord)

					for existingRecord in existingRecords {
						if (existingRecord.tmdbId == updateMovieRecord.tmdbId) {
							existingRecord.migrate(updateMovieRecord, updateKeys: self.queryKeys)
							break
						}
					}
				}
				
				// save updated movies
				writeMoviesToDevice()
				self.completionHandler?(movies: nil)
			}
		}
	}
	
	
	// from MovieDatabase.swift
	
	
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
		Writes the movies and the modification date to file.

		- parameter allMovieRecords:			The array with all movies. This will be written to file.
		- parameter updatedMoviesAsRecordArray:	The array with all updated movies (used to find out latest modification date)
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

}
