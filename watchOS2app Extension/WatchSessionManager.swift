//
//  WatchSessionManager.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 12.10.15.
//  Copyright © 2015 Oliver Eichhorn. All rights reserved.
//

import WatchConnectivity


// WSM for the Watch

class WatchSessionManager: NSObject, WCSessionDelegate {
	
	static let sharedManager = WatchSessionManager()
	private let session = WCSession.defaultSession()
	var launchStatus: LaunchStatus?
	var rootInterfaceController: MovieInterfaceController?
	
	
	private override init() {
		super.init()
	}

	// Activate Session
	func startSession() {
		session.delegate = self
		session.activateSession()
	}
	
	var isReachable: Bool {
		return session.reachable
	}


	// MARK: Transfer File

	
	func session(session: WCSession, didReceiveFile file: WCSessionFile) {
		
		// move received files from inbox to documents folder
		
		let fileManager = NSFileManager.defaultManager()
		guard let documentDir = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first else { return }

		if (file.metadata?[Constants.watchMetadataThumbnail] != nil) {
			
			// thumbnail received
			
			print("Watch has received a thumbnail.")
			
			guard let inputFilename = file.fileURL.lastPathComponent else { return }
			let documentFilename = documentDir.URLByAppendingPathComponent(inputFilename)

			do {
				try fileManager.moveItemAtURL(file.fileURL, toURL: documentFilename)
			} catch let error as NSError {
				if ((error.domain == NSCocoaErrorDomain) && (error.code == NSFileWriteFileExistsError)) {
					// ignoring, because it's okay it it's already there
				}
				else {
					NSLog("Error moving thumbnail file from \(file.fileURL.absoluteString) to \(documentFilename)")
					NSLog("\(error.description)")
				}
			}
		}
		else if (file.metadata?[Constants.watchMetadataMovieList] != nil) {
			
			// movie list received - store it!
			
			print("Watch has received a movie list.")

			let documentFilename = documentDir.URLByAppendingPathComponent(Constants.watchMovieFileName)
			
			// first delete old movie list
			do {
				try fileManager.removeItemAtURL(documentFilename)
			} catch {
				// ignoring, because it might be not there and can therefore not be deleted
			}
			
			do {
				try fileManager.moveItemAtURL(file.fileURL, toURL: documentFilename)
			} catch let error as NSError {
				NSLog("Error moving movielist file from \(file.fileURL.absoluteString) to \(documentFilename)")
				NSLog("\(error.description)")
			}
			
			// update interface controller
			
			dispatch_async(dispatch_get_main_queue()) {
				self.rootInterfaceController?.loadMovieDataFromFile()
			}
			
			// Now that we have the latest movie list: Check if we have all needed thumbnails
			
			guard let documentFilenamePath = documentFilename.path else { return }
			let loadedDictArray: [NSDictionary]? = NSArray(contentsOfFile: documentFilenamePath) as? [NSDictionary]
			
			if let loadedDictArray = loadedDictArray {
				
				// get content of document directory
				
				var filesInDocDir: [NSURL]?
				
				do {
					try filesInDocDir = fileManager.contentsOfDirectoryAtURL(documentDir, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)
				} catch let error as NSError {
					NSLog("Error reading documents dir: \(error.description)")
					return
				}
				
				guard let filesInDocDirSave = filesInDocDir else { return }

				// read favorites piece by piece
				
				for dict in loadedDictArray {
					guard let favPosterUrl = dict[Constants.DB_ID_POSTER_URL] as? String else { continue }
					var thumbnailFound = false
					
					// check, if this thumbnail of poster-url from the favorite is on the watch
					
					for fileInDocDir in filesInDocDirSave {
						guard let filename = fileInDocDir.lastPathComponent where filename.endsWith(".jpg") else { continue }

						if favPosterUrl.containsString(filename) {
							thumbnailFound = true
							break
						}
					}
					
					if (thumbnailFound == false) {
						// a thumbnail was not found: ask phone for thumbnails
						// TODO: be smarter: collect the IDs of the missing thumbnails and ask for only those
						
						do {
							try WatchSessionManager.sharedManager.updateApplicationContext([Constants.watchAppContextGetAllMovies : Constants.watchAppContextValueThumbnailsOnly])
						} catch let error as NSError {
							NSLog("Error updating AppContext (thumbnails only): \(error.description)")
						}
						
						break
					}
				}
			}
		}
	}


	// MARK: Application Context

	
	func updateApplicationContext(applicationContext: [String : AnyObject]) throws {
		do {
			try session.updateApplicationContext(applicationContext)
		} catch let error {
			throw error
		}
	}

	func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
		dispatch_async(dispatch_get_main_queue()) {
			// make sure to put on the main queue to update UI!
		}
	}

}

