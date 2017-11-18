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
		queryKeys = [Constants.dbIdTmdbId, Constants.dbIdOrigTitle, Constants.dbIdPopularity, Constants.dbIdVoteAverage, Constants.dbIdVoteCount, Constants.dbIdProductionCountries, Constants.dbIdImdbId, Constants.dbIdDirectors, Constants.dbIdActors, Constants.dbIdHidden, Constants.dbIdGenreIds, Constants.dbIdCharacters, Constants.dbIdId, Constants.dbIdTrailerIdsEN, Constants.dbIdPosterUrlEN, Constants.dbIdSynopsisEN, Constants.dbIdRuntimeEN,
		    
			// version 1.2
			Constants.dbIdRatingImdb, Constants.dbIdRatingTomato, Constants.dbIdTomatoImage, Constants.dbIdTomatoURL, Constants.dbIdRatingMetacritic,
		
			// version 2.0
			Constants.dbIdBudget, Constants.dbIdBackdrop, Constants.dbIdProfilePictures, Constants.dbIdDirectorPictures
		]

		let fileUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.movieStartsGroup)

		if let fileUrl = fileUrl {
			moviesPlistPath = fileUrl.path
		}
        else {
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
	func getUpdatedMovies(	_ allMovies: [MovieRecord],
							country: MovieCountry,
							addNewMovieHandler: @escaping (MovieRecord) -> (),
							updateMovieHandler: @escaping (MovieRecord) -> (),
							removeMovieHandler: @escaping (MovieRecord) -> (),
							completionHandler: @escaping ([MovieRecord]?) -> (),
							errorHandler: @escaping (String) -> ())
	{
		self.addNewMovieHandler = addNewMovieHandler
		self.updateMovieHandler = updateMovieHandler
		self.removeMovieHandler = removeMovieHandler
		self.completionHandler  = completionHandler
		self.errorHandler		= errorHandler
		
		self.loadedMovieRecordArray = allMovies
		
		let userDefaults = UserDefaults(suiteName: Constants.movieStartsGroup)
		let latestModDate: Date? = userDefaults?.object(forKey: Constants.prefsLatestDbModification) as? Date
		
		if let modDate: Date = latestModDate {
			let minReleaseDate = Date(timeIntervalSinceNow: 60 * 60 * 24 * -1 * Constants.maxDaysInThePast)
			
			NSLog("Getting records after modification date \(modDate) and after releasedate \(minReleaseDate)")
			
			UIApplication.shared.isNetworkActivityIndicatorVisible = true
			
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
		}
	}
	
	
	/**
		Sends a new CloudKit query to get more updated records.
		- parameter queryOperation:		The query operation containing the predicates
		- parameter onOperationQueue:	The queue for the query operation
	*/
	internal func executeQueryOperation(queryOperation: CKQueryOperation, onOperationQueue operationQueue: OperationQueue) {
		let prefsCountryString = (UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
		
		if let country = MovieCountry(rawValue: prefsCountryString) {
			queryOperation.desiredKeys = self.queryKeys + country.languageQueryKeys + country.countryQueryKeys
		}
		else {
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
	internal func recordFetchedCallback(record: CKRecord) {
		
		let prefsCountryString = (UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
		guard let country = MovieCountry(rawValue: prefsCountryString) else { NSLog("recordFetchedUpdatedMoviesCallback: Corrupt countrycode \(prefsCountryString)"); return }
			
		let newMovieRecord = MovieRecord(country: country)
		newMovieRecord.initWithCKRecord(ckRecord: record)
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
			self.updateMovieHandler?(newMovieRecord)
		}
		else {
			self.addNewMovieHandler?(newMovieRecord)
		}
		
		updatedCKRecords.append(record)
	}
	
	
	/**
		This function is called when all updated records have been fetched from the CloudKit database.
		MovieRecord objects are generated and save.
		- parameter error:	The error object
	*/
	internal func queryOperationFinished(error: Error?) {
		if let error = error as NSError? {
			// there was an error
			self.errorHandler?("Error querying updated records: \(error.code) (\(error.localizedDescription))")
			return
		}
		else {
			// received records from the cloud
			let userDefaults = UserDefaults(suiteName: Constants.movieStartsGroup)
			userDefaults?.set(Date(), forKey: Constants.prefsLatestDbSuccessfullUpdate)
			userDefaults?.synchronize()

			if (updatedCKRecords.count > 0) {
				// generate an array of MovieRecords
				var updatedMovieRecordArray: [MovieRecord] = []
					
				let prefsCountryString = (UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
				guard let country = MovieCountry(rawValue: prefsCountryString) else { NSLog("queryOperationFinishedUpdatedMovies: Corrupt countrycode \(prefsCountryString)"); return }
					
				for ckRecord in self.updatedCKRecords {
					let newRecord = MovieRecord(country: country)
					newRecord.initWithCKRecord(ckRecord: ckRecord)
					updatedMovieRecordArray.append(newRecord)
				}
					
				// merge both arrays (the existing movies and the updated movies)
				if (self.loadedMovieRecordArray != nil) {
					MovieDatabaseHelper.joinMovieRecordArrays(existingMovies: &(self.loadedMovieRecordArray!), updatedMovies: updatedMovieRecordArray)
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
	fileprivate func cleanUpPosters() {
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
	fileprivate func deleteUnneededPosters(basePath: String, movies: [MovieRecord]) {
		
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
	fileprivate func deleteUnneededYoutubeImages(basePath: String, movies: [MovieRecord]) {
		
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
	fileprivate func downloadMissingPosters(basePath: String, movies: [MovieRecord]) {
		
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
				
				if let sourceUrl = URL(string: sourcePath + posterUrl) {
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
}

