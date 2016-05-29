//
//  MovieDatabaseParent.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 25.03.16.
//  Copyright © 2016 Oliver Eichhorn. All rights reserved.
//

import Foundation
import CloudKit
import UIKit


class MovieDatabaseParent : DatabaseParent {
	
	var moviesPlistPath: String?
	var moviesPlistFile: String?

	var loadedMovieRecordArray: [MovieRecord]?
	var viewForError: UIView?
	var queryKeys: [String] = []

	var updatedCKRecords: [CKRecord] = []
	var allCKRecords: [CKRecord] = []
	
	var completionHandler: ((movies: [MovieRecord]?) -> ())?
	var errorHandler: ((errorMessage: String) -> ())?
	var finishHandler: (() -> ())?
	var updateMovieHandler: ((movie: MovieRecord) -> ())?
	var addNewMovieHandler: ((movie: MovieRecord) -> ())?
	var removeMovieHandler: ((movie: MovieRecord) -> ())?
	var updateThumbnailHandler: ((tmdbId: Int) -> ())?
	
	var showIndicator: (() -> ())?
	var stopIndicator: (() -> ())?
	var updateIndicator: ((counter: Int) -> ())?
	
	
	/**
		Writes the movies and the modification date to file.
		- parameter allMovieRecords:			The array with all movies. This will be written to file.
		- parameter updatedMoviesAsRecordArray:	The array with all updated movies (only used to find out latest modification date)
		- parameter completionHandler:			The handler which is called upon completion
		- parameter errorHandler:				The handler which is called if an error occurs
	*/
	func writeMovies(allMovieRecords: [MovieRecord], updatedMoviesAsRecordArray: [CKRecord], completionHandler: (movies: [MovieRecord]?) -> (), errorHandler: (errorMessage: String) -> ()) {
		
		// write it to device
		
		if let filename = self.moviesPlistFile {
			if ((MovieDatabaseHelper.movieRecordArrayToDictArray(allMovieRecords) as NSArray).writeToFile(filename, atomically: true) == false) {
				if let saveStopIndicator = self.stopIndicator {
					dispatch_async(dispatch_get_main_queue()) {
						saveStopIndicator()
					}
				}
				
				errorHandler(errorMessage: "*** Error writing movies-file")
				var errorWindow: MessageWindow?
				
				if let viewForError = viewForError {
					dispatch_async(dispatch_get_main_queue()) {
						errorWindow = MessageWindow(parent: viewForError, darkenBackground: true, titleStringId: "InternalErrorTitle", textStringId: "ErrorWritingFile", buttonStringIds: ["Close"],
						                            handler: { (buttonIndex) -> () in
														errorWindow?.close()
							}
						)
					}
				}
				
				return
			}
		}
		else {
			errorHandler(errorMessage: "*** Filename for movies-list is broken")
			return
		}
		
		// and store the latest modification-date of the records
		if (updatedMoviesAsRecordArray.count > 0) {
			MovieDatabaseHelper.storeLastModification(updatedMoviesAsRecordArray)
		}
		
		// success
		dispatch_async(dispatch_get_main_queue()) {
			self.finishHandler?()
		}
		
		completionHandler(movies: allMovieRecords)
	}

	
	/**
		Checks if there are movies which are too old and removes them.
		- parameter existingMovies:	The array of existing movies to check
	*/
	func cleanUpExistingMovies(inout existingMovies: [MovieRecord]) {
		let compareDate = NSDate(timeIntervalSinceNow: 60 * 60 * 24 * -1 * Constants.maxDaysInThePast) // 30 days ago
		let oldNumberOfMovies = existingMovies.count
		var removedMovies = 0
		
		print("Cleaning up old movies...")
		
		let prefsCountryString = (NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
		
		if let country = MovieCountry(rawValue: prefsCountryString) {
			
			for index in (0 ..< existingMovies.count).reverse() {
				let releaseDate = existingMovies[index].releaseDate[country.countryArrayIndex]
				
				if releaseDate.compare(compareDate) == NSComparisonResult.OrderedAscending {
					// movie is too old
					removeMovieHandler?(movie: existingMovies[index])
					print("   '\(existingMovies[index].origTitle)' (\(releaseDate)) removed")
					existingMovies.removeAtIndex(index)
				}
			}
			
			removedMovies = oldNumberOfMovies - existingMovies.count
			
			if (removedMovies > 0) {
				// udpate the watch
				WatchSessionManager.sharedManager.sendAllFavoritesToWatch(true, sendThumbnails: false)
			}
		}
		
		print("Clean up over, removed \(removedMovies) movies from local file. Now we have \(existingMovies.count) movies.")
	}
	
	
	/**
		Loads the genre database.
		- parameter genresLoadedHandler: This handler is called after the genres are read, even if an error occured.
	*/
	func loadGenreDatabase(genresLoadedHandler: (() -> ())) {
		
		let genreDatabase = GenreDatabase(
			finishHandler: { (genres) -> () in
				genresLoadedHandler()
			},
			errorHandler: { (errorMessage) -> () in
				NSLog("Error reading genres from the Cloud: \(errorMessage)")
				genresLoadedHandler()
			}
		)
		
		genreDatabase.readGenresFromCloud()
	}

	
	/**
		Reads the movie database from local file and returns it.
		- returns: All movies as array of MovieRecord objects, or nil on error
	*/
	func readDatabaseFromFile() -> [MovieRecord]? {
		let prefsCountryString = (NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
		guard let country = MovieCountry(rawValue: prefsCountryString) else { return nil }
		
		if let moviesPlistFile = moviesPlistFile {
			// try to load movies from device
			if let loadedDictArray = NSArray(contentsOfFile: moviesPlistFile) as? [NSDictionary] {
				// successfully loaded movies from device
				return MovieDatabaseHelper.dictArrayToMovieRecordArray(loadedDictArray, country: country)
			}
		}
		
		return nil
	}

	
	/**
		Tries to write the movies to the device.
	*/
	func writeMoviesToDevice() {
		if let completionHandler = completionHandler, errorHandler = errorHandler, loadedMovieRecordArray = loadedMovieRecordArray {
			writeMovies(loadedMovieRecordArray, updatedMoviesAsRecordArray: updatedCKRecords, completionHandler: completionHandler, errorHandler: errorHandler)
		}
		else {
			errorHandler?(errorMessage: "One of the handlers is nil!")
		}
	}
}

