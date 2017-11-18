//
//  AppDelegate.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 11.02.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit
import CloudKit
import Fabric
import Crashlytics

//let log = SwiftyBeaver.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var versionOfPreviousLaunch = Constants.version1_0
	var movieReleaseNotification: UILocalNotification?
	var movieTabBarController: TabBarController? {
		return (window?.rootViewController as? StartViewController)?.myTabBarController
	}
	var settingsTableViewController: SettingsTableViewController? {
		var stvc: SettingsTableViewController?

		if let viewControllersOfRoot = movieTabBarController?.viewControllers {
			for viewControllerOfRoot in viewControllersOfRoot where viewControllerOfRoot is UINavigationController {
				if let viewControllersOfNav = (viewControllerOfRoot as? UINavigationController)?.viewControllers {
					for viewControllerOfNav in viewControllersOfNav where viewControllerOfNav is SettingsTableViewController {
						stvc = viewControllerOfNav as? SettingsTableViewController
						break
					}
				}
			}
		}
		return stvc
	}
	var favoriteViewController: FavoriteViewController? {
		var fvc: FavoriteViewController?
		
		if let viewControllersOfRoot = movieTabBarController?.viewControllers {
			for viewControllerOfRoot in viewControllersOfRoot where viewControllerOfRoot is UINavigationController {
				if let viewControllersOfNav = (viewControllerOfRoot as? UINavigationController)?.viewControllers {
					for viewControllerOfNav in viewControllersOfNav where viewControllerOfNav is FavoriteViewController {
						fvc = viewControllerOfNav as? FavoriteViewController
						break
					}
				}
			}
		}
		return fvc
	}
	

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		// add log destinations. at least one is needed
/*
        SwiftyBeaver stuff
         
		let console = ConsoleDestination()  // log to Xcode Console
//		let file = FileDestination()  // log to default swiftybeaver.log file
		let platform = SBPlatformDestination(appID: "NxnnVL",
		                                     appSecret: "wvDg36mYNrwrqsZ3iw5TtbFz5lmt1cho",
		                                     encryptionKey: "xfjxarkwsscacv7Sglsbl9eYZpc89rji")
		log.addDestination(platform)
		log.addDestination(console)
//		log.addDestination(file)
		
//		log.verbose("not so important")  // prio 1, VERBOSE in silver
//		log.debug("something to debug")  // prio 2, DEBUG in blue
//		log.info("a nice information")   // prio 3, INFO in green
//		log.warning("oh no, that won’t be good")  // prio 4, WARNING in yellow
//		log.error("ouch, an error did occur!")  // prio 5, ERROR in red
*/
        
		// create folders for image asset
		
		let appPathUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.movieStartsGroup)

		if let appPathUrl = appPathUrl {
			let fileManager = FileManager.default

			
			
			// TODO: kürzer!!!!!!
			
			
			
			// create thumbnail folder
			do {
				try fileManager.createDirectory(atPath: appPathUrl.path + Constants.thumbnailFolder,
				                                      withIntermediateDirectories: true, attributes: nil)
			}
			catch let error as NSError {
				NSLog("Error creating folder for thumbnails at \(appPathUrl.path + Constants.thumbnailFolder).")
				NSLog(error.debugDescription)
			}
			
			// create big poster folder
			do {
				try fileManager.createDirectory(atPath: appPathUrl.path + Constants.bigPosterFolder,
				                                      withIntermediateDirectories: true, attributes: nil)
			}
			catch let error as NSError {
				NSLog("Error creating folder for big posters at \(appPathUrl.path + Constants.bigPosterFolder).")
				NSLog(error.debugDescription)
			}

			// create trailer folder
			do {
				try fileManager.createDirectory(atPath: appPathUrl.path + Constants.trailerFolder,
				                                      withIntermediateDirectories: true, attributes: nil)
			}
			catch let error as NSError {
				NSLog("Error creating folder for trailer covers at \(appPathUrl.path + Constants.trailerFolder).")
				NSLog(error.debugDescription)
			}
			
			// create actor thumbnail folder
			do {
				try fileManager.createDirectory(atPath: appPathUrl.path + Constants.actorThumbnailFolder,
				                                      withIntermediateDirectories: true, attributes: nil)
			}
			catch let error as NSError {
				NSLog("Error creating folder for actor thumbnails at \(appPathUrl.path + Constants.actorThumbnailFolder).")
				NSLog(error.debugDescription)
			}
			
			// create actor big picture folder
			do {
				try fileManager.createDirectory(atPath: appPathUrl.path + Constants.actorBigFolder,
				                                      withIntermediateDirectories: true, attributes: nil)
			}
			catch let error as NSError {
				NSLog("Error creating folder for big actor images at \(appPathUrl.path + Constants.actorBigFolder).")
				NSLog(error.debugDescription)
			}
			
			// create director thumbnail folder
			do {
				try fileManager.createDirectory(atPath: appPathUrl.path + Constants.directorThumbnailFolder,
				                                      withIntermediateDirectories: true, attributes: nil)
			}
			catch let error as NSError {
				NSLog("Error creating folder for director thumbnails at \(appPathUrl.path + Constants.directorThumbnailFolder).")
				NSLog(error.debugDescription)
			}
			
			// create director big picture folder
			do {
				try fileManager.createDirectory(atPath: appPathUrl.path + Constants.directorBigFolder,
				                                      withIntermediateDirectories: true, attributes: nil)
			}
			catch let error as NSError {
				NSLog("Error creating folder for big director images at \(appPathUrl.path + Constants.directorBigFolder).")
				NSLog(error.debugDescription)
			}
		}

		// read favorites from file
		let favorites = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsFavorites)
		if let favorites = favorites as? [String] {
			Favorites.IDs = favorites
		}
		
		// set some colors, etc.
		UITabBar.appearance().tintColor = UIColor.darkTürkisColor()
        UITabBar.appearance().barTintColor = UIColor.lightGrayBackgroundColor()
		UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0)], for: UIControlState())
        
		UINavigationBar.appearance().tintColor = UIColor.darkTürkisColor()
        UINavigationBar.appearance().barTintColor = UIColor.lightGrayBackgroundColor()

		// check if use-app-prefs are stored. If not, set them to "false"
		let useImdbApp: Bool? = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsUseImdbApp) as? Bool
		let useYoutubeApp: Bool? = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsUseYoutubeApp) as? Bool
		
		if useImdbApp == nil {
			UserDefaults(suiteName: Constants.movieStartsGroup)?.set(false, forKey: Constants.prefsUseImdbApp)
			UserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
		}
		
		if useYoutubeApp == nil {
			UserDefaults(suiteName: Constants.movieStartsGroup)?.set(false, forKey: Constants.prefsUseYoutubeApp)
			UserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
		}
		
		// start watch session (if there is a watch)
		WatchSessionManager.sharedManager.startSession()
		
		// Handle launching from a notification
		if let launchOptions = launchOptions {
			if let notification = launchOptions[UIApplicationLaunchOptionsKey.localNotification] as? UILocalNotification {
				// save received notification for later
				movieReleaseNotification = notification
			}
		}
		
		// getting version of the last launch to find out if we need to set the "migrate" flag
		
		let oldVersion = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsVersion)

		if let oldVersion = oldVersion as? Int {
			versionOfPreviousLaunch = oldVersion
		}

		// if this is a new version: write it to disc
		if (versionOfPreviousLaunch != Constants.versionCurrent) {
			// write old version to disc
			UserDefaults(suiteName: Constants.movieStartsGroup)?.set(Constants.versionCurrent, forKey: Constants.prefsVersion)
			UserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
			
			// check if movie database exists locally
			
			if (databaseFileExists()) {
				// movie database file exists -> check if we need to migrate the database to a new version
				
				if (versionOfPreviousLaunch < Constants.version2_0) {
					// set the flag in the prefs, read the flag later in MovieTableViewController.
					// special case: if the prefs-entry already exists (from a previously failed update-try from an older version), 
					// don't override it: the database file is from the older version (because previous update failed).
					
					let previousMigrateFromVersion = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsMigrateFromVersion)
					
					if (previousMigrateFromVersion == nil) {
						UserDefaults(suiteName: Constants.movieStartsGroup)?.set(versionOfPreviousLaunch, forKey: Constants.prefsMigrateFromVersion)
						UserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
					}
				}
			}
		}
		
		Fabric.with([Crashlytics.self])
		
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {}
	func applicationDidEnterBackground(_ application: UIApplication) {}
	func applicationWillEnterForeground(_ application: UIApplication) {}
	func applicationDidBecomeActive(_ application: UIApplication) {}
	func applicationWillTerminate(_ application: UIApplication) {}

	
	// MARK: - Handling local notifications
 
	
	func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
		
		if (notificationSettings.types.contains(UIUserNotificationType.alert)) {
			// user has allowed notifications
			if let settings = settingsTableViewController {
				settings.switchNotifications(true)
			}
			else {
				NSLog("Settings dialog not available. This should never happen.")
				UserDefaults(suiteName: Constants.movieStartsGroup)?.set(true, forKey: Constants.prefsNotifications)
				UserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
				NotificationManager.updateFavoriteNotifications(favoriteMovies: movieTabBarController?.favoriteMovies)
			}
		}
		else {
			// user has *not* allowed notifications
			if let settings = settingsTableViewController {
				settings.switchNotifications(false)
			}
			else {
				NSLog("Settings dialog not available. This should never happen.")
				UserDefaults(suiteName: Constants.movieStartsGroup)?.set(false, forKey: Constants.prefsNotifications)
				UserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
				NotificationManager.removeAllFavoriteNotifications()
			}
			
			// warn user
			var messageWindow: MessageWindow?
			
			if let viewForMessage = window {
				messageWindow = MessageWindow(parent: viewForMessage, darkenBackground: true, titleStringId: "NotificationWarnTitle", textStringId: "NotificationWarnText", buttonStringIds: ["Close"],
					handler: { (buttonIndex) -> () in
						messageWindow?.close()
					}
				)
			}
		}
	}

	func application(_ application: UIApplication, didReceive notification: UILocalNotification) {

		guard let userInfo = notification.userInfo,
			  let movieIDs = userInfo[Constants.notificationUserInfoId] as? [String] , movieIDs.count > 0,
			  let movieTitles = userInfo[Constants.notificationUserInfoName] as? [String] , movieTitles.count > 0,
			  let movieDate = userInfo[Constants.notificationUserInfoDate] as? String,
			  let notificationDay = userInfo[Constants.notificationUserInfoDay] as? Int else {
			return
		}

		let state = application.applicationState

		if (state == UIApplicationState.active) {
			// app was in foreground
			
			if (movieTitles.count == 1) {
				// only one movie
				NotificationManager.notifyAboutOneMovie(appDelegate: self, movieID: movieIDs[0], movieTitle: movieTitles[0], movieDate: movieDate, notificationDay: notificationDay)
			}
			else {
				// multiple movies
				NotificationManager.notifyAboutMultipleMovies(appDelegate: self, movieIDs: movieIDs, movieTitles: movieTitles, movieDate: movieDate, notificationDay: notificationDay)
			}
		}
		else if (state == UIApplicationState.inactive) {
			// app was in background, but in memory
			
			if (movieTitles.count == 1) {
				// only one movie
				self.movieTabBarController?.selectedIndex = Constants.tabIndexFavorites
				self.favoriteViewController?.showFavoriteMovie(movieIDs[0])
			}
			else {
				// multiple movies
				NotificationManager.notifyAboutMultipleMovies(appDelegate: self, movieIDs: movieIDs, movieTitles: movieTitles, movieDate: movieDate, notificationDay: notificationDay)
			}
		}
	}

	
	fileprivate func databaseFileExists() -> Bool {
		let fileUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.movieStartsGroup)
		
		if let fileUrl = fileUrl {
			var moviesPlistFile: String
			if fileUrl.path.hasSuffix("/") {
				moviesPlistFile = fileUrl.path + Constants.dbRecordTypeMovie + ".plist"
			}
			else {
				moviesPlistFile = fileUrl.path + "/" + Constants.dbRecordTypeMovie + ".plist"
			}
			
			if (FileManager.default.fileExists(atPath: moviesPlistFile)) {
				return true
			}
		}
		
		return false
	}
    
    
    // MARK: - Handling device orientation
    // The app disables rotation for all view controllers except for a few that opt-in by conforming to the Rotatable protocol

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask
    {
        guard let _ = topViewController(for: window?.rootViewController) as? Rotatable else
        {
            return .portrait
        }
        
        return .all
    }
    
    private func topViewController(for rootViewController: UIViewController!) -> UIViewController?
    {
        guard let rootVC = rootViewController else { return nil }
        
        if rootVC is UITabBarController
        {
            let rootTabBarVC = rootVC as! UITabBarController
            return topViewController(for: rootTabBarVC.selectedViewController)
        }
        else if rootVC is UINavigationController
        {
            let rootNavVC = rootVC as! UINavigationController
            return topViewController(for: rootNavVC.visibleViewController)
        }
        else if let rootPresentedVC = rootVC.presentedViewController
        {
            return topViewController(for: rootPresentedVC)
        }
        
        return rootViewController
    }
}

