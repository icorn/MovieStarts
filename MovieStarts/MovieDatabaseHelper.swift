//
//  DatabaseHelper.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 21.02.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation
import CloudKit


public class MovieDatabaseHelper {
	
   /**
		Converts an array of MovieRecord objects to an array of NSDictionaries.
	
		- parameter movieRecords:	The input array of MovieRecord objects
	
		- returns: An array of NSDictionarys which contain the data of the input parameter movieRecords.
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
	
		- parameter dictArray:	The input array of NSDictionarys
		- parameter country:	The current country for the movie
	
		- returns: An array of MovieRecord objects, generated of the input parameter dictArray.
	*/
	public class func dictArrayToMovieRecordArray(dictArray: [NSDictionary]?, country: MovieCountry) -> [MovieRecord] {
		var retval: [MovieRecord] = []
		
		if let dictArray = dictArray {
			for dict in dictArray {
				if let dict = (dict as? [String : AnyObject]) {
					retval.append(MovieRecord(country: country, dict: dict))
				}
				else {
					NSLog("Error converting dictionary")
				}
			}
		}
		
		return retval
	}
	
	
   /**
		Stores the date of the last modified CKRecord in the UserDefaults.
	
		- parameter ckrecords:	The new or updated CKRecords from the CloudKit database
	*/
	class func storeLastModification(ckrecords: [CKRecord]) {
		var latestModification = NSDate(timeIntervalSince1970: 0)
		
		for movie in ckrecords {
			if let movieModDate = movie.modificationDate {
				if (latestModification.compare(movieModDate) == NSComparisonResult.OrderedAscending) {
					latestModification = movieModDate
				}
			}
		}
		
		NSUserDefaults(suiteName: Constants.movieStartsGroup)?.setObject(latestModification, forKey: Constants.prefsLatestDbModification)
		NSUserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
	}
	
	
   /**
		Joins the both arrays of MovieRecord with existing and updated movies.
	
		- parameter existingMovies:	The array with the existing movies
		- parameter updatedMovies:	The array with the updated movies
	*/
	public class func joinMovieRecordArrays(inout existingMovies: [MovieRecord], updatedMovies: [MovieRecord]) {
		
		for updatedMovie in updatedMovies {
			let movieIndex = MovieDatabaseHelper.findArrayIndexOfMovie(updatedMovie, array: existingMovies)
			
			if let movieIndex = movieIndex {
				// update existing movie
				existingMovies[movieIndex] = updatedMovie
			}
			else {
				// add new movie
				existingMovies.append(updatedMovie)
			}
		}
	}
	
	
   /**
		Searches for a movie in an array of movie records. The index or null is returned.
	
		- parameter updatedMovie:	The movie record to search for
		- parameter array:			The array to be searched
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