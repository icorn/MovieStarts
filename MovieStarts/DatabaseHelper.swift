//
//  DatabaseHelper.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 21.02.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation
import CloudKit


class DatabaseHelper {
	
   /**
	* Converts an NSArray of NSDictionaries to an arry of MovieRecords objects.
	*/
	class func movieDictsToMovieRecords(dictArray: NSArray) -> [MovieRecord] {
		var movieRecordArray: [MovieRecord] = []
		
		for dict in dictArray {
			movieRecordArray.append(MovieRecord(dict: dict as [String : AnyObject]))
		}
		
		return movieRecordArray
	}
	
	
   /**
	* Converts an array of CKRecords to an array of NSDictionaries.
	*/
	class func ckrecordsToMovieDicts(ckrecords: [CKRecord]) -> [NSDictionary] {
		var retval: [NSDictionary] = []
		
		for record in ckrecords {
			var asset: CKAsset? = (record as CKRecord).objectForKey(Constants.DB_ID_ASSET) as? CKAsset
			var urlString: String? = asset?.fileURL.absoluteString
			
			if let saveUrlString = urlString {
				var url: NSURL? = NSURL(string: saveUrlString)
				
				if let saveUrl = url {
					var dict = NSDictionary(contentsOfURL: saveUrl)
					
					if let saveDict = dict {
						retval.append(saveDict)
					}
				}
			}
		}
		
		return retval
	}
	
	
   /**
	* Stores the date of the last modified CKRecord in the UserDefaults.
	*/
	class func storeLastModification(ckrecords: [CKRecord]) {
		var latestModification = NSDate(timeIntervalSince1970: 0)
		
		for movie in ckrecords {
			if (latestModification.compare(movie.modificationDate) == NSComparisonResult.OrderedAscending) {
				latestModification = movie.modificationDate
			}
		}
		
		NSUserDefaults.standardUserDefaults().setObject(latestModification, forKey: Constants.PREFS_LATEST_DB_MODIFICATION)
		NSUserDefaults.standardUserDefaults().synchronize()
	}
	
	
   /**
	* Joins the both arrays of NSDictionary with existing and updated movies.
	*/
	class func joinDictArrays(inout existingMovies: [NSDictionary], updatedMovies: [NSDictionary]) {
		
		for updatedMovie in updatedMovies {
			var movieIndex = DatabaseHelper.findArrayIndexOfMovie(updatedMovie, array: existingMovies)
			
			if (movieIndex == nil) {
				// add new movie
				existingMovies.append(updatedMovie)
			}
			else {
				// update existing movie
				existingMovies[movieIndex!] = updatedMovie
			}
		}
	}
	
	
   /**
	* Searches for a movie in an array of movie dictionaries. The index or null is returned.
	*/
	class func findArrayIndexOfMovie(updatedMovie: NSDictionary, array: [NSDictionary]) -> Int? {
		var foundIndex: Int?
		
		if let updatedMovieId = updatedMovie.objectForKey(Constants.DB_ID_TMDB_ID) as? Int {
			var index = 0
			
			for movie in array {
				
				if let existingMovieId = movie.objectForKey(Constants.DB_ID_TMDB_ID) as? Int {
					if (existingMovieId == updatedMovieId) {
						foundIndex = index
						break
					}
				}
				
				index++
			}
		}
		
		return foundIndex
	}
	
	
}