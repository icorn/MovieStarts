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
	var documentsMoviePath: String
	var loadedDictArray: [NSDictionary]?
	
	var cloudKitContainer: CKContainer
	var cloudKitDatabase: CKDatabase
	
	var completionHandler: ((movies: [MovieRecord]?) -> ())?
	var errorHandler: ((errorMessage: String) -> ())?
	
	var allCKRecords: [CKRecord] = []
	var updatedCKRecords: [CKRecord] = []

	
	init(recordType: String) {
		self.recordType = recordType
		self.documentsMoviePath = Constants.DOCUMENTS_FOLDER.stringByAppendingPathComponent(recordType + ".plist")
		self.cloudKitContainer = CKContainer(identifier: Constants.CLOUDKIT_CONTAINER_ID)
		self.cloudKitDatabase = cloudKitContainer.publicCloudDatabase
	}
	
	func getAllMovies(completionHandler: (movies: [MovieRecord]?) -> (), errorHandler: (errorMessage: String) -> ()) {
		
		self.completionHandler = completionHandler
		self.errorHandler = errorHandler
		
		// try to load movies from device
		
		self.loadedDictArray = NSArray(contentsOfFile: documentsMoviePath) as? [NSDictionary]

		if (self.loadedDictArray != nil) {
			
			// successfully loaded movies from device. Should we search for updated movies?

			var getUpdatesFlag = true
			var latestUpdate: NSDate? = NSUserDefaults.standardUserDefaults().objectForKey(Constants.PREFS_LATEST_DB_UPDATE_CHECK) as NSDate?
			
			if let saveLatestUpdate: NSDate = latestUpdate {
				var daysSinceLastUpdate = abs(Int(saveLatestUpdate.timeIntervalSinceNow)) / 60 / 60 / 24
				
				if (daysSinceLastUpdate < Constants.DAYS_TILL_DB_UPDATE) {
					getUpdatesFlag = false
				}
			}
			
			if (getUpdatesFlag) {
				// get updates from the cloud
				var latestModDate: NSDate? = NSUserDefaults.standardUserDefaults().objectForKey(Constants.PREFS_LATEST_DB_MODIFICATION) as NSDate?

				if let saveModDate: NSDate = latestModDate {

					println("Getting records after modification date \(saveModDate)")
					
					var predicate = NSPredicate(format: "modificationDate > %@", argumentArray: [saveModDate])
					var query = CKQuery(recordType: self.recordType, predicate: predicate)
					let queryOperation = CKQueryOperation(query: query)
					
					queryOperation.recordFetchedBlock = recordFetchedUpdatedMoviesCallback
					queryOperation.queryCompletionBlock = queryCompleteUpdatedMoviesCallback
					self.cloudKitDatabase.addOperation(queryOperation)
				}
			}
			else {
				// no updates wanted, just return the stuff from the file
				completionHandler(movies: DatabaseHelper.movieDictsToMovieRecords(loadedDictArray!))
			}
		}
		else {
			// movies are not on the device: get them from the cloud
			
			let predicate = NSPredicate(value: true)
			let query = CKQuery(recordType: self.recordType, predicate: predicate)
			let queryOperation = CKQueryOperation(query: query)
				
			queryOperation.recordFetchedBlock = recordFetchedAllMoviesCallback
			queryOperation.queryCompletionBlock = queryCompleteAllMoviesCallback
			self.cloudKitDatabase.addOperation(queryOperation)
		}
	}
	
	// MARK: callbacks for getting all movies
	
	func recordFetchedAllMoviesCallback(record: CKRecord!) {
		self.allCKRecords.append(record)
	}
	
	func queryCompleteAllMoviesCallback(cursor: CKQueryCursor!, error: NSError!) {
		if (cursor == nil) {
			// all objects are here!

			if (error != nil) {
				self.errorHandler?(errorMessage: "Error querying records: \(error!.code) (\(error!.localizedDescription))")
				return
			}
			else {
				// received records from the cloud
				// generate an array of dictionaries
				var dictArray: [NSDictionary] = DatabaseHelper.ckrecordsToMovieDicts(self.allCKRecords)
					
				if (dictArray.isEmpty) {
					self.errorHandler?(errorMessage: "Error reading assets")
					return
				}
				
				NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: Constants.PREFS_LATEST_DB_UPDATE_CHECK)
				NSUserDefaults.standardUserDefaults().synchronize()
				
				// finish movies
				if ((self.completionHandler != nil) && (self.errorHandler != nil)) {
					DatabaseHelper.finishMovies(dictArray, ckrecordArray: self.allCKRecords,
						documentsMoviePath: self.documentsMoviePath, self.completionHandler!, self.errorHandler!)
				}
				else {
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
			self.cloudKitDatabase.addOperation(queryOperation)
		}
	}
	

	// MARK: callbacks for getting updated movies
	
	func recordFetchedUpdatedMoviesCallback(record: CKRecord!) {
		self.updatedCKRecords.append(record)
	}

	func queryCompleteUpdatedMoviesCallback(cursor: CKQueryCursor!, error: NSError!) {
		if (cursor == nil) {
			// all objects are here!

			if (error != nil) {
				self.errorHandler?(errorMessage: "Error querying updated records: \(error!.code) (\(error!.localizedDescription))")
				return
			}
			else {
				// received records from the cloud
				
				NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: Constants.PREFS_LATEST_DB_UPDATE_CHECK)
				NSUserDefaults.standardUserDefaults().synchronize()
				
				if (self.updatedCKRecords.count > 0) {
					// generate an array of dictionaries
					var updatedDictArray: [NSDictionary] = DatabaseHelper.ckrecordsToMovieDicts(self.updatedCKRecords)
					
					// merge both dict-arrays (the existing movies and the updated movies)
					DatabaseHelper.joinDictArrays(&(self.loadedDictArray!), updatedMovies: updatedDictArray)
					
					// finish movies
					if ((self.completionHandler != nil) && (self.errorHandler != nil)) {
						DatabaseHelper.finishMovies(self.loadedDictArray!, ckrecordArray: self.updatedCKRecords,
							documentsMoviePath: self.documentsMoviePath, self.completionHandler!, self.errorHandler!)
					}
					else {
						self.errorHandler?(errorMessage: "One of the handlers is nil!")
						return
					}
				}
				else {
					// no updated movies
					if let saveCompletionHandler = self.completionHandler {
						saveCompletionHandler(movies: DatabaseHelper.movieDictsToMovieRecords(self.loadedDictArray!))
					}
				}
			}
		}
		else {
			// some objects are here, ask for more
			let queryOperation = CKQueryOperation(cursor: cursor)
			queryOperation.recordFetchedBlock = recordFetchedUpdatedMoviesCallback
			queryOperation.queryCompletionBlock = queryCompleteUpdatedMoviesCallback
			self.cloudKitDatabase.addOperation(queryOperation)
		}
	}
}

