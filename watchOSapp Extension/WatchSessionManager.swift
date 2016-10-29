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
	fileprivate let session = WCSession.default()
	var launchStatus: LaunchStatus?
	var rootInterfaceController: MovieInterfaceController?
	
	
	fileprivate override init() {
		super.init()
	}

	// Activate Session
	func startSession() {
		session.delegate = self
		session.activate()
	}
	
	var isReachable: Bool {
		return session.isReachable
	}


	// MARK: Transfer File


	func session(_ session: WCSession, didReceive file: WCSessionFile) {
		
		// move received files from inbox to documents folder
		
		let fileManager = FileManager.default
		guard let documentDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

		if (file.metadata?[Constants.watchMetadataThumbnail] != nil) {
			
			// thumbnail received
			let inputFilename = file.fileURL.lastPathComponent

			let documentFilename = documentDir.appendingPathComponent(inputFilename)
			print("Watch has received thumbnail \(inputFilename)")
			
			do {
				try fileManager.moveItem(at: file.fileURL, to: documentFilename)
				
				// update interface controller
				DispatchQueue.main.async {
					self.rootInterfaceController?.loadMovieDataFromFile()
				}
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

			let documentFilename = documentDir.appendingPathComponent(Constants.watchMovieFileName)
			
			// first delete old movie list
			do {
				try fileManager.removeItem(at: documentFilename)
			} catch {
				// ignoring, because it might be not there and can therefore not be deleted
			}
			
			do {
				try fileManager.moveItem(at: file.fileURL, to: documentFilename)
			} catch let error as NSError {
				NSLog("Error moving movielist file from \(file.fileURL.absoluteString) to \(documentFilename)")
				NSLog("\(error.description)")
			}
			
			// update interface controller
			
			DispatchQueue.main.async {
				self.rootInterfaceController?.loadMovieDataFromFile()
			}
			
			// Now that we have the latest movie list: Check if we have all needed thumbnails
			
			let loadedDictArray: [NSDictionary]? = NSArray(contentsOfFile: documentFilename.path) as? [NSDictionary]
			
			if let loadedDictArray = loadedDictArray {
				
				// get content of document directory
				
				var filesInDocDir: [URL]?
				
				do {
					try filesInDocDir = fileManager.contentsOfDirectory(at: documentDir, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
				} catch let error as NSError {
					NSLog("Error reading documents dir: \(error.description)")
					return
				}
				
				guard let filesInDocDirSave = filesInDocDir else { return }

				// read favorites piece by piece to check thumbnails
				
				for dict in loadedDictArray {
					guard let posterUrl = dict[Constants.dbIdPosterUrl] as? String else { continue }
					var thumbnailFound = false
					
					// check, if this thumbnail of poster-url from the favorite is on the watch
					
					for fileInDocDir in filesInDocDirSave {
						let filename = fileInDocDir.lastPathComponent
						
						if ((filename.endsWith(".jpg")) && posterUrl.contains(filename)) {
							thumbnailFound = true
							break
						}
					}
					
					if (thumbnailFound == false) {
						// thumbnail was not found: ask phone for missing thumbnail
						
						do {
							try WatchSessionManager.sharedManager.updateApplicationContext(
								[Constants.watchAppContextGetDataFromPhone : Constants.watchAppContextValueThumbnailsOnly as AnyObject,
								 Constants.watchAppContextGetThumbnail : posterUrl as AnyObject])
						} catch let error as NSError {
							NSLog("Error updating AppContext (thumbnail): \(error.description)")
						}
					}
				}
			}
		}
	}


	// MARK: Application Context


	func updateApplicationContext(_ applicationContext: [String : AnyObject]) throws {
		do {
			try session.updateApplicationContext(applicationContext)
		} catch let error {
			throw error
		}
	}

	
    // MARK: WCSessionDelegate - Asynchronous Activation

    
	@available(watchOSApplicationExtension 2.2, *)
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

        print("session activated with state: \(activationDidCompleteWithState.rawValue)")
	}
}

