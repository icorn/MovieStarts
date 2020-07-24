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
	fileprivate let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil
	
    fileprivate override init() {
        super.init()
    }
	
	// Activate Session
	func startSession() {
		session?.delegate = self
		session?.activate()
	}
	
    fileprivate var validSession: WCSession? {
        // paired - the user has to have their device paired to the watch
        // watchAppInstalled - the user must have your watch app installed
		
		guard let session = session else { return nil }
		
        if session.isPaired && session.isWatchAppInstalled {
            return session
        }

		return nil
    }
	
	func sessionWatchStateDidChange(_ session: WCSession) {
		if validSession != nil {
			// watch app is installed: send all favorites to watch
			print("Watch app was installed.")
			sendAllFavoritesToWatch(sendList: true, sendThumbnails: true)
		}
	}
	

	// MARK: Transfer File
	
	
    // Sender
    func transferFile(_ file: URL, metadata: [String : AnyObject]) -> WCSessionFileTransfer? {
        return validSession?.transferFile(file, metadata: metadata)
    }
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {

		// handle filed transfer completion
		
		if let error = error {
			NSLog("Error transfering \(fileTransfer.file.fileURL.absoluteString): \(error.localizedDescription)")
		}
		else {
			print("Filetransfer successfull")
			if (fileTransfer.file.metadata?[Constants.watchMetadataMovieList] != nil) {
				// successfully transfered a movie list: removed it from phone again
                do {
                    try FileManager.default.removeItem(at: fileTransfer.file.fileURL)
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
	func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
		self.configureDeviceDetailsWithApplicationContext(applicationContext: applicationContext)
	}

    func configureDeviceDetailsWithApplicationContext(applicationContext: [String: Any]) {
        guard let getDataFromPhone = applicationContext[Constants.watchAppContextGetDataFromPhone] as? String else {
            NSLog("Received illegal call from watch: \(applicationContext)")
            return
        }

        if (getDataFromPhone == Constants.watchAppContextValueEveryting) {
            // the watch wants to get all favorites movies with list and all thumbnails
            sendAllFavoritesToWatch(sendList: true, sendThumbnails: true)
        }
        else if (getDataFromPhone == Constants.watchAppContextValueListOnly) {
            // the watch wants to get all favorites movies, but only the list
            sendAllFavoritesToWatch(sendList: true, sendThumbnails: false)
        }
        else if (getDataFromPhone == Constants.watchAppContextValueThumbnailsOnly) {
            // the watch wants to get a thumbnail

            guard let posterUrl = applicationContext[Constants.watchAppContextGetThumbnail] as? String else {
                NSLog("Received no posterUrl for a thumbnail from watch.")
                return
            }
            
            sendThumbnailToWatch(posterUrl)
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
		
		let prefsCountryString = (UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
		guard let country = MovieCountry(rawValue: prefsCountryString) else { return }
		
		let genreDatabase = GenreDatabase(finishHandler: nil, errorHandler: nil)
		let genreDict = genreDatabase.readGenresFromFile()
		
		// transfer favorite thumbnails to watch
		
		let loadedMovieRecordArray = MovieDatabaseHelper.dictArrayToMovieRecordArray(dictArray: loadMovieListToDictArray(), country: country)
		var favoritesDicts: [NSDictionary] = []
		
		if sendThumbnails {
			print("Transfering thumbnails to the Watch.")
		}
		
		for movie in loadedMovieRecordArray {
			if ((movie.isHidden == false) && Favorites.IDs.contains(movie.id)) {
				favoritesDicts.append(movie.toWatchDictionary(genreDict: genreDict) as NSDictionary)

				if sendThumbnails {
					guard let thumbnailUrl = movie.thumbnailURL else { continue }
					removeOutstandingThumbnailTransfer(name: thumbnailUrl.path)
					
					if (transferFile(thumbnailUrl, metadata: [Constants.watchMetadataThumbnail : 1 as AnyObject]) == nil) {
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
		Sends a thumbnail to the watch.
	
		- parameter posterUrl: The posterUrl of the movie whose thumbnail we will send to the watch
	*/
	func sendThumbnailToWatch(_ posterUrl: String) {
		if (validSession == nil) {
			return
		}
		
//		let prefsCountryString = (NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
//		guard let country = MovieCountry(rawValue: prefsCountryString) else { return }
		
		// transfer favorite thumbnails to watch
		
//		let loadedMovieRecordArray = MovieDatabaseHelper.dictArrayToMovieRecordArray(loadMovieListToDictArray(), country: country)
		
		print("Transfering thumbnail for movie \(posterUrl) to the Watch.")
		
		let pathUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.movieStartsGroup)
		guard let thumbnailURL = pathUrl?.appendingPathComponent(Constants.thumbnailFolder + posterUrl) else {
			NSLog("Received illegal thumbnail url from watch (\(posterUrl))")
			return
		}
		
		removeOutstandingThumbnailTransfer(name: thumbnailURL.path)
		
		if (transferFile(thumbnailURL, metadata: [Constants.watchMetadataThumbnail : 1 as AnyObject]) == nil) {
			NSLog("Error sending tumbnail \(thumbnailURL.path) to watch.")
		}
		
/*
		for movie in loadedMovieRecordArray {
			if (movie.id == movieID) {
				guard let thumbnailUrl = movie.thumbnailURL else { continue }
				guard let thumbnailName = thumbnailUrl.path else { continue }
					
				removeOutstandingThumbnailTransfer(thumbnailName)
					
				if (transferFile(thumbnailUrl, metadata: [Constants.watchMetadataThumbnail : 1]) == nil) {
					NSLog("Error sending tumbnail for \(movie.title) to watch.")
				}
			}
		}
*/
	}
	
	
	/**
		Sends a new movie list and a new thumbnail of the new favorite to the watch.
	
		- parameter newFavorite: The new favorite movie
	*/
	func sendNewFavoriteToWatch(_ newFavorite: MovieRecord) {
		if (validSession == nil) {
			return
		}
		
		removeOutstandingMovieListTransfers()
		
		// send thumbnail
		
		var title = "NoName"
		
		if (newFavorite.title[newFavorite.currentCountry.languageArrayIndex].count > 0) {
			title = newFavorite.title[newFavorite.currentCountry.languageArrayIndex]
		}
		
		if let thumbnailUrl = newFavorite.thumbnailURL {
			if (transferFile(thumbnailUrl as URL, metadata: [Constants.watchMetadataThumbnail : 1 as AnyObject]) == nil) {
				NSLog("Error sending tumbnail for \(title) to watch.")
			}
			else {
				print("Sent thumbnail for \(title)")
			}
		}
		
		sendAllFavoritesToWatch(sendList: true, sendThumbnails: false)
	}

	
	/**
		Sends an updated movie list to the watch, after a favorite has been removed.
	
		- parameter removedFavorite: The removed favorite (for later use)
	*/
	func sendRemoveFavoriteToWatch(_ removedFavorite: MovieRecord) {
		if validSession == nil {
			return
		}
		
		removeOutstandingMovieListTransfers()
		sendAllFavoritesToWatch(sendList: true, sendThumbnails: false)
	}

	
	/**
		Sends an updated movie list to the watch.
	*/
	func updateFavoritesOnWatch() {
		if validSession == nil {
			return
		}

		removeOutstandingMovieListTransfers()
		sendAllFavoritesToWatch(sendList: true, sendThumbnails: false)
	}
	

	// MARK: Private helper functions
	
	
	/**
		Loads the movie list and returns it as optional array of NSDictionaries.
	
		- returns: An optional array of NSDictionaries, or nil on error
	*/
	fileprivate func loadMovieListToDictArray() -> [NSDictionary]? {
		// get plist with movie list and load it
		
		let fileManager = FileManager.default
		let fileUrl = fileManager.containerURL(forSecurityApplicationGroupIdentifier: Constants.movieStartsGroup)
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
	fileprivate func sendMovieListToWatch(_ favoritesDicts: [NSDictionary]) {
		
		print("Transfering movie list file to the Watch.")
		
		let tempFilename = UUID().uuidString
		guard let documentDirUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
		let tempPathUrl = documentDirUrl.appendingPathComponent(tempFilename)
		
		if ((favoritesDicts as NSArray).write(to: tempPathUrl, atomically: true) == false) {
			NSLog("Error writing movie list to URL \(tempPathUrl.absoluteString)")
		}
		else {
			if (transferFile(tempPathUrl, metadata: [Constants.watchMetadataMovieList : 1 as AnyObject]) == nil) {
				NSLog("Error transfering movie list to watch.")
			}
		}
	}
	
	
	/**
		Removes movie lists from the outstanding queue of file transfers.
	*/
	fileprivate func removeOutstandingMovieListTransfers() {
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
	fileprivate func removeOutstandingThumbnailTransfer(name: String) {
		if let validSession = validSession {
			for transfer in validSession.outstandingFileTransfers {
				if (transfer.file.metadata?[Constants.watchMetadataThumbnail] != nil) {
					if (transfer.file.fileURL.path == name) {
						transfer.cancel()
						return
					}
				}
			}
		}
	}

	
	// MARK: WCSessionDelegate - Asynchronous Activation
	// The next 3 methods are required in order to support asynchronous session activation; required for quick watch switching.
	
    func session(_: WCSession, activationDidCompleteWith activationDidCompleteWithState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("session activation failed with error: \(error.localizedDescription)")
            return
        }

        /*
            Called when the activation of a session finishes. Your implementation
            should check the value of the activationState parameter to see if
            communication with the counterpart app is possible. When the state is
            WCSessionActivationStateActivated, you may communicate normally with
            the other app.
         */

        if let context = session?.receivedApplicationContext {
            configureDeviceDetailsWithApplicationContext(applicationContext: context)
        }
	}
	
	func sessionDidBecomeInactive(_: WCSession) {
        /*
            The session calls this method when it detects that the user has
            switched to a different Apple Watch. While in the inactive state,
            the session delivers any pending data to your delegate object and
            prevents you from initiating any new data transfers. After the last
            transfer finishes, the session moves to the deactivated state.
            
            Use this method to update any private data structures that might be
            affected by the impending change to the active Apple Watch. For example,
            you might clean up data structures and close files related to
            outgoing content.
        */
	}
	
	func sessionDidDeactivate(_: WCSession) {
        /*
            The session calls this method when there is no more pending data
            to deliver to your app and the previous session can be formally closed.

            iOS apps that process content delivered from their Watch Extension
            should finish processing that content, then call activateSession()
            to initiate a session with the new Apple Watch.
         */

        // Begin the activation process for the new Apple Watch
        WCSession.default.activate()
    }

}

