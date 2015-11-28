//
//  ExtensionDelegate.swift
//  watchOS2app Extension
//
//  Created by Oliver Eichhorn on 10.10.15.
//  Copyright © 2015 Oliver Eichhorn. All rights reserved.
//

import WatchKit


class ExtensionDelegate: NSObject, WKExtensionDelegate {

    func applicationDidFinishLaunching() {
		WatchSessionManager.sharedManager.startSession()
		
		// if we have no movie plist: ask the phone
		
		let fileManager = NSFileManager.defaultManager()
		guard let documentDir = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first else { return }
		guard let movieFileNamePath = documentDir.URLByAppendingPathComponent(Constants.watchMovieFileName).path else { return }

		if fileManager.fileExistsAtPath(movieFileNamePath) {
			
			// set launchstatus to: show movie list
			WatchSessionManager.sharedManager.launchStatus = LaunchStatus.ShowMovieList

			// clean up thumbnails which are no longer needed
			let loadedDictArray: [NSDictionary]? = NSArray(contentsOfFile: movieFileNamePath) as? [NSDictionary]
			guard let movieDictArray = loadedDictArray else { return }
			
			var filesInDocDir: [NSURL]?
			
			do {
				try filesInDocDir = fileManager.contentsOfDirectoryAtURL(documentDir, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)
			} catch let error as NSError {
				NSLog("Error reading documents dir: \(error.description)")
				return
			}
			
			if let filesInDocDir = filesInDocDir {
				for fileInDocDir in filesInDocDir {
					guard let filename = fileInDocDir.lastPathComponent else { continue }
					
					if filename.endsWith(".jpg") {
						// found a thumbnail. now check if it's still needed.
						if (isThumbnailInFavorites(movieDictArray, filename: filename) == false) {
							do {
								try fileManager.removeItemAtURL(fileInDocDir)
							} catch let error as NSError {
								NSLog("Error deleting unneeded thumbnail: \(error.description)")
							}
						}
					}
				}
			}
		}
		else {
			// there are no movies on the watch. ask phone for movies (if it's there)
			
			print("No movie list on the Watch, asking Phone to give my some.")
			
			do {
				try WatchSessionManager.sharedManager.updateApplicationContext([Constants.watchAppContextGetAllMovies : Constants.watchAppContextValueEveryting])
			} catch let error as NSError {
				NSLog("Error updating AppContext: \(error.description)")
				WatchSessionManager.sharedManager.launchStatus = LaunchStatus.ConnectError
				return
			}
			
			// Tell user to start the iPhone app
			print("iPhone is not reachable, movies will come after iPhone is turned on. Tell the user about it.")
			WatchSessionManager.sharedManager.launchStatus = LaunchStatus.UserShouldStartPhone
		}
	}

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

	func handleUserActivity(userInfo: [NSObject : AnyObject]?) {
		// called if app is launched by glance
		
		// available in future versions?? See https://forums.developer.apple.com/thread/7633
		
//		let rootController = WKExtension.sharedExtension().rootInterfaceController
//		rootController?.popToRootController()
//		rootController.doStuffForUserActivity(userInfo)
		
	}
	
	
	private func isThumbnailInFavorites(movieDictArray: [NSDictionary], filename: String) -> Bool {
		for dict in movieDictArray {
			guard let dict = (dict as? [String : AnyObject]) else { continue }
			
			for dbIdPosterUrl in Constants.allDbIdPosterUrls {
				guard let posterUrl = dict[dbIdPosterUrl] as? String else { continue }

				if posterUrl.containsString(filename) {
					return true
				}
			}
		}
		
		return false
	}

}

