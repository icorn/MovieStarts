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


class MovieDatabaseParent : DatabaseParent
{	
    public var viewForError: UIView?
    
	var moviesPlistPath: String?
	var moviesPlistFile: String?

	var loadedMovieRecordArray: [MovieRecord]?
	var queryKeys: [String] = []

	var updatedCKRecords: [CKRecord] = []
	var allCKRecords: [CKRecord] = []
	
	var completionHandler: (([MovieRecord]?) -> ())?
	var errorHandler: ((String) -> ())?
	var finishHandler: (() -> ())?
	var updateMovieHandler: ((MovieRecord) -> ())?
	var addNewMovieHandler: ((MovieRecord) -> ())?
	var removeMovieHandler: ((MovieRecord) -> ())?
	var updateThumbnailHandler: ((Int) -> ())?
	
	var showIndicator: (() -> ())?
	var stopIndicator: (() -> ())?
	var updateIndicator: ((Int) -> ())?
	
	
	/**
		Writes the movies and the modification date to file.
		- parameter allMovieRecords:			The array with all movies. This will be written to file.
		- parameter updatedMoviesAsRecordArray:	The array with all updated movies (only used to find out latest modification date)
		- parameter completionHandler:			The handler which is called upon completion
		- parameter errorHandler:				The handler which is called if an error occurs
	*/
	func writeMovies(allMovieRecords: [MovieRecord], updatedMoviesAsRecordArray: [CKRecord], completionHandler: ([MovieRecord]?) -> (), errorHandler: (String) -> ()) {
		
		// write it to device
		
		if let filename = self.moviesPlistFile {
			if ((MovieDatabaseHelper.movieRecordArrayToDictArray(movieRecords: allMovieRecords) as NSArray).write(toFile: filename, atomically: true) == false) {
				if let saveStopIndicator = self.stopIndicator {
					DispatchQueue.main.async {
						saveStopIndicator()
					}
				}
				
				errorHandler("*** Error writing movies-file")
				var errorWindow: MessageWindow?
				
				if let viewForError = viewForError {
					DispatchQueue.main.async {
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
			errorHandler("*** Filename for movies-list is broken")
			return
		}
		
		// and store the latest modification-date of the records
		if (updatedMoviesAsRecordArray.count > 0) {
			MovieDatabaseHelper.storeLastModification(ckrecords: updatedMoviesAsRecordArray)
		}
		
		// success
		DispatchQueue.main.async {
			self.finishHandler?()
		}
		
		completionHandler(allMovieRecords)
	}

	
	/**
		Checks if there are movies which are too old and removes them.
		- parameter existingMovies:	The array of existing movies to check
	*/
	func cleanUpExistingMovies(_ existingMovies: inout [MovieRecord])
    {
		let compareDateTooOld = Date(timeIntervalSinceNow: 60 * 60 * 24 * -1 * Constants.maxDaysInThePast) // 30 days ago
		let oldNumberOfMovies = existingMovies.count
		var removedMovies = 0
        let invalidCalendar = Calendar(identifier: .gregorian)
        let dateComponents = DateComponents(calendar: invalidCalendar,
                                            timeZone: TimeZone(secondsFromGMT: 0),
                                            year: 9999,
                                            month: 1,
                                            day: 1,
                                            hour: 0,
                                            minute: 0,
                                            second: 0)
        let compareDateInvalid = invalidCalendar.date(from: dateComponents)

		print("Cleaning up old & invalid movies...")
		
		let prefsCountryString = (UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
		
		if let country = MovieCountry(rawValue: prefsCountryString)
        {
			for index in (0 ..< existingMovies.count).reversed()
            {
				let releaseDate = existingMovies[index].releaseDate[country.countryArrayIndex]
				
				if releaseDate.compare(compareDateTooOld) == ComparisonResult.orderedAscending
                {
					// movie is too old
					removeMovieHandler?(existingMovies[index])
					print("   '\(existingMovies[index].origTitle ?? "nil")' (\(releaseDate)) removed (too old)")
					existingMovies.remove(at: index)
				}
                else if let compareDateInvalid = compareDateInvalid, releaseDate.compare(compareDateInvalid) == ComparisonResult.orderedDescending
                {
                    // movie is from year 9999 (-> invalid)
                    removeMovieHandler?(existingMovies[index])
                    print("   '\(existingMovies[index].origTitle ?? "nil")' (\(releaseDate)) removed (invalid)")
                    existingMovies.remove(at: index)
                }
			}
			
			removedMovies = oldNumberOfMovies - existingMovies.count
			
			if (removedMovies > 0)
            {
				// udpate the watch
				WatchSessionManager.sharedManager.sendAllFavoritesToWatch(sendList: true, sendThumbnails: false)
			}
		}
		
		print("Clean up over, removed \(removedMovies) movies from local file. Now we have \(existingMovies.count) movies.")
	}
	
	
	/**
		Loads the genre database.
		- parameter genresLoadedHandler: This handler is called after the genres are read, even if an error occured.
	*/
	func loadGenreDatabase(_ genresLoadedHandler: @escaping (() -> ())) {
		
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
		let prefsCountryString = (UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
		guard let country = MovieCountry(rawValue: prefsCountryString) else { return nil }
		
		if let moviesPlistFile = moviesPlistFile {
			// try to load movies from device
			if let loadedDictArray = NSArray(contentsOfFile: moviesPlistFile) as? [NSDictionary] {
				// successfully loaded movies from device
				return MovieDatabaseHelper.dictArrayToMovieRecordArray(dictArray: loadedDictArray, country: country)
			}
		}
		
		return nil
	}

	
	/**
		Tries to write the movies to the device.
	*/
	func writeMoviesToDevice() {
		if let completionHandler = completionHandler,
           let errorHandler = errorHandler,
           let loadedMovieRecordArray = loadedMovieRecordArray
        {
			writeMovies(allMovieRecords: loadedMovieRecordArray, updatedMoviesAsRecordArray: updatedCKRecords, completionHandler: completionHandler, errorHandler: errorHandler)
		}
		else {
			errorHandler?("One of the handlers is nil!")
		}
	}
}

