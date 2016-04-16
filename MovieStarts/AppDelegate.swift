//
//  AppDelegate.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 11.02.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit
import CloudKit


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
	var favoriteTableViewController: FavoriteTableViewController? {
		var ftvc: FavoriteTableViewController?
		
		if let viewControllersOfRoot = movieTabBarController?.viewControllers {
			for viewControllerOfRoot in viewControllersOfRoot where viewControllerOfRoot is UINavigationController {
				if let viewControllersOfNav = (viewControllerOfRoot as? UINavigationController)?.viewControllers {
					for viewControllerOfNav in viewControllersOfNav where viewControllerOfNav is FavoriteTableViewController {
						ftvc = viewControllerOfNav as? FavoriteTableViewController
						break
					}
				}
			}
		}
		return ftvc
	}
	

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		
		// create folders for image asset
		
		let appPathUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(Constants.movieStartsGroup)

		if let appPathUrl = appPathUrl, absolutePath = appPathUrl.path {
			let fileManager = NSFileManager.defaultManager()

			// create thumbnail folder
			
			do {
				try fileManager.createDirectoryAtPath(absolutePath + Constants.thumbnailFolder, withIntermediateDirectories: true, attributes: nil)
			}
			catch let error as NSError {
				NSLog("Error creating folder for thumbnails at \(absolutePath + Constants.thumbnailFolder).")
				NSLog(error.debugDescription)
			}
			
			// create big poster folder
			
			do {
				try fileManager.createDirectoryAtPath(absolutePath + Constants.bigPosterFolder, withIntermediateDirectories: true, attributes: nil)
			}
			catch let error as NSError {
				NSLog("Error creating folder for big posters at \(absolutePath + Constants.bigPosterFolder).")
				NSLog(error.debugDescription)
			}

			// create trailer folder
			
			do {
				try fileManager.createDirectoryAtPath(absolutePath + Constants.trailerFolder, withIntermediateDirectories: true, attributes: nil)
			}
			catch let error as NSError {
				NSLog("Error creating folder for trailer covers at \(absolutePath + Constants.trailerFolder).")
				NSLog(error.debugDescription)
			}
		}

		// read favorites from file
		let favorites = NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsFavorites)
		if let favorites = favorites as? [String] {
			Favorites.IDs = favorites
		}
		
		// set some colors, etc.
		UITabBar.appearance().tintColor = UIColor(red: 0.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0)
		UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14.0)], forState: .Normal)
		UINavigationBar.appearance().tintColor = UIColor.whiteColor()

		// check if use-app-prefs are stored. If not, set them to "false"
		let useImdbApp: Bool? = NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsUseImdbApp) as? Bool
		let useYoutubeApp: Bool? = NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsUseYoutubeApp) as? Bool
		
		if useImdbApp == nil {
			NSUserDefaults(suiteName: Constants.movieStartsGroup)?.setObject(false, forKey: Constants.prefsUseImdbApp)
			NSUserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
		}
		
		if useYoutubeApp == nil {
			NSUserDefaults(suiteName: Constants.movieStartsGroup)?.setObject(false, forKey: Constants.prefsUseYoutubeApp)
			NSUserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
		}
		
		// start watch session (if there is a watch)
		WatchSessionManager.sharedManager.startSession()
		
		// Handle launching from a notification
		if let launchOptions = launchOptions {
			if let notification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
				// save received notification for later
				movieReleaseNotification = notification
			}
		}
		
		// getting version of the last launch
		
		let oldVersion = NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsVersion)
		
		if let oldVersion = oldVersion as? Int {
			versionOfPreviousLaunch = oldVersion
		}

		// if this is a new version: write it to disc
		if (versionOfPreviousLaunch != Constants.versionCurrent) {
			// write old version to disc
			NSUserDefaults(suiteName: Constants.movieStartsGroup)?.setObject(Constants.versionCurrent, forKey: Constants.prefsVersion)
			NSUserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
			
			// check if movie database exists locally
			
			if (databaseFileExists()) {
				// movie database file exists -> check if we need to migrate the database to a new version
				
				if (versionOfPreviousLaunch < Constants.version1_2) {
					// set in flag in the prefs, read the flag later in MovieTableViewController.
					// special case: if the prefs-entry already exists (from a previously failed update-try from an older version), 
					// don't override it: the database file is from the older version (because previous update failed).
					
					let previousMigrateFromVersion = NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsMigrateFromVersion)
					
					if (previousMigrateFromVersion == nil) {
						NSUserDefaults(suiteName: Constants.movieStartsGroup)?.setObject(versionOfPreviousLaunch, forKey: Constants.prefsMigrateFromVersion)
						NSUserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
					}
				}
			}
		}
		
		return true
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}

	
	// MARK: - Handling local notifications
 
	
	func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
		
		if (notificationSettings.types.contains(UIUserNotificationType.Alert)) {
			// user has allowed notifications
			if let settings = settingsTableViewController {
				settings.switchNotifications(true)
			}
			else {
				NSLog("Settings dialog not available. This should never happen.")
				NSUserDefaults(suiteName: Constants.movieStartsGroup)?.setObject(true, forKey: Constants.prefsNotifications)
				NSUserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
				NotificationManager.updateFavoriteNotifications(movieTabBarController?.favoriteMovies)
			}
		}
		else {
			// user has *not* allowed notifications
			if let settings = settingsTableViewController {
				settings.switchNotifications(false)
			}
			else {
				NSLog("Settings dialog not available. This should never happen.")
				NSUserDefaults(suiteName: Constants.movieStartsGroup)?.setObject(false, forKey: Constants.prefsNotifications)
				NSUserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
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

	func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {

		guard let userInfo = notification.userInfo,
			  let movieIDs = userInfo[Constants.notificationUserInfoId] as? [String] where movieIDs.count > 0,
			  let movieTitles = userInfo[Constants.notificationUserInfoName] as? [String] where movieTitles.count > 0,
			  let movieDate = userInfo[Constants.notificationUserInfoDate] as? String,
			  let notificationDay = userInfo[Constants.notificationUserInfoDay] as? Int else {
			return
		}

		let state = application.applicationState

		if (state == UIApplicationState.Active) {
			// app was in foreground
			
			if (movieTitles.count == 1) {
				// only one movie
				NotificationManager.notifyAboutOneMovie(self, movieID: movieIDs[0], movieTitle: movieTitles[0], movieDate: movieDate, notificationDay: notificationDay)
			}
			else {
				// multiple movies
				NotificationManager.notifyAboutMultipleMovies(self, movieIDs: movieIDs, movieTitles: movieTitles, movieDate: movieDate, notificationDay: notificationDay)
			}
		}
		else if (state == UIApplicationState.Inactive) {
			// app was in background, but in memory
			
			if (movieTitles.count == 1) {
				// only one movie
				self.movieTabBarController?.selectedIndex = Constants.tabIndexFavorites
				self.favoriteTableViewController?.showFavoriteMovie(movieIDs[0])
			}
			else {
				// multiple movies
				NotificationManager.notifyAboutMultipleMovies(self, movieIDs: movieIDs, movieTitles: movieTitles, movieDate: movieDate, notificationDay: notificationDay)
			}
		}
	}

	
	private func databaseFileExists() -> Bool {
		let fileUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(Constants.movieStartsGroup)
		
		if let fileUrl = fileUrl, fileUrlPath = fileUrl.path {
			var moviesPlistFile: String
			if fileUrlPath.hasSuffix("/") {
				moviesPlistFile = fileUrlPath + Constants.dbRecordTypeMovie + ".plist"
			}
			else {
				moviesPlistFile = fileUrlPath + "/" + Constants.dbRecordTypeMovie + ".plist"
			}
			
			if (NSFileManager.defaultManager().fileExistsAtPath(moviesPlistFile)) {
				return true
			}
		}
		
		return false
	}
}

