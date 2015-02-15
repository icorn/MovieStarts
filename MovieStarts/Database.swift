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
	
	class func getAllMovies(recordType: String, completionHandler: (movies: [MovieRecord]?) -> (), errorHandler: (errorMessage: String) -> ()) {
		
		// try to load movies from device
		
		let documentsMoviePath = Constants.DOCUMENTS_FOLDER.stringByAppendingPathComponent(recordType + ".plist")
		var loadedDictArray = NSArray(contentsOfFile: documentsMoviePath)

		if let saveLoadedDictArray = loadedDictArray {
			
			// successfully loaded movies from device
			
			completionHandler(movies: Database.movieDictsToMovieRecords(saveLoadedDictArray))
			
			// TODO:
/*
			// checking for updates
			var latestModDate: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey(Constants.PREFS_LATEST_DB_MODIFICATION)
			
			if let saveModDate: AnyObject = latestModDate {
				var predicate = NSPredicate(format: "modificationDate > %@", argumentArray: [saveModDate])
				var query = CKQuery(recordType: Constants.RECORD_TYPE_USA, predicate: predicate)
				
				saveDatabase.performQuery(query, inZoneWithID: nil,
					completionHandler: { (dataArray: [AnyObject]!, error: NSError!) in
						var bla = 42
					}
				)
			}
*/
		}
		else {
			
			// movies are not on the device: get them from the cloud
			
			var cloudKitContainer = CKContainer.init(identifier: Constants.CLOUDKIT_CONTAINER_ID)
			var cloudKitDatabase = cloudKitContainer?.publicCloudDatabase
			
			if let saveDatabase = cloudKitDatabase {
				let predicate = NSPredicate(value: true)
				let query = CKQuery(recordType: Constants.RECORD_TYPE_USA, predicate: predicate)
				
				saveDatabase.performQuery(query, inZoneWithID: nil,
					completionHandler: { (dataArray: [AnyObject]!, error: NSError!) in
						
						if (error != nil) {
							errorHandler(errorMessage: "Error querying records: \(error!.code) (\(error!.localizedDescription))")
							return
						}
						else {
							// received records from the cloud
							
							var allCKRecords = dataArray as? [CKRecord]
							
							if let saveAllCKRecords = allCKRecords {
								
								// generate an array of dictionaries
								
								var dictArray: [NSDictionary] = []
								
								for record in saveAllCKRecords {
									var asset: CKAsset? = (record as CKRecord).objectForKey(Constants.DB_ID_ASSET) as? CKAsset
									var urlString: String? = asset?.fileURL.absoluteString
									
									if let saveUrlString = urlString {
										var url: NSURL? = NSURL(string: saveUrlString)
											
										if let saveUrl = url {
											var dict = NSDictionary(contentsOfURL: saveUrl)
											
											if let saveDict = dict {
												dictArray.append(saveDict)
											}
										}
									}
								}
								
								if (dictArray.isEmpty) {
									errorHandler(errorMessage: "Error reading assets")
									return
								}
								
								// write it to device
								
								if ((dictArray as NSArray).writeToFile(documentsMoviePath, atomically: true) == false) {
									errorHandler(errorMessage: "Error writing movies-file")
									return
								}

								// convert array of dictionaries to array of MovieRecord objects
								
								var movieRecordArray = Database.movieDictsToMovieRecords(dictArray as NSArray)
								
								// and store the latest modification-date of the records
								
								var latestModification = NSDate(timeIntervalSince1970: 0)
								
								for movie in saveAllCKRecords {
									if (latestModification.compare(movie.modificationDate) == NSComparisonResult.OrderedAscending) {
										latestModification = movie.modificationDate
									}
								}
								
								NSUserDefaults.standardUserDefaults().setObject(latestModification, forKey: Constants.PREFS_LATEST_DB_MODIFICATION)
								NSUserDefaults.standardUserDefaults().synchronize()

								// success
								completionHandler(movies: movieRecordArray)
							}
							else {
								errorHandler(errorMessage: "Database records are nil")
								return
							}
						}
					}
				);
			}
		}
	}
	
	
	class func movieDictsToMovieRecords(dictArray: NSArray) -> [MovieRecord] {
		var movieRecordArray: [MovieRecord] = []
		
		for dict in dictArray {
			movieRecordArray.append(MovieRecord(dict: dict as [String : AnyObject]))
		}
	
		return movieRecordArray
	}
}

