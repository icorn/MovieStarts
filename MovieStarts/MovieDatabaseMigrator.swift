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


class MovieDatabaseMigrator : MovieDatabaseParent, MovieDatabaseProtocol
{
    static let sharedInstance = MovieDatabaseMigrator()
	
	private init()
    {
        let recordType = Constants.dbRecordTypeMovie
		super.init(recordType: recordType)

		queryKeys =
        [
			// version 1.2
			Constants.dbIdRatingImdb, Constants.dbIdRatingTomato, Constants.dbIdTomatoImage, Constants.dbIdTomatoURL, Constants.dbIdRatingMetacritic,
			
			// version 1.3
			Constants.dbIdBudget, Constants.dbIdBackdrop, Constants.dbIdProfilePictures, Constants.dbIdDirectorPictures, Constants.dbIdHomepageEN, Constants.dbIdTaglineEN, Constants.dbIdCrewWriting
		]
		
		let fileUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.movieStartsGroup)
		
		if let fileUrl = fileUrl {
			moviesPlistPath = fileUrl.path
		}
		else {
			NSLog("Error getting url for app-group.")
			var errorWindow: MessageWindow?
			
			if let viewForError = viewForError {
				DispatchQueue.main.async {
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
	                        updateMovieHandler: @escaping (MovieRecord) -> (),
	                        completionHandler: @escaping ([MovieRecord]?) -> (),
	                        errorHandler: @escaping (String) -> ())
	{
		self.updateMovieHandler = updateMovieHandler
		self.completionHandler  = completionHandler
		self.errorHandler		= errorHandler
		
		self.loadedMovieRecordArray = readDatabaseFromFile()
		
		let minReleaseDate = Date(timeIntervalSinceNow: 60 * 60 * 24 * -1 * Constants.maxDaysInThePast)
		
		NSLog("Getting records for migration after releasedate \(minReleaseDate)")
		
		// get new database fields for current records
		let migrationPredicate = NSPredicate(format: "(%K > %@)", argumentArray: [country.databaseKeyRelease, minReleaseDate])
		let predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [migrationPredicate])
		
		let query = CKQuery(recordType: self.recordType, predicate: predicate)
		let queryOperation = CKQueryOperation(query: query)
		
		let operationQueue = OperationQueue()
		executeQueryOperation(queryOperation: queryOperation, onOperationQueue: operationQueue)
	}
	
	
	/**
		Sends a new CloudKit query to get more records.
		- parameter queryOperation:		The query operation containing the predicates
		- parameter onOperationQueue:	The queue for the query operation
	*/
	internal func executeQueryOperation(queryOperation: CKQueryOperation, onOperationQueue operationQueue: OperationQueue) {
		
		queryOperation.desiredKeys = self.queryKeys
		queryOperation.desiredKeys?.append(Constants.dbIdTmdbId)
		queryOperation.database = cloudKitDatabase
		queryOperation.qualityOfService = QualityOfService.userInitiated
		queryOperation.resultsLimit = 10
		queryOperation.recordFetchedBlock = self.recordFetchedCallback
/*
		queryOperation.recordFetchedBlock = { (record : CKRecord) -> Void in
			self.recordFetchedCallback(record)
		}
*/
		queryOperation.queryCompletionBlock = { (cursor: CKQueryOperation.Cursor?, error: Error?) -> Void in
			if let cursor = cursor {
				// some objects are here, ask for more
				let queryCursorOperation = CKQueryOperation(cursor: cursor)
				self.executeQueryOperation(queryOperation: queryCursorOperation, onOperationQueue: operationQueue)
			}
			else {
				// download finished (with error or not)
				self.queryOperationFinished(error: error)
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
	internal func recordFetchedCallback(record: CKRecord) {
		let prefsCountryString = (UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
		guard let country = MovieCountry(rawValue: prefsCountryString) else {
			NSLog("recordFetchedMigrationMoviesCallback: Corrupt countrycode \(prefsCountryString)")
			return
		}
		
		let newMovieRecord = MovieRecord(country: country)
		newMovieRecord.initWithCKRecord(ckRecord: record)
		
		if let existingMovieRecords = loadedMovieRecordArray {
			for existingMovieRecord in existingMovieRecords {
				if (existingMovieRecord.id == newMovieRecord.id) {
					self.updateMovieHandler?(newMovieRecord)
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
	internal func queryOperationFinished(error: Error?) {
		if let error = error as NSError? {
			// there was an error
			self.errorHandler?("Error querying updated records: \(error.code) (\(error.localizedDescription))")
		}
		else if let existingRecords = self.loadedMovieRecordArray {
			// received records from the cloud
			
			if (updatedCKRecords.count > 0) {
				let prefsCountryString = (UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
				guard let country = MovieCountry(rawValue: prefsCountryString) else {
					NSLog("queryOperationFinishedMigrationMovies: Corrupt countrycode \(prefsCountryString)");
					return
				}
				
				// update the existing movies
				for updateCKRecord in self.updatedCKRecords {
					let updateMovieRecord = MovieRecord(country: country)
					updateMovieRecord.initWithCKRecord(ckRecord: updateCKRecord)

					for existingRecord in existingRecords {
						if (existingRecord.tmdbId == updateMovieRecord.tmdbId) {
							existingRecord.migrate(updateRecord: updateMovieRecord, updateKeys: self.queryKeys)
							break
						}
					}
				}
				
				// save updated movies
				writeMoviesToDevice()
				self.completionHandler?(nil)
			}
            else
            {
                self.completionHandler?(nil)
            }
		}
        else
        {
            self.completionHandler?(nil)
        }
	}
}

