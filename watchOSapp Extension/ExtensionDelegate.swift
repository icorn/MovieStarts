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

        let fileManager = FileManager.default
        guard let documentDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let movieFileNameURL = documentDir.appendingPathComponent(Constants.watchMovieFileName)
        let movieFileNamePath = movieFileNameURL.path

        if fileManager.fileExists(atPath: movieFileNamePath) {

            // set launchstatus to: show movie list
            WatchSessionManager.sharedManager.launchStatus = LaunchStatus.showMovieList

            // clean up thumbnails which are no longer needed
            let loadedDictArray: [NSDictionary]? = NSArray(contentsOfFile: movieFileNamePath) as? [NSDictionary]
            guard let movieDictArray = loadedDictArray else { return }

            var filesInDocDir: [URL]?

            do {
                try filesInDocDir = fileManager.contentsOfDirectory(at: documentDir, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            } catch let error as NSError {
                NSLog("Error reading documents dir: \(error.description)")
                return
            }

            if let filesInDocDir = filesInDocDir {
                for fileInDocDir in filesInDocDir {
                    let filename = fileInDocDir.lastPathComponent

                    if filename.endsWith(".jpg") {
                        // found a thumbnail. now check if it's still needed.
                        if (isThumbnailInFavorites(movieDictArray: movieDictArray, filename: filename) == false) {
                            do {
                                try fileManager.removeItem(at: fileInDocDir)
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
                try WatchSessionManager.sharedManager.updateApplicationContext([Constants.watchAppContextGetDataFromPhone : Constants.watchAppContextValueEveryting as AnyObject])
            } catch let error as NSError {
                NSLog("Error updating AppContext: \(error.description)")
                WatchSessionManager.sharedManager.launchStatus = LaunchStatus.connectError
                return
            }

            // Tell user to start the iPhone app
            print("iPhone is not reachable, movies will come after iPhone is turned on. Tell the user about it.")
            WatchSessionManager.sharedManager.launchStatus = LaunchStatus.userShouldStartPhone
        }
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    private func handleUserActivity(userInfo: [AnyHashable: Any]?) {
        // called if app is launched by glance

        // available in future versions?? See https://forums.developer.apple.com/thread/7633

        //		let rootController = WKExtension.sharedExtension().rootInterfaceController
        //		rootController?.popToRootController()
        //		rootController.doStuffForUserActivity(userInfo)

    }


    /**
     Checks if the given poster-filename belongs to at least one favorite movie.

     - parameter movieDictArray: The array of dictionaries, each representing a favorite movie
     - parameter filename:		The filename to search for
     */
    fileprivate func isThumbnailInFavorites(movieDictArray: [NSDictionary], filename: String) -> Bool {
        for dict in movieDictArray {
            guard let dict = (dict as? [String : AnyObject]) else { continue }
            guard let posterUrl = dict[Constants.dbIdPosterUrl] as? String else { continue }
            
            if posterUrl.contains(filename) {
                return true
            }
        }
        
        return false
    }
    
    
    // for future use, if we want to use notifications with custom actions
    
    /*
     func handleActionWithIdentifier(identifier: String?, forLocalNotification localNotification: UILocalNotification) {
     
     guard let userInfo = localNotification.userInfo else { return }
     
     notificationMovieIDs 	= userInfo[Constants.notificationUserInfoId] as? [String]
     notificationMovieTitles = userInfo[Constants.notificationUserInfoName] as? [String]
     notificationMovieDate	= userInfo[Constants.notificationUserInfoDate] as? String
     notificationAlarmDay	= userInfo[Constants.notificationUserInfoDay] as? Int
     }
     
     */
    
}

