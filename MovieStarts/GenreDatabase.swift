//
//  File.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 30.11.15.
//  Copyright © 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation
import CloudKit

class GenreDatabase : DatabaseParent {

	var genresPlistFile: String = ""
	var allCKRecords: [CKRecord] = []

	var errorHandler: ((String) -> ())?
	var finishHandler: (([Int : [String]]) -> ())?

	
	init(finishHandler: (([Int : [String]]) -> ())?, errorHandler: ((String) -> ())?) {
		self.finishHandler = finishHandler
		self.errorHandler = errorHandler
		
		super.init(recordType: Constants.dbRecordTypeGenre)

		let fileUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.movieStartsGroup)
		var genresPlistPath = ""
		
		if let fileUrl = fileUrl {
			genresPlistPath = fileUrl.path
		}
		else {
			NSLog("Error getting url for app-group.")
		}
		
		if genresPlistPath.hasSuffix("/") {
			genresPlistFile = genresPlistPath + recordType + ".plist"
		}
		else {
			genresPlistFile = genresPlistPath + "/" + recordType + ".plist"
		}
	}

	
	/**
		Loads the genres from file.
	
		- returns: A dictionary with genreIds and genreNames for the current language
	*/
	func readGenresFromFile() -> [Int: String] {
		
		var genreDict: [Int: String] = [:]

		let prefsCountryString = (UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
		
		if let country = MovieCountry(rawValue: prefsCountryString) {
			if let loadedDict = NSDictionary(contentsOfFile: genresPlistFile) as? [String: [String]] {
				// successfully loaded movies from device
			
				for (genreIdString, genreNames) in loadedDict {
					if let genreId = Int(genreIdString) {
						genreDict[genreId] = genreNames[country.languageArrayIndex]
					}
				}
			}
		}
		
		return genreDict
	}
	

	/**
		Initiates the reading of all genres from CloudKit and writes it to a file later.
	*/
	func readGenresFromCloud() {
		
		// get all movies which started a month ago or later
		let predicate = NSPredicate(value: true)
		let query = CKQuery(recordType: self.recordType, predicate: predicate)
		let queryOperation = CKQueryOperation(query: query)
		let operationQueue = OperationQueue()
		
		executeQueryOperation(queryOperation, onOperationQueue: operationQueue)
	}

	/**
		Sends a new CloudKit query to get all records.
	
		- parameter queryOperation:		The query operation containing the predicates
		- parameter onOperationQueue:	The queue for the query operation
	*/
	fileprivate func executeQueryOperation(_ queryOperation: CKQueryOperation, onOperationQueue operationQueue: OperationQueue) {
		queryOperation.database = cloudKitDatabase
		queryOperation.qualityOfService = QualityOfService.userInitiated
		
		queryOperation.recordFetchedBlock = { (record : CKRecord) -> Void in
			self.allCKRecords.append(record)
		}
		
		queryOperation.queryCompletionBlock = { (cursor: CKQueryCursor?, error: Error?) -> Void in
			if let cursor = cursor {
				// some objects are here, ask for more
				let queryCursorOperation = CKQueryOperation(cursor: cursor)
				self.executeQueryOperation(queryCursorOperation, onOperationQueue: operationQueue)
			}
			else {
				// download finished (with error or not)
				self.queryOperationFinished(error: error as NSError?)
			}
		}
		
		// Add the operation to the operation queue to execute it
		operationQueue.addOperation(queryOperation)
	}
	
	
	/**
		This function is called when all records have been fetched from the CloudKit database.
	
		- parameter error:	The error object
	*/
	fileprivate func queryOperationFinished(error: NSError?) {
		if let error = error {
			let msg = "Error querying records: Code=\(error.code) Domain=\(error.domain) Error: (\(error.localizedDescription))"
			NSLog(msg)
			allCKRecords = []
			errorHandler?(msg)
			return
		}
		else {
			// received all records from the cloud

			// a dictionary can only be writte to a file if the key is a string.
			var genreDictToWrite: [String: [String]] = [:]
			var genreDictToReturn: [Int: [String]] = [:]
			
			for ckRecord in self.allCKRecords {
				if let genreId = ckRecord.object(forKey: Constants.dbIdGenreId) as? Int, let genreNames = ckRecord.object(forKey: Constants.dbIdGenreNames) as? [String] {
					genreDictToWrite[String(genreId)] = genreNames
					genreDictToReturn[genreId] = genreNames
				}
			}

			// write dictionary to file

			if ((genreDictToWrite as NSDictionary).write(toFile: genresPlistFile, atomically: true) == false) {
				let msg = "Error writing genre dictionary to file."
				NSLog(msg)
				errorHandler?(msg)
				return
			}

			finishHandler?(genreDictToReturn)
		}
	}
	
}

