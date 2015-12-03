//
//  WatchSessionManager.swift
//  WatchConnectivityDemo
//
//  Created by Natasha Murashev on 9/3/15.
//  Copyright © 2015 NatashaTheRobot. All rights reserved.
//

import WatchConnectivity


// WSM for the iPhone

class WatchSessionManager: NSObject, WCSessionDelegate {
    
    static let sharedManager = WatchSessionManager()
	private let session: WCSession? = WCSession.isSupported() ? WCSession.defaultSession() : nil
	
    private override init() {
        super.init()
    }
	
	// Activate Session
	func startSession() {
		session?.delegate = self
		session?.activateSession()
	}
	
    private var validSession: WCSession? {
        // paired - the user has to have their device paired to the watch
        // watchAppInstalled - the user must have your watch app installed
		
        if let session = session where session.paired && session.watchAppInstalled {
            return session
        }
        return nil
    }
	
	func sessionWatchStateDidChange(session: WCSession) {
		if validSession != nil {
			// watch app is installed: send all favorites to watch
			print("Watch app was installed.")
			sendAllFavoritesToWatch(true, sendThumbnails: true)
		}
	}
	

	// MARK: Transfer File
	
	
    // Sender
    func transferFile(file: NSURL, metadata: [String : AnyObject]) -> WCSessionFileTransfer? {
        return validSession?.transferFile(file, metadata: metadata)
    }
    
    func session(session: WCSession, didFinishFileTransfer fileTransfer: WCSessionFileTransfer, error: NSError?) {

		// handle filed transfer completion
		
		if let error = error {
			NSLog("Error transfering \(fileTransfer.file.fileURL.absoluteString): \(error.description)")
		}
		else {
			print("Filetransfer successfull")
			if (fileTransfer.file.metadata?[Constants.watchMetadataMovieList] != nil) {
				// successfully transfered a movie list: removed it from phone again
				do {
					try NSFileManager.defaultManager().removeItemAtURL(fileTransfer.file.fileURL)
				} catch let error as NSError {
					NSLog("Error deleting temp. movie list: \(error.description)")
				}
			}
		}
    }
	
	
	// MARK: Application Context

/*
	// Sender
	func updateApplicationContext(applicationContext: [String : AnyObject]) throws {
		if let session = validSession {
			do {
				try session.updateApplicationContext(applicationContext)
			} catch let error {
				throw error
			}
		}
	}
*/
	
	// Receiver
	func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
		
		guard let getAllMovies = applicationContext[Constants.watchAppContextGetAllMovies] as? String else { return }
		
		if (getAllMovies == Constants.watchAppContextValueEveryting) {
			// the watch wants to get all favorites movies with list and all thumbnails
			print("Received 'GetAllMovies everything' call from Watch.")
			sendAllFavoritesToWatch(true, sendThumbnails: true)
		}
		else if (getAllMovies == Constants.watchAppContextValueListOnly) {
			// the watch wants to get all favorites movies, but only the list
			print("Received 'GetAllMovies list-only' call from Watch.")
			sendAllFavoritesToWatch(true, sendThumbnails: false)
		}
		else if (getAllMovies == Constants.watchAppContextValueThumbnailsOnly) {
			// the watch wants to get all favorites movies, but only the thumbnails
			print("Received 'GetAllMovies list-only' call from Watch.")
			sendAllFavoritesToWatch(false, sendThumbnails: true)
		}
	}
	
	
	// MARK: Public functions for sending files to the watch
	
	
	/**
		Sends data of all favorites to the watch.
	
		- parameter sendList:		If TRUE, the favorites list is sent to the watch
		- parameter sendThumbnails:	If TRUE, the thumbnails are sent to the watch
	*/
	func sendAllFavoritesToWatch(sendList: Bool, sendThumbnails: Bool) {
		if (validSession == nil) {
			return
		}
		
		let prefsCountryString = (NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
		guard let country = MovieCountry(rawValue: prefsCountryString) else { return }
		
		let genreDatabase = GenreDatabase(finishHandler: nil, errorHandler: nil)
		let genreDict = genreDatabase.readGenresFromFile()
		
		// transfer favorite thumbnails to watch
		
		let loadedMovieRecordArray = MovieDatabaseHelper.dictArrayToMovieRecordArray(loadMovieListToDictArray(), country: country)
		var favoritesDicts: [NSDictionary] = []
		
		if sendThumbnails {
			print("Transfering thumbnails to the Watch.")
		}
		
		for movie in loadedMovieRecordArray {
			if ((movie.isHidden == false) && Favorites.IDs.contains(movie.id)) {
				favoritesDicts.append(movie.toWatchDictionary(genreDict))

				if sendThumbnails {
					guard let thumbnailUrl = movie.thumbnailURL else { continue }
					guard let thumbnailName = thumbnailUrl.path else { continue }
					
					removeOutstandingThumbnailTransfer(thumbnailName)
					
					if (transferFile(thumbnailUrl, metadata: [Constants.watchMetadataThumbnail : 1]) == nil) {
						NSLog("Error sending tumbnail for \(movie.title) to watch.")
					}
				}
			}
		}
		
		if sendList {
			// write movielist and transfer it to watch
			sendMovieListToWatch(favoritesDicts)
		}
	}
	
	
	/**
		Sends a new movie list and a new thumbnail of the new favorite to the watch.
	
		- parameter newFavorite: The new favorite movie
	*/
	func sendNewFavoriteToWatch(newFavorite: MovieRecord) {
		if (validSession == nil) {
			return
		}
		
		removeOutstandingMovieListTransfers()
		
		// send thumbnail
		
		var title = "NoName"
		
		if (newFavorite.title[newFavorite.currentCountry.languageArrayIndex].characters.count > 0) {
			title = newFavorite.title[newFavorite.currentCountry.languageArrayIndex]
		}
		
		if let thumbnailUrl = newFavorite.thumbnailURL {
			if (transferFile(thumbnailUrl, metadata: [Constants.watchMetadataThumbnail : 1]) == nil) {
				NSLog("Error sending tumbnail for \(title) to watch.")
			}
			else {
				print("Sent thumbnail for \(title)")
			}
		}
		
		sendAllFavoritesToWatch(true, sendThumbnails: false)
	}

	
	/**
		Sends an updated movie list to the watch, after a favorite has been removed.
	
		- parameter removedFavorite: The removed favorite (for later use)
	*/
	func sendRemoveFavoriteToWatch(removedFavorite: MovieRecord) {
		if validSession == nil {
			return
		}
		
		removeOutstandingMovieListTransfers()
		sendAllFavoritesToWatch(true, sendThumbnails: false)
	}

	
	/**
		Sends an updated movie list to the watch.
	*/
	func updateFavoritesOnWatch() {
		if validSession == nil {
			return
		}

		removeOutstandingMovieListTransfers()
		sendAllFavoritesToWatch(true, sendThumbnails: false)
	}
	

	// MARK: Private helper functions
	
	
	/**
		Loads the movie list and returns it as optional array of NSDictionaries.
	
		- returns: An optional array of NSDictionaries, or nil on error
	*/
	private func loadMovieListToDictArray() -> [NSDictionary]? {
		// get plist with movie list and load it
		
		let fileManager = NSFileManager.defaultManager()
		let fileUrl = fileManager.containerURLForSecurityApplicationGroupIdentifier(Constants.movieStartsGroup)
		var moviesPlistPath = ""
		
		guard let fileUrlPath = fileUrl?.path else {
			NSLog("Error getting url for app-group.")
			return nil
		}
		
		moviesPlistPath = fileUrlPath + "/" + Constants.dbRecordTypeMovie + ".plist"

		return NSArray(contentsOfFile: moviesPlistPath) as? [NSDictionary]
	}

	
	/**
		Sends the current favorites as list to the watch.
	
		- parameter favoritesDicts: The array of dictionaries containing the favorites
	*/
	private func sendMovieListToWatch(favoritesDicts: [NSDictionary]) {
		
		print("Transfering movie list file to the Watch.")
		
		let tempFilename = NSUUID().UUIDString
		guard let documentDirUrl = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first else { return }
		let tempPathUrl = documentDirUrl.URLByAppendingPathComponent(tempFilename)
		
		if ((favoritesDicts as NSArray).writeToURL(tempPathUrl, atomically: true) == false) {
			NSLog("Error writing movie list to URL \(tempPathUrl.absoluteString)")
		}
		else {
			if (transferFile(tempPathUrl, metadata: [Constants.watchMetadataMovieList : 1]) == nil) {
				NSLog("Error transfering movie list to watch.")
			}
		}
	}
	
	
	/**
		Removes movie lists from the outstanding queue of file transfers.
	*/
	private func removeOutstandingMovieListTransfers() {
		if let validSession = validSession {
			for transfer in validSession.outstandingFileTransfers {
				if (transfer.file.metadata?[Constants.watchMetadataMovieList] != nil) {
					transfer.cancel()
					print("Removed outstanding movie list from queue.")
				}
			}
		}
	}
	
	
	/**
		Removes the given thumbnail from the outstanding queue of file transfers.
	*/
	private func removeOutstandingThumbnailTransfer(name: String) {
		if let validSession = validSession {
			for transfer in validSession.outstandingFileTransfers {
				if (transfer.file.metadata?[Constants.watchMetadataThumbnail] != nil) {
					guard let nameInQueue = transfer.file.fileURL.path else { continue }

					if (nameInQueue == name) {
						transfer.cancel()
						return
					}
				}
			}
		}
	}
}

