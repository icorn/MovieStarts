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
	var loadedDictArray: [NSDictionary]?
	var totalNumberOfRecordsFromCloud: Int?

	var cloudKitContainer: CKContainer
	var cloudKitDatabase: CKDatabase
	
	var completionHandler: ((movies: [MovieRecord]?) -> ())?
	var errorHandler: ((errorMessage: String) -> ())?
	var showIndicator: ((updating: Bool, showProgress: Bool) -> ())?
	var stopIndicator: (() -> ())?
	var updateIndicator: ((progress: Float) -> ())?
	
	var allCKRecords: [CKRecord] = []
	var updatedCKRecords: [CKRecord] = []

	let userDefaults = NSUserDefaults(suiteName: Constants.MOVIESTARTS_GROUP)
	
	
	init(recordType: String) {
		self.recordType = recordType
		var fileUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(Constants.MOVIESTARTS_GROUP)

		if ((fileUrl != nil) && (fileUrl!.path != nil)) {
			self.moviesPlistPath = fileUrl!.path!
		}
		
		self.cloudKitContainer = CKContainer(identifier: Constants.CLOUDKIT_CONTAINER_ID)
		self.cloudKitDatabase = cloudKitContainer.publicCloudDatabase
	}
	
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
			self.loadedDictArray = NSArray(contentsOfFile: moviesPlistFile!) as? [NSDictionary]

			if (self.loadedDictArray != nil) {
				
				// successfully loaded movies from device. Should we search for updated movies?

				var getUpdatesFlag = true
				
/* WIEDER REIN!!
				var latestUpdate: NSDate? = userDefaults?.objectForKey(Constants.PREFS_LATEST_DB_UPDATE_CHECK) as NSDate?
				
				if let saveLatestUpdate: NSDate = latestUpdate {
					var daysSinceLastUpdate = abs(Int(saveLatestUpdate.timeIntervalSinceNow)) / 60 / 60 / 24
					
					if (daysSinceLastUpdate < Constants.DAYS_TILL_DB_UPDATE) {
						getUpdatesFlag = false
					}
				}
*/
				
				if (getUpdatesFlag) {
					// get updates from the cloud
					var latestModDate: NSDate? = userDefaults?.objectForKey(Constants.PREFS_LATEST_DB_MODIFICATION) as NSDate?

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
				
				// first get number of records for nice progress display

				var recordId = CKRecordID(recordName: Constants.RECORD_ID_RESULT_USA)
				
				self.cloudKitDatabase.fetchRecordWithID(recordId, completionHandler: { (record: CKRecord!, error: NSError!) in
					
					if (error != nil) {
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
					self.cloudKitDatabase.addOperation(queryOperation)
				})
			}
		}
		else {
			println("No group folder found")
			errorHandler(errorMessage: "No group folder found")
		}
	}
	

/*
	func setUpSubscription() {
		
		// unused. Called in StartViewController.viewDidAppear()
		
		self.cloudKitDatabase.fetchSubscriptionWithID(Constants.SUBSCRIPTION_ID_USA) { subscription, error in
			if (subscription == nil) {
				// we have no subscription: make it!
				
				let predicate = NSPredicate(value: true)
				let notificationInfo = CKNotificationInfo()
				notificationInfo.shouldSendContentAvailable = true
				
				let subscription = CKSubscription(recordType: Constants.RECORD_TYPE_USA, predicate: predicate, subscriptionID: Constants.SUBSCRIPTION_ID_USA,
				options: CKSubscriptionOptions.FiresOnRecordCreation | CKSubscriptionOptions.FiresOnRecordDeletion | CKSubscriptionOptions.FiresOnRecordUpdate)
				
				subscription.notificationInfo = notificationInfo

				self.cloudKitDatabase.saveSubscription(subscription) { subscription, error in
					if (error != nil) {
						// TODO
						println("Error adding subscriptions: \(error!.code) (\(error!.localizedDescription))")
					}
				}
			}
		}
	}
*/
	
	
	func finishMovies(allMoviesAsDictArray: [NSDictionary], updatedMoviesAsRecordArray: [CKRecord], completionHandler: (movies: [MovieRecord]?) -> (), errorHandler: (errorMessage: String) -> ()) {

		// write it to device
		if ((allMoviesAsDictArray as NSArray).writeToFile(self.moviesPlistFile!, atomically: true) == false) {
			
			if let saveStopIndicator = self.stopIndicator {
				dispatch_async(dispatch_get_main_queue()) {
					saveStopIndicator()
				}
			}
			
			errorHandler(errorMessage: "Error writing movies-file")
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
		
		completionHandler(movies: DatabaseHelper.movieDictsToMovieRecords(allMoviesAsDictArray as NSArray))
	}
	
	
	// MARK: callbacks for getting all movies
	
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
				// received records from the cloud
				// generate an array of dictionaries
				var dictArray: [NSDictionary] = DatabaseHelper.ckrecordsToMovieDicts(self.allCKRecords)
					
				if (dictArray.isEmpty) {
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
					self.finishMovies(dictArray, updatedMoviesAsRecordArray: self.allCKRecords, self.completionHandler!, self.errorHandler!)
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
			self.cloudKitDatabase.addOperation(queryOperation)
		}
	}
	

	// MARK: callbacks for getting updated movies
	
	func recordFetchedUpdatedMoviesCallback(record: CKRecord!) {
		self.updatedCKRecords.append(record)
	}

	func queryCompleteUpdatedMoviesCallback(cursor: CKQueryCursor!, error: NSError!) {
		if (cursor == nil) {
			// all updated records are here!

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
				
				if (self.updatedCKRecords.count > 0) {
					// generate an array of dictionaries
					var updatedDictArray: [NSDictionary] = DatabaseHelper.ckrecordsToMovieDicts(self.updatedCKRecords)
					
					// merge both dict-arrays (the existing movies and the updated movies)
					DatabaseHelper.joinDictArrays(&(self.loadedDictArray!), updatedMovies: updatedDictArray)
				}
				
				// delete all movies which were not updated and don't exist anymore in the cloud

				self.cleanUpExistingMovies(&self.loadedDictArray!)
				
				// finish movies
				if ((self.completionHandler != nil) && (self.errorHandler != nil)) {
					self.finishMovies(self.loadedDictArray!, updatedMoviesAsRecordArray: self.updatedCKRecords, self.completionHandler!, self.errorHandler!)
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
			queryOperation.recordFetchedBlock = recordFetchedUpdatedMoviesCallback
			queryOperation.queryCompletionBlock = queryCompleteUpdatedMoviesCallback
			self.cloudKitDatabase.addOperation(queryOperation)
		}
	}
	
	
	private func cleanUpExistingMovies(inout existingMovies: [NSDictionary]) {
		
		var compareDate = NSDate(timeIntervalSinceNow: 60 * 60 * 24 * -1 * Constants.MAX_DAYS_IN_THE_PAST) // 30 days ago
		var oldNumberOfMovies = existingMovies.count
		
		println("Cleaning up old movies...")
		
		for (var index = existingMovies.count-1; index >= 0; index--) {
			var releaseDate = existingMovies[index].objectForKey(Constants.DB_ID_RELEASE) as? NSDate
			
			if let saveDate = releaseDate {
				if (saveDate.compare(compareDate) == NSComparisonResult.OrderedAscending) {
					// movie is too old
					println("   '\(existingMovies[index].objectForKey(Constants.DB_ID_TITLE))' (\(saveDate)) removed")
					existingMovies.removeAtIndex(index)
				}
			}
		}
		
		println("Clean up over, removed \(oldNumberOfMovies - existingMovies.count) movies from local file. Now we have \(existingMovies.count) movies.")
	}

}

