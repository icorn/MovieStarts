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


class MovieDatabaseUpdater : MovieDatabaseParent, MovieDatabaseProtocol {
	
	required init(recordType: String, viewForError: UIView?) {
		super.init(recordType: recordType)

		self.viewForError = viewForError
		queryKeys = [Constants.dbIdTmdbId, Constants.dbIdOrigTitle, Constants.dbIdPopularity, Constants.dbIdVoteAverage, Constants.dbIdVoteCount, Constants.dbIdProductionCountries, Constants.dbIdImdbId, Constants.dbIdDirectors, Constants.dbIdActors, Constants.dbIdHidden, Constants.dbIdGenreIds, Constants.dbIdCharacters, Constants.dbIdId, Constants.dbIdTrailerIdsEN, Constants.dbIdPosterUrlEN, Constants.dbIdSynopsisEN, Constants.dbIdRuntimeEN, Constants.dbIdRatingImdb, Constants.dbIdRatingTomato, Constants.dbIdTomatoImage, Constants.dbIdTomatoURL, Constants.dbIdRatingMetacritic]

		let fileUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(Constants.movieStartsGroup)

		if let fileUrl = fileUrl, fileUrlPath = fileUrl.path {
			moviesPlistPath = fileUrlPath
		}
        else {
            NSLog("Error getting url for app-group.")
			var errorWindow: MessageWindow?

			if let viewForError = viewForError {
				dispatch_async(dispatch_get_main_queue()) {
					errorWindow = MessageWindow(parent: viewForError, darkenBackground: true, titleStringId: "InternalError", textStringId: "NoAppGroup", buttonStringIds: ["Close"], handler: { (buttonIndex) -> () in
						errorWindow?.close()
					})
				}
			}
        }
		
		if let saveMoviesPlistPath = self.moviesPlistPath {
			if saveMoviesPlistPath.hasSuffix("/") {
				moviesPlistFile = saveMoviesPlistPath + recordType + ".plist"
			}
			else {
				moviesPlistFile = saveMoviesPlistPath + "/" + recordType + ".plist"
			}
		}
	}
	
	
	/**
		Checks if there are new or updates movies in the cloud and gets them.
	*/
	func getUpdatedMovies(	allMovies: [MovieRecord],
							country: MovieCountry,
							addNewMovieHandler: (movie: MovieRecord) -> (),
							updateMovieHandler: (movie: MovieRecord) -> (),
							removeMovieHandler: (movie: MovieRecord) -> (),
							completionHandler: (movies: [MovieRecord]?) -> (),
							errorHandler: (errorMessage: String) -> ())
	{
		self.addNewMovieHandler = addNewMovieHandler
		self.updateMovieHandler = updateMovieHandler
		self.removeMovieHandler = removeMovieHandler
		self.completionHandler  = completionHandler
		self.errorHandler		= errorHandler
		
		self.loadedMovieRecordArray = allMovies
		
		let userDefaults = NSUserDefaults(suiteName: Constants.movieStartsGroup)
		let latestModDate: NSDate? = userDefaults?.objectForKey(Constants.prefsLatestDbModification) as? NSDate
		
		if let modDate: NSDate = latestModDate {
			let minReleaseDate = NSDate(timeIntervalSinceNow: 60 * 60 * 24 * -1 * Constants.maxDaysInThePast)
			
			NSLog("Getting records after modification date \(modDate) and after releasedate \(minReleaseDate)")
			
			UIApplication.sharedApplication().networkActivityIndicatorVisible = true
			
			// get records modified after the last modification of the local database
			let predicateModificationDate = NSPredicate(format: "(%K > %@) AND (modificationDate > %@)", argumentArray: [country.databaseKeyRelease, minReleaseDate, modDate])
			let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [predicateModificationDate])
			
			let query = CKQuery(recordType: self.recordType, predicate: predicate)
			let queryOperation = CKQueryOperation(query: query)

			let operationQueue = NSOperationQueue()
			executeQueryOperation(queryOperation, onOperationQueue: operationQueue)
		}
		else {
			NSLog("ERROR: mo last mod.data of db")
		}
	}
	
	
	/**
		Sends a new CloudKit query to get more updated records.
		- parameter queryOperation:		The query operation containing the predicates
		- parameter onOperationQueue:	The queue for the query operation
	*/
	internal func executeQueryOperation(queryOperation: CKQueryOperation, onOperationQueue operationQueue: NSOperationQueue) {
		let prefsCountryString = (NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
		
		if let country = MovieCountry(rawValue: prefsCountryString) {
			queryOperation.desiredKeys = self.queryKeys + country.languageQueryKeys + country.countryQueryKeys
		}
		else {
			NSLog("executeQueryOperationUpdatedMovies: Error getting country for country-code \(prefsCountryString)")
		}
		
		queryOperation.database = cloudKitDatabase
		queryOperation.qualityOfService = NSQualityOfService.UserInitiated
		queryOperation.recordFetchedBlock = self.recordFetchedCallback
/*
		queryOperation.recordFetchedBlock = { (record : CKRecord) -> Void in
			self.recordFetchedCallback(record)
		}
*/
		queryOperation.queryCompletionBlock = { (cursor: CKQueryCursor?, error: NSError?) -> Void in
			if let cursor = cursor {
				// some objects are here, ask for more
				let queryCursorOperation = CKQueryOperation(cursor: cursor)
				self.executeQueryOperation(queryCursorOperation, onOperationQueue: operationQueue)
			}
			else {
				// download finished (with error or not)
				self.queryOperationFinished(error)
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
	internal func recordFetchedCallback(record: CKRecord) {
		
		let prefsCountryString = (NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
		guard let country = MovieCountry(rawValue: prefsCountryString) else { NSLog("recordFetchedUpdatedMoviesCallback: Corrupt countrycode \(prefsCountryString)"); return }
			
		let newMovieRecord = MovieRecord(country: country)
		newMovieRecord.initWithCKRecord(record)
		var movieAlreadyExists: Bool = false
		
		if let existingMovieRecords = loadedMovieRecordArray {
			for existingMovieRecord in existingMovieRecords {
				if (existingMovieRecord.id == newMovieRecord.id) {
					movieAlreadyExists = true
					break
				}
			}
		}
		
		if (movieAlreadyExists) {
			self.updateMovieHandler?(movie: newMovieRecord)
		}
		else {
			self.addNewMovieHandler?(movie: newMovieRecord)
		}
		
		updatedCKRecords.append(record)
	}
	
	
	/**
		This function is called when all updated records have been fetched from the CloudKit database.
		MovieRecord objects are generated and save.
		- parameter error:	The error object
	*/
	internal func queryOperationFinished(error: NSError?) {
		if let error = error {
			// there was an error
			self.errorHandler?(errorMessage: "Error querying updated records: \(error.code) (\(error.description))")
			return
		}
		else {
			// received records from the cloud
			let userDefaults = NSUserDefaults(suiteName: Constants.movieStartsGroup)
			userDefaults?.setObject(NSDate(), forKey: Constants.prefsLatestDbSuccessfullUpdate)
			userDefaults?.synchronize()

			if (updatedCKRecords.count > 0) {
				// generate an array of MovieRecords
				var updatedMovieRecordArray: [MovieRecord] = []
					
				let prefsCountryString = (NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
				guard let country = MovieCountry(rawValue: prefsCountryString) else { NSLog("queryOperationFinishedUpdatedMovies: Corrupt countrycode \(prefsCountryString)"); return }
					
				for ckRecord in self.updatedCKRecords {
					let newRecord = MovieRecord(country: country)
					newRecord.initWithCKRecord(ckRecord)
					updatedMovieRecordArray.append(newRecord)
				}
					
				// merge both arrays (the existing movies and the updated movies)
				if (self.loadedMovieRecordArray != nil) {
					MovieDatabaseHelper.joinMovieRecordArrays(&(self.loadedMovieRecordArray!), updatedMovies: updatedMovieRecordArray)
				}
			}
			
			// delete all movies which are too old
			if (loadedMovieRecordArray != nil) {
				cleanUpExistingMovies(&loadedMovieRecordArray!)
			}
			
			if (updatedCKRecords.count > 0) {
				// we have updated records: also update genre-database, then clean-up posters
				loadGenreDatabase({ () -> () in
					self.cleanUpPosters()
					self.writeMoviesToDevice()
				})
			}
			else {
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
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
            let pathUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(Constants.movieStartsGroup)
		
            if let basePath = pathUrl?.path, movies = self.loadedMovieRecordArray {
                self.deleteUnneededPosters(basePath, movies: movies)
                self.downloadMissingPosters(basePath, movies: movies)
                self.deleteUnneededYoutubeImages(basePath, movies: movies)
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
			filenames = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(basePath + Constants.thumbnailFolder)
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
                            for posterUrl in movie.posterUrl {
                                if ((posterUrl.characters.count > 3) &&
                                    (posterfilenameString == posterUrl.substringFromIndex(posterUrl.startIndex.advancedBy(1))))
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
							try NSFileManager.defaultManager().removeItemAtPath(basePath + Constants.thumbnailFolder + "/" + posterfilenameString)
						} catch let error as NSError {
							NSLog("Error removing thumbnail: \(error.description)")
						}
						do {
							try NSFileManager.defaultManager().removeItemAtPath(basePath + Constants.bigPosterFolder + "/" + posterfilenameString)
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
			filenames = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(basePath + Constants.trailerFolder)
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
								if (trailerId.characters.count > 0) {
									if (trailerfilenameString.beginsWith(trailerId)) {
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
							try NSFileManager.defaultManager().removeItemAtPath(basePath + Constants.trailerFolder + "/" + trailerfilenameString)
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
		
		let prefsCountryString = (NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
		let sourcePath = Constants.imageBaseUrl + PosterSizePath.Small.rawValue

		guard let country = MovieCountry(rawValue: prefsCountryString) else { return }
		
		for movie in movies {
			var posterUrl = movie.posterUrl[country.languageArrayIndex]
			
			if (posterUrl.characters.count == 0) {
				// if there is no poster in wanted language, try the english one
				posterUrl = movie.posterUrl[MovieCountry.England.languageArrayIndex]
			}
			
			if ((posterUrl.characters.count > 0) && (NSFileManager.defaultManager().fileExistsAtPath(basePath + Constants.thumbnailFolder + posterUrl) == false)) {
				// poster file is missing
				
				if let sourceUrl = NSURL(string: sourcePath + posterUrl) {
					let task = NSURLSession.sharedSession().downloadTaskWithURL(sourceUrl,
						completionHandler: { (location: NSURL?, response: NSURLResponse?, error: NSError?) -> Void in
						if let error = error {
							NSLog("Error getting missing thumbnail: \(error.description)")
						}
						else if let receivedPath = location?.path {
							// move received thumbnail to target path where it belongs and update the thumbnail in the table view
							do {
								try NSFileManager.defaultManager().moveItemAtPath(receivedPath, toPath: basePath + Constants.thumbnailFolder + posterUrl)
								if let tmdbId = movie.tmdbId {
									self.updateThumbnailHandler?(tmdbId: tmdbId)
								}
							}
							catch let error as NSError {
								if ((error.domain == NSCocoaErrorDomain) && (error.code == NSFileWriteFileExistsError)) {
									// ignoring, because it's okay it it's already there
								}
								else {
									NSLog("Error moving missing poster: \(error.description)")
								}
							}
						}
					})
					
					task.resume()
				}
			}
		}
	}
}

