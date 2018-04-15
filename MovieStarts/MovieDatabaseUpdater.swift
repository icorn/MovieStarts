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


class MovieDatabaseUpdater : MovieDatabaseParent, MovieDatabaseProtocol
{
    static let sharedInstance = MovieDatabaseUpdater()
    static let MovieUpdateFinishNotification = "MovieUpdateFinishNotification"
    
    private init()
    {
        let recordType = Constants.dbRecordTypeMovie
        
        super.init(recordType: recordType)
        
        self.inProgress = false
        queryKeys = [Constants.dbIdTmdbId, Constants.dbIdOrigTitle, Constants.dbIdPopularity, Constants.dbIdVoteAverage, Constants.dbIdVoteCount, Constants.dbIdProductionCountries, Constants.dbIdImdbId, Constants.dbIdDirectors, Constants.dbIdActors, Constants.dbIdHidden, Constants.dbIdGenreIds, Constants.dbIdCharacters, Constants.dbIdId, Constants.dbIdTrailerIdsEN, Constants.dbIdPosterUrlEN, Constants.dbIdSynopsisEN, Constants.dbIdRuntimeEN,
                     
            // version 1.2
            Constants.dbIdRatingImdb, Constants.dbIdRatingTomato, Constants.dbIdTomatoImage, Constants.dbIdTomatoURL, Constants.dbIdRatingMetacritic,
            
            // version 1.3
            Constants.dbIdBudget, Constants.dbIdBackdrop, Constants.dbIdProfilePictures, Constants.dbIdDirectorPictures, Constants.dbIdHomepageEN, Constants.dbIdTaglineEN, Constants.dbIdCrewWriting
        ]
        
        let fileUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.movieStartsGroup)
        
        if let fileUrl = fileUrl
        {
            moviesPlistPath = fileUrl.path
        }
        else
        {
            NSLog("Error getting url for app-group.")
            var errorWindow: MessageWindow?
            
            if let viewForError = viewForError {
                DispatchQueue.main.async {
                    errorWindow = MessageWindow(parent: viewForError, darkenBackground: true, titleStringId: "InternalError", textStringId: "NoAppGroup", buttonStringIds: ["Close"], handler: { (buttonIndex) -> () in
                        errorWindow?.close()
                    })
                }
            }
        }
        
        if let saveMoviesPlistPath = self.moviesPlistPath
        {
            if saveMoviesPlistPath.hasSuffix("/") {
                moviesPlistFile = saveMoviesPlistPath + recordType + ".plist"
            }
            else {
                moviesPlistFile = saveMoviesPlistPath + "/" + recordType + ".plist"
            }
        }
    }
    
    
/*
 
    TODO
 
    Für die Zukunft: Entweder weiter unten jedes insert/delete/etc. als local-notification an den Rest der App (wäre ideal), oder
    (falls das mit dem Timing nicht klappt) z. B. den ganzen Controller hier her übergeben, und wir rufen es ähnlich auf wie jetzt.
    
    
    func updateMovies(allMovies: [MovieRecord], withErrorView errorView: UIView)
    {
        let userDefaults = UserDefaults(suiteName: Constants.movieStartsGroup)
/*
        if (userDefaults?.object(forKey: Constants.prefsLatestDbSuccessfullUpdate) != nil) {
            let latestSuccessfullUpdate: Date? = userDefaults?.object(forKey: Constants.prefsLatestDbSuccessfullUpdate) as? Date
            
            if let latestSuccessfullUpdate = latestSuccessfullUpdate {
                let hoursSinceLastSuccessfullUpdate = abs(Int(latestSuccessfullUpdate.timeIntervalSinceNow)) / 60 / 60
                
                if (hoursSinceLastSuccessfullUpdate < Constants.hoursBetweenDbUpdates) {
                    // last successfull update was inside the tolerance: don't get new update
                    return
                }
            }
        }
*/
        // check iCloud status
        
        MovieDatabaseUpdater.sharedInstance.checkCloudKit(
            handler:
            { [unowned self] (status: CKAccountStatus, error: Error?) -> () in
            
                var errorWindow: MessageWindow?
                
                switch status
                {
                case .available:
                    self.getUpdatedMoviesFromDatabase(allMovies: allMovies)
                    
                case .noAccount:
                    NSLog("CloudKit error on update: no account")
                    DispatchQueue.main.async
                    {
                        errorWindow = MessageWindow(parent: errorView,
                                                    darkenBackground: true,
                                                    titleStringId: "iCloudError",
                                                    textStringId: "iCloudNoAccountUpdate",
                                                    buttonStringIds: ["Close"],
                                                    handler: { (buttonIndex) -> () in
                                                        errorWindow?.close()
                                                    })
                    }
                    
                case .restricted:
                    NSLog("CloudKit error on update: Restricted")
                    DispatchQueue.main.async
                    {
                        errorWindow = MessageWindow(parent: errorView,
                                                    darkenBackground: true,
                                                    titleStringId: "iCloudError",
                                                    textStringId: "iCloudRestrictedUpdate",
                                                    buttonStringIds: ["Close"],
                                                    handler: { (buttonIndex) -> () in
                                                        errorWindow?.close()
                                                    })
                    }
                    
                case .couldNotDetermine:
                    NSLog("CloudKit error on update: CouldNotDetermine")
                    DispatchQueue.main.async
                    {
                        errorWindow = MessageWindow(parent: errorView,
                                                    darkenBackground: true,
                                                    titleStringId: "iCloudError",
                                                    textStringId: "iCloudCouldNotDetermineUpdate",
                                                    buttonStringIds: ["Close"],
                                                    handler: { (buttonIndex) -> () in
                                                        errorWindow?.close()
                                                    })
                    }
                }
            }
        )
    }

    
    private func getUpdatedMoviesFromDatabase(allMovies: [MovieRecord])
    {
        let prefsCountryString = (UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
        
        guard let country = MovieCountry(rawValue: prefsCountryString) else
        {
            NSLog("ERROR getting country from preferences")
            return
        }
        
        MovieDatabaseUpdater.sharedInstance.updateThumbnailHandler = updateThumbnailHandler
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async
        {
            MovieDatabaseUpdater.sharedInstance.getUpdatedMovies(
                allMovies,
                country: country,
                addNewMovieHandler: { [unowned self] (movie: MovieRecord) in
                    
                    if (!movie.isHidden)
                    {
                        // add new movie
                        
                        DispatchQueue.main.async
                        {
                            let title = movie.title[movie.currentCountry.languageArrayIndex]
                            
                            if movie.isNowPlaying()
                            {
                                print("Adding \(title) to NOW PLAYING")
                                self.nowPlayingController?.addMovie(movie)
                            }
                            else
                            {
                                print("Adding \(title) to UPCOMING")
                                self.upcomingController?.addMovie(movie)
                            }
                        }
                    }
                },
                
                updateMovieHandler: { [unowned self] (movie: MovieRecord) in
                    
                    // update movie
                    
                    // there are several possibilities:
                    // 1a) movie was and is now-playing, movie cell stays in same position, only "invisible" changes
                    // 1b) movie was and is now-playing, movie cell stays in same position, changes in visible data, change cell with animation
                    // 1c) movie was and is now-playing, movie cell moves because of name-change
                    
                    // 2a) movie was and is upcoming, movie cell stays in same position (same date, same name), only "invisible" changes
                    // 2b) movie was and is upcoming, movie cell stays in same position (same date, same name), changes in visible data, change cell with animation
                    // 2c) movie was and is upcoming, movie cell moves in current section (same date, name has changed)
                    // 2d) movie was and is upcoming, movie cell moves from one section to another (date has changed)
                    
                    // 3) movie was upcoming, is now now-playing
                    // 4) movie was now-playing, is now upcoming (unlikely)
                    
                    // the last two remove the cell from one *tab* and add it to another.
                    
                    let movieIsInUpcomingList = self.isMovieInUpcomingList(newMovie: movie)
                    let movieIsInNowPlayingList = self.isMovieInNowPlayingList(newMovie: movie)
                    
                    DispatchQueue.main.async
                    {
                        if (movie.isNowPlaying() && movieIsInNowPlayingList)
                        {
                            // movie was and is now-playing
                            
                            if movie.isHidden
                            {
                                self.nowPlayingController?.removeMovie(movie)
                            }
                            else
                            {
                                let title = movie.title[movie.currentCountry.languageArrayIndex]
                                print("Updating \(title) in NOW PLAYING")
                                self.nowPlayingController?.updateMovie(movie)
                            }
                        }
                        else if (!movie.isNowPlaying() && movieIsInUpcomingList)
                        {
                            // movie was and is upcoming
                            
                            if movie.isHidden
                            {
                                self.upcomingController?.removeMovie(movie)
                            }
                            else
                            {
                                let title = movie.title[movie.currentCountry.languageArrayIndex]
                                print("Updating \(title) in UPCOMING")
                                self.upcomingController?.updateMovie(movie)
                            }
                        }
                        else if (!movie.isNowPlaying() && movieIsInNowPlayingList)
                        {
                            // movie was now-playing, is now upcoming
                            
                            if movie.isHidden
                            {
                                self.nowPlayingController?.removeMovie(movie)
                            }
                            else
                            {
                                let title = movie.title[movie.currentCountry.languageArrayIndex]
                                print("Moving \(title) in from NOW PLAYING to UPCOMING")
                                self.nowPlayingController?.removeMovie(movie)
                                self.upcomingController?.addMovie(movie)
                            }
                        }
                        else if (movie.isNowPlaying() && movieIsInUpcomingList)
                        {
                            // movie was upcoming, is now now-playing
                            
                            if movie.isHidden
                            {
                                self.upcomingController?.removeMovie(movie)
                            }
                            else
                            {
                                let title = movie.title[movie.currentCountry.languageArrayIndex]
                                print("Moving \(title) in from UPCOMING to NOW PLAYING")
                                self.upcomingController?.removeMovie(movie)
                                self.nowPlayingController?.addMovie(movie)
                            }
                        }
                        
                        if (Favorites.IDs.contains(movie.id))
                        {
                            // also, update the favorites
                            
                            if movie.isHidden
                            {
                                self.favoriteController?.removeFavorite(movie.id)
                            }
                            else
                            {
                                let title = movie.title[movie.currentCountry.languageArrayIndex]
                                print("Updating \(title) in FAVORITES")
                                self.favoriteController?.updateFavorite(movie)
                            }
                        }
                    }
                },
                
                removeMovieHandler: { [unowned self] (movie: MovieRecord) in
                    
                    // remove movie
                    DispatchQueue.main.async
                    {
                        self.nowPlayingController?.removeMovie(movie)
                        self.upcomingController?.removeMovie(movie)
                        
                        if (Favorites.IDs.contains(movie.id))
                        {
                            self.favoriteController?.removeFavorite(movie.id)
                        }
                    }
                },
                
                completionHandler: { [unowned self] (movies: [MovieRecord]?) in
                    DispatchQueue.main.async
                    {
                         UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                    self.loadGenresFromFile()
                },
                
                errorHandler: { (errorMessage: String) in
                    DispatchQueue.main.async
                    {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                    NSLog(errorMessage)
                }
            )
        }
    }
*/
    

	/**
		Checks if there are new or updates movies in the cloud and gets them.
	*/
	func getUpdatedMovies(_ allMovies: [MovieRecord],
							country: MovieCountry,
							addNewMovieHandler: @escaping (MovieRecord) -> (),
							updateMovieHandler: @escaping (MovieRecord) -> (),
							removeMovieHandler: @escaping (MovieRecord) -> (),
							completionHandler: @escaping ([MovieRecord]?) -> (),
							errorHandler: @escaping (String) -> ())
	{
        self.inProgress = true

		self.addNewMovieHandler = addNewMovieHandler
		self.updateMovieHandler = updateMovieHandler
		self.removeMovieHandler = removeMovieHandler
		self.completionHandler  = completionHandler
		self.errorHandler		= errorHandler
		
		self.loadedMovieRecordArray = allMovies
		
		let userDefaults = UserDefaults(suiteName: Constants.movieStartsGroup)
		let latestModDate: Date? = userDefaults?.object(forKey: Constants.prefsLatestDbModification) as? Date
		
		if let modDate: Date = latestModDate
        {
			let minReleaseDate = Date(timeIntervalSinceNow: 60 * 60 * 24 * -1 * Constants.maxDaysInThePast)
			
			NSLog("Getting records after modification date \(modDate) and after releasedate \(minReleaseDate)")
			
            DispatchQueue.main.async
            {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
            
			// get records modified after the last modification of the local database
			let predicateModificationDate = NSPredicate(format: "(%K > %@) AND (modificationDate > %@)", argumentArray: [country.databaseKeyRelease, minReleaseDate, modDate])
			let predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicateModificationDate])
			
			let query = CKQuery(recordType: self.recordType, predicate: predicate)
			let queryOperation = CKQueryOperation(query: query)

			let operationQueue = OperationQueue()
			executeQueryOperation(queryOperation: queryOperation, onOperationQueue: operationQueue)
		}
		else {
			NSLog("ERROR: mo last mod.data of db")
            self.inProgress = false
		}
	}
	
	
    // MARK: - Internal functions
    
    
	/**
		Sends a new CloudKit query to get more updated records.
		- parameter queryOperation:		The query operation containing the predicates
		- parameter onOperationQueue:	The queue for the query operation
	*/
	internal func executeQueryOperation(queryOperation: CKQueryOperation, onOperationQueue operationQueue: OperationQueue) {
		let prefsCountryString = (UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
		
		if let country = MovieCountry(rawValue: prefsCountryString)
        {
			queryOperation.desiredKeys = self.queryKeys + country.languageQueryKeys + country.countryQueryKeys
		}
		else
        {
			NSLog("executeQueryOperationUpdatedMovies: Error getting country for country-code \(prefsCountryString)")
		}
		
		queryOperation.database = cloudKitDatabase
		queryOperation.qualityOfService = QualityOfService.userInitiated
		queryOperation.recordFetchedBlock = self.recordFetchedCallback
/*
		queryOperation.recordFetchedBlock = { (record : CKRecord) -> Void in
			self.recordFetchedCallback(record)
		}
*/
		queryOperation.queryCompletionBlock = { (cursor: CKQueryCursor?, error: Error?) -> Void in
			if let cursor = cursor {
				// some objects are here, ask for more
				let queryCursorOperation = CKQueryOperation(cursor: cursor)
				self.executeQueryOperation(queryOperation: queryCursorOperation, onOperationQueue: operationQueue)
			}
			else {
				// download finished (with error or not)
				self.queryOperationFinished(error: error)
			}
		}
		
		// Add the operation to the operation queue to execute it
		operationQueue.addOperation(queryOperation)
	}
	

	/**
		Adds the record to an array to save it for later processing.
		This function is called when a new updated record was fetched from the CloudKit database.
		- parameter record:	The record from the CloudKit database
	*/
	internal func recordFetchedCallback(record: CKRecord)
    {
		let prefsCountryString = (UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
		guard let country = MovieCountry(rawValue: prefsCountryString) else { NSLog("recordFetchedUpdatedMoviesCallback: Corrupt countrycode \(prefsCountryString)"); return }
			
		let newMovieRecord = MovieRecord(country: country)
		newMovieRecord.initWithCKRecord(ckRecord: record)
		var movieAlreadyExists: Bool = false
		
		if let existingMovieRecords = loadedMovieRecordArray
        {
			for existingMovieRecord in existingMovieRecords
            {
				if (existingMovieRecord.id == newMovieRecord.id)
                {
					movieAlreadyExists = true
					break
				}
			}
		}
		
		if (movieAlreadyExists)
        {
			self.updateMovieHandler?(newMovieRecord)
		}
		else
        {
			self.addNewMovieHandler?(newMovieRecord)
		}
		
		updatedCKRecords.append(record)
	}
	
	
	/**
		This function is called when all updated records have been fetched from the CloudKit database.
		MovieRecord objects are generated and save.
		- parameter error:	The error object
	*/
	internal func queryOperationFinished(error: Error?)
    {
		if let error = error as NSError?
        {
			// there was an error
			self.errorHandler?("Error querying updated records: \(error.code) (\(error.localizedDescription))")
            self.inProgress = false
			return
		}
		else
        {
			// received records from the cloud
			let userDefaults = UserDefaults(suiteName: Constants.movieStartsGroup)
			userDefaults?.set(Date(), forKey: Constants.prefsLatestDbSuccessfullUpdate)
			userDefaults?.synchronize()

			if (updatedCKRecords.count > 0)
            {
				// generate an array of MovieRecords
				var updatedMovieRecordArray: [MovieRecord] = []
					
				let prefsCountryString = (UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
				guard let country = MovieCountry(rawValue: prefsCountryString) else { NSLog("queryOperationFinishedUpdatedMovies: Corrupt countrycode \(prefsCountryString)"); return }
					
				for ckRecord in self.updatedCKRecords
                {
					let newRecord = MovieRecord(country: country)
					newRecord.initWithCKRecord(ckRecord: ckRecord)
					updatedMovieRecordArray.append(newRecord)
				}
					
				// merge both arrays (the existing movies and the updated movies)
				if (self.loadedMovieRecordArray != nil)
                {
					MovieDatabaseHelper.joinMovieRecordArrays(existingMovies: &(self.loadedMovieRecordArray!), updatedMovies: updatedMovieRecordArray)
				}
			}
			
			// delete all movies which are too old
			if (loadedMovieRecordArray != nil)
            {
				cleanUpExistingMovies(&loadedMovieRecordArray!)
			}
			
			if (updatedCKRecords.count > 0)
            {
				// we have updated records: also update genre-database, then clean-up posters
				loadGenreDatabase({ () -> () in
					self.cleanUpPosters()
					self.writeMoviesToDevice()
				})
			}
			else
            {
				// clean up posters
				cleanUpPosters()
				self.writeMoviesToDevice()
			}
		}
	}
	
	
	// MARK: - Private functions for cleaning up
	

	/**
		Deleted unneeded poster files from the device, and reads missing poster files from the CloudKit database to the device.
	*/
	private func cleanUpPosters() {
		DispatchQueue.global(qos: DispatchQoS.QoSClass.utility).async {
            let pathUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.movieStartsGroup)
		
            if let basePath = pathUrl?.path, let movies = self.loadedMovieRecordArray {
                self.deleteUnneededPosters(basePath: basePath, movies: movies)
                self.downloadMissingPosters(basePath: basePath, movies: movies)
                self.deleteUnneededYoutubeImages(basePath: basePath, movies: movies)
            }
		}
	}


	/**
		Checks for all poster files if they are still needed and delete them if not.

		- parameter basePath:	The local basepath for all images
		- parameter movies:		The array with all movie records
	*/
	private func deleteUnneededPosters(basePath: String, movies: [MovieRecord]) {
		
		var filenames: [AnyObject]?
		do {
			filenames = try FileManager.default.contentsOfDirectory(atPath: basePath + Constants.thumbnailFolder) as [AnyObject]?
		} catch let error as NSError {
			NSLog("Error getting thumbnail folder: \(error.description)")
			filenames = nil
		}
		
		if let posterfilenames = filenames {
			for posterfilename in posterfilenames {
				var found = false
				
				if let posterfilenameString = posterfilename as? String {
					for movie in movies {
                        if (found == false) {
                            for posterUrl in movie.posterUrl
                            {
                                if ((posterUrl.count > 3) &&
                                    (posterfilenameString == String(posterUrl.suffix(posterUrl.count - 1))))
                                {
                                    found = true
                                    break
                                }
                            }
                        }
					}
					
					if (found == false) {
						// posterfile is not in any database record anymore: delete poster(s)
						print("Deleting unneeded poster image \(posterfilenameString)")

						do {
							try FileManager.default.removeItem(atPath: basePath + Constants.thumbnailFolder + "/" + posterfilenameString)
						} catch let error as NSError {
							NSLog("Error removing thumbnail: \(error.description)")
						}
						do {
							try FileManager.default.removeItem(atPath: basePath + Constants.bigPosterFolder + "/" + posterfilenameString)
						} catch {
							// this happens all the time, when no hi-res poster was loaded
							// NSLog("Error removing poster: \(error.description)")
						}
					}
				}
			}
		}
	}
	
	
	/**
		Checks for all youtube-titles-images if they are still needed and delete them if not.
		- parameter basePath:	The local basepath for all images
		- parameter movies:		The array with all movie records
	*/
	private func deleteUnneededYoutubeImages(basePath: String, movies: [MovieRecord]) {
		
		var filenames: [AnyObject]?
		do {
			filenames = try FileManager.default.contentsOfDirectory(atPath: basePath + Constants.trailerFolder) as [AnyObject]?
		} catch let error as NSError {
			NSLog("Error getting trailer folder: \(error.description)")
			filenames = nil
		}
		
		if let trailerfilenames = filenames {
			for trailerfilename in trailerfilenames {
				var found = false
				
				if let trailerfilenameString = trailerfilename as? String {
					for movie in movies {
						for trailerIdsForCountry in movie.trailerIds {
							for trailerId in trailerIdsForCountry {
								if (trailerId.count > 0) {
									if (trailerfilenameString.hasPrefix(trailerId)) {
										found = true
										break
									}
								}
							}
						}
					}

					if (found == false) {
						// trailerfile is not in any database record anymore: delete trailer-image
						
						print("Deleting unneeded trailer image \(trailerfilenameString)")

						do {
							try FileManager.default.removeItem(atPath: basePath + Constants.trailerFolder + "/" + trailerfilenameString)
						} catch let error as NSError {
							NSLog("Error removing trailer image: \(error.description)")
						}
					}
				}
			}
		}
	}
	
	
	/**
		Loads missing poster files and downloads them.
		- parameter basePath:	The local basepath for all images
		- parameter movies:		The array with all movie records
	*/
	private func downloadMissingPosters(basePath: String, movies: [MovieRecord]) {
		
		let prefsCountryString = (UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
		let sourcePath = Constants.imageBaseUrl + PosterSizePath.Small.rawValue

		guard let country = MovieCountry(rawValue: prefsCountryString) else { return }
		
		for movie in movies {
			var posterUrl = movie.posterUrl[country.languageArrayIndex]
			
			if (posterUrl.count == 0) {
				// if there is no poster in wanted language, try the english one
				posterUrl = movie.posterUrl[MovieCountry.England.languageArrayIndex]
			}
			
			if ((posterUrl.count > 0) && (FileManager.default.fileExists(atPath: basePath + Constants.thumbnailFolder + posterUrl) == false)) {
				// poster file is missing
				
				if let sourceUrl = URL(string: sourcePath + posterUrl)
                {
					let task = URLSession.shared.downloadTask(with: sourceUrl,
						completionHandler: { (location: URL?, response: URLResponse?, error: Error?) -> Void in
						if let error = error {
							NSLog("Error getting missing thumbnail: \(error.localizedDescription)")
						}
						else if let receivedPath = location?.path {
							// move received thumbnail to target path where it belongs and update the thumbnail in the table view
							do {
								try FileManager.default.moveItem(atPath: receivedPath, toPath: basePath + Constants.thumbnailFolder + posterUrl)
								if let tmdbId = movie.tmdbId {
									self.updateThumbnailHandler?(tmdbId)
								}
							}
							catch let error as NSError {
								if ((error.domain == NSCocoaErrorDomain) && (error.code == NSFileWriteFileExistsError)) {
									// ignoring, because it's okay it it's already there
								}
								else {
									NSLog("Error moving missing poster: \(error.localizedDescription)")
								}
							}
						}
					})
					
					task.resume()
				}
			}
		}
	}
    
    
    class func isLastMovieUpdateOlderThan(minutes: Int) -> Bool
    {
        let userDefaults = UserDefaults(suiteName: Constants.movieStartsGroup)
        
        if (userDefaults?.object(forKey: Constants.prefsLatestDbSuccessfullUpdate) != nil)
        {
            if let latestSuccessfullUpdate = userDefaults?.object(forKey: Constants.prefsLatestDbSuccessfullUpdate) as? Date
            {
                let minutesSinceLastSuccessfullUpdate = abs(Int(latestSuccessfullUpdate.timeIntervalSinceNow)) / 60
                
                if (minutesSinceLastSuccessfullUpdate < minutes)
                {
                    // last successfull update was inside the tolerance: don't get new update
                    return false
                }
            }
        }

        return true
    }
}

