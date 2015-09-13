//
//  DatabaseHelper.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 21.02.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation
import CloudKit


public class DatabaseHelper {
	
   /**
		Converts an array of MovieRecord objects to an array of NSDictionaries.
	
		:param: movieRecords	The input array of MovieRecord objects
	
		:returns: An array of NSDictionarys which contain the data of the input parameter movieRecords.
	*/
	public class func movieRecordArrayToDictArray(movieRecords: [MovieRecord]) -> [NSDictionary] {
		var retval: [NSDictionary] = []
	
		for record in movieRecords {
			retval.append(record.toDictionary())
		}
	
		return retval
	}
	
	
   /**
		Converts an array of NSDictionarys to an array of MovieRecord objects.
	
		:param: dictArray	The input array of NSDictionarys
	
		:returns: An array of MovieRecord objects, generated of the input parameter dictArray.
	*/
	public class func dictArrayToMovieRecordArray(dictArray: [NSDictionary]) -> [MovieRecord] {
		var retval: [MovieRecord] = []
		
		for dict in dictArray {
			if let dict = (dict as? [String : AnyObject]) {
				retval.append(MovieRecord(dict: dict))
			}
			else {
				NSLog("Error converting dictionary")
			}
		}
		
		return retval
	}
	
	
   /**
		Stores the date of the last modified CKRecord in the UserDefaults.
	
		:param: ckrecords	The new or updated CKRecords from the CloudKit database
	*/
	class func storeLastModification(ckrecords: [CKRecord]) {
		var latestModification = NSDate(timeIntervalSince1970: 0)
		
		for movie in ckrecords {
			if (latestModification.compare(movie.modificationDate) == NSComparisonResult.OrderedAscending) {
				latestModification = movie.modificationDate
			}
		}
		
		NSUserDefaults(suiteName: Constants.MOVIESTARTS_GROUP)?.setObject(latestModification, forKey: Constants.PREFS_LATEST_DB_MODIFICATION)
		NSUserDefaults(suiteName: Constants.MOVIESTARTS_GROUP)?.synchronize()
	}
	
	
   /**
		Joins the both arrays of MovieRecord with existing and updated movies.
	
		:param: existingMovies	The array with the existing movies
		:param: updatedMovies	The array with the updated movies
	*/
	public class func joinMovieRecordArrays(inout existingMovies: [MovieRecord], updatedMovies: [MovieRecord]) {
		
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
		Searches for a movie in an array of movie records. The index or null is returned.
	
		:param: updatedMovie	The movie record to search for
		:param: array			The array to be searched
	*/
	public class func findArrayIndexOfMovie(updatedMovie: MovieRecord, array: [MovieRecord]) -> Int? {
		var foundIndex: Int?
		
		if let updatedMovieId = updatedMovie.tmdbId {
			var index = 0
			
			for movie in array {
				if let existingMovieId = movie.tmdbId {
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