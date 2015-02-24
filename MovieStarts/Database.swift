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


class Database {
	
	var recordType: String
	var documentsMoviePath: String
	var loadedDictArray: [NSDictionary]?
	var parentView: UIView?
	
//	var activityIndicator: UIActivityIndicatorView?
	var activityView: UIView?
	
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
	
	func getAllMovies(parentView: UIView, completionHandler: (movies: [MovieRecord]?) -> (), errorHandler: (errorMessage: String) -> ()) {
		
		self.completionHandler = completionHandler
		self.errorHandler = errorHandler
		self.parentView = parentView
		
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
					
					self.startActivityIndicator(title: "Updating movies...")
					
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

			self.startActivityIndicator(title: "Loading movies...")
			
			let predicate = NSPredicate(value: true)
			let query = CKQuery(recordType: self.recordType, predicate: predicate)
			let queryOperation = CKQueryOperation(query: query)
				
			queryOperation.recordFetchedBlock = recordFetchedAllMoviesCallback
			queryOperation.queryCompletionBlock = queryCompleteAllMoviesCallback
			self.cloudKitDatabase.addOperation(queryOperation)
		}
	}
	
	func startActivityIndicator(title: String? = nil) {
		if let saveParentView = self.parentView {
			
			if (title != nil) {
				var labelWidth = (title! as NSString).sizeWithAttributes([NSFontAttributeName : UIFont.systemFontOfSize(16)]).width
				var viewWidth = labelWidth + 20
				
				self.activityView = UIView(frame:
					CGRect(x: saveParentView.frame.width / 2 - viewWidth / 2, y: saveParentView.frame.height / 2 - 50, width: viewWidth, height: 100))
				self.activityView?.layer.cornerRadius = 15
				self.activityView?.backgroundColor = UIColor.blackColor()
				var spinner = UIActivityIndicatorView(frame: CGRect(x: viewWidth/2 - 20, y: 20, width: 40, height: 40))
				spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
				spinner.startAnimating()
				var msg = UILabel(frame: CGRect(x: 10, y: 75, width: labelWidth, height: 20))
				msg.text = title
				msg.font = UIFont.systemFontOfSize(14)
				msg.textAlignment = NSTextAlignment.Center
				msg.textColor = UIColor.whiteColor()
				msg.backgroundColor = UIColor.clearColor()
				self.activityView?.opaque = false
				self.activityView?.backgroundColor = UIColor.blackColor()
				self.activityView?.addSubview(spinner)
				self.activityView?.addSubview(msg)
				saveParentView.addSubview(activityView!)
			}
			else {
				var viewWidth: CGFloat = 80.0
				self.activityView = UIView(frame: CGRect(x: saveParentView.frame.width/2 - viewWidth/2, y: saveParentView.frame.height/2 - 20, width: viewWidth, height: viewWidth))
				self.activityView?.layer.cornerRadius = 15
				self.activityView?.backgroundColor = UIColor.blackColor()
				var spinner = UIActivityIndicatorView(frame: CGRect(x: viewWidth/2 - 20, y: 20, width: 40, height: 40))
				spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
				spinner.startAnimating()
				self.activityView?.opaque = false
				self.activityView?.backgroundColor = UIColor.blackColor()
				self.activityView?.addSubview(spinner)
				saveParentView.addSubview(activityView!)
			}
		}
	}

	func stopActivityIndicator() {
		self.activityView?.removeFromSuperview()
		self.activityView = nil
	}

	
	func finishMovies(dictArray: [NSDictionary], ckrecordArray: [CKRecord], documentsMoviePath: String,
		completionHandler: (movies: [MovieRecord]?) -> (), errorHandler: (errorMessage: String) -> ()) {
			
			// write it to device
			if ((dictArray as NSArray).writeToFile(documentsMoviePath, atomically: true) == false) {
				self.stopActivityIndicator()
				errorHandler(errorMessage: "Error writing movies-file")
				return
			}
			
			// and store the latest modification-date of the records
			DatabaseHelper.storeLastModification(ckrecordArray)
			
			// success
			self.stopActivityIndicator()
			completionHandler(movies: DatabaseHelper.movieDictsToMovieRecords(dictArray as NSArray))
	}
	
	
	// MARK: callbacks for getting all movies
	
	func recordFetchedAllMoviesCallback(record: CKRecord!) {
		self.allCKRecords.append(record)
	}
	
	func queryCompleteAllMoviesCallback(cursor: CKQueryCursor!, error: NSError!) {
		if (cursor == nil) {
			// all objects are here!

			if (error != nil) {
				stopActivityIndicator()
				
				// TODO: Error-Code 1 heißt u. a., dass der User nicht in iCloud eingeloggt ist
				
				self.errorHandler?(errorMessage: "Error querying records: \(error!.code) (\(error!.localizedDescription))")
				return
			}
			else {
				// received records from the cloud
				// generate an array of dictionaries
				var dictArray: [NSDictionary] = DatabaseHelper.ckrecordsToMovieDicts(self.allCKRecords)
					
				if (dictArray.isEmpty) {
					stopActivityIndicator()
					self.errorHandler?(errorMessage: "Error reading assets")
					return
				}
				
				NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: Constants.PREFS_LATEST_DB_UPDATE_CHECK)
				NSUserDefaults.standardUserDefaults().synchronize()
				
				// finish movies
				if ((self.completionHandler != nil) && (self.errorHandler != nil)) {
					self.finishMovies(dictArray, ckrecordArray: self.allCKRecords,
						documentsMoviePath: self.documentsMoviePath, self.completionHandler!, self.errorHandler!)
				}
				else {
					stopActivityIndicator()
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
				self.stopActivityIndicator()
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
						self.finishMovies(self.loadedDictArray!, ckrecordArray: self.updatedCKRecords,
							documentsMoviePath: self.documentsMoviePath, self.completionHandler!, self.errorHandler!)
					}
					else {
						self.stopActivityIndicator()
						self.errorHandler?(errorMessage: "One of the handlers is nil!")
						return
					}
				}
				else {
					// no updated movies
					self.stopActivityIndicator()
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

