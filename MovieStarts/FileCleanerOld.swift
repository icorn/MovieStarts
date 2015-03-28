//
//  FileCleanerOld.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 08.03.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation
import CloudKit


// cleans the local movies file of movies which are no longer in the cloud

class FileCleanerOld {
	
	var recordType: String
	var cloudKitDatabase: CKDatabase
	var movieIDsToDelete: [String] = []
	var completionCallback: (() -> ())?
	
	
	init (recordType: String, database: CKDatabase) {
		self.recordType = recordType
		self.cloudKitDatabase = database
	}
	
	func start(updatedMovies: [NSDictionary], allLocalMovies: [NSDictionary], completionCallback: () -> ()) {
		self.completionCallback = completionCallback
		self.getMoviesToDeleteFromCloud(updatedMovies, allLocalMovies: allLocalMovies)
	}
	
	
   /**
	* Checks if in the list of existing movies there are movies which are deleted in the cloud.
	* Just updated movies are excluded from deletion (they *are* in the cloud).
	*/
	
	func getMoviesToDeleteFromCloud(updatedMovies: [NSDictionary], allLocalMovies: [NSDictionary]) {
		
		// generate an array of movieIDs which were just updated and cannot be deleted
		
		println("FileCleaner: \(updatedMovies.count) updated movies, \(allLocalMovies.count) total movies")

		var movieIDsToIgnore: [Int] = []
		
		for movie in updatedMovies {
			var tmdbId = movie.objectForKey(Constants.DB_ID_TMDB_ID) as Int?
			
			if let saveTmdbId = tmdbId {
				movieIDsToIgnore.append(saveTmdbId)
			}
		}
		
		// fill two arrays:
		// - movieIDsToCheck: an array of movieIDs from local movies which we check if they still exist in the cloud.
		// - movieIDsToDelete: gets the same IDs than the other array, but existing IDs will be removed later in recordFetchedCallback
		
		var movieIDsToCheck: [CKReference] = []
		
		for localMovie in allLocalMovies {
			var tmdbId = localMovie.objectForKey(Constants.DB_ID_TMDB_ID) as Int?
			var ignore = false
			
			if let saveTmdbId = tmdbId {
				for ignoreId in movieIDsToIgnore {
					if (saveTmdbId == ignoreId) {
						ignore = true
					}
				}

				if (!ignore) {
					movieIDsToCheck.append(CKReference(recordID: CKRecordID(recordName: String(saveTmdbId)), action: CKReferenceAction.None))
					movieIDsToDelete.append(String(saveTmdbId))
				}
			}
		}

		// get all movies from the cloud which are not in the ignore-list
		
		println("FileCleaner: Checking \(movieIDsToCheck.count) movies if they still exist in the cloud")
		
		var predicate = NSPredicate(format: "recordID IN %@", argumentArray: [movieIDsToCheck])
		var query = CKQuery(recordType: self.recordType, predicate: predicate)
		let queryOperation = CKQueryOperation(query: query)

		queryOperation.recordFetchedBlock = recordFetchedCallback
		queryOperation.queryCompletionBlock = queryCompleteCallback
		self.cloudKitDatabase.addOperation(queryOperation)
	}
	
	func recordFetchedCallback(record: CKRecord!) {
		
		// the record was returned from the query: that means, it exists, and we can removed it from the delete-array
		
		for (index, movieID) in enumerate(self.movieIDsToDelete) {
			if (movieID == record.recordID.recordName) {
				self.movieIDsToDelete.removeAtIndex(index)
				println("FileCleaner: Removing movie \(movieID) from delete-list (which now has \(self.movieIDsToDelete.count) movies on it).")
				break
			}
		}
	}
	
	func queryCompleteCallback(cursor: CKQueryCursor!, error: NSError!) {
		if (error != nil) {
			println("FileCleaner: error \(error!.code) (\(error!.localizedDescription))")
		}
		else if (cursor == nil) {
			// all updated records are here, let's call the callback (which later calls "cleanUpExistingMovies")
			if let saveCallback = self.completionCallback {
				saveCallback()
			}
		}
		else {
			// some objects are here, ask for more
			let queryOperation = CKQueryOperation(cursor: cursor)
			queryOperation.recordFetchedBlock = recordFetchedCallback
			queryOperation.queryCompletionBlock = queryCompleteCallback
			self.cloudKitDatabase.addOperation(queryOperation)
		}
	}

	
	func cleanUpExistingMovies(inout existingMovies: [NSDictionary]) {
		
		println("FileCleaner: Deleting \(self.movieIDsToDelete.count) movies from local array.")
		
		for deleteId in self.movieIDsToDelete {
			for (index, existingMovie) in enumerate(existingMovies) {
				var tmdbIdExisting = existingMovie.objectForKey(Constants.DB_ID_TMDB_ID) as Int?
				
				if let saveTmdbIdExisting = tmdbIdExisting {
					if (String(saveTmdbIdExisting) == deleteId) {
						existingMovies.removeAtIndex(index)
						break
					}
				}
			}
		}

		println("FileCleaner: Now there are \(existingMovies.count) movies left.")
	}
	
}

