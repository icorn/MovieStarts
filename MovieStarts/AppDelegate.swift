//
//  AppDelegate.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 11.02.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit
import CloudKit
import UserNotifications

let notificationDelegate = NotificationDelegate()


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var versionOfPreviousLaunch = Constants.version1_0
	var movieReleaseNotification: UNNotificationRequest?
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
	

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
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

        // set some colors, etc.
        UITabBar.appearance().tintColor = UIColor.darkTürkisColor()
        UITabBar.appearance().barTintColor = UIColor.secondarySystemBackground
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)], for: UIControl.State())
        
        UINavigationBar.appearance().tintColor = UIColor.darkTürkisColor()
        UINavigationBar.appearance().barTintColor = UIColor.secondarySystemBackground
        
		// read favorites from file (and send number to analytics)
		let favorites = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsFavorites)
        
		if let favorites = favorites as? [String]
        {
			Favorites.IDs = favorites
            AnalyticsClient.setPropertyNumberOfMoviesInWatchlist(to: favorites.count)
		}
        else
        {
            AnalyticsClient.setPropertyNumberOfMoviesInWatchlist(to: 0)
        }
        
		// check if use-app-prefs are stored. If not, set them to "false"
		let useImdbApp: Bool? = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsUseImdbApp) as? Bool
		let useYoutubeApp: Bool? = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsUseYoutubeApp) as? Bool
		
        if let useImdbApp = useImdbApp
        {
            AnalyticsClient.setPropertyUseImdbApp(to: useImdbApp ? "1" : "0")
        }
        else
        {
			UserDefaults(suiteName: Constants.movieStartsGroup)?.set(false, forKey: Constants.prefsUseImdbApp)
			UserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
            AnalyticsClient.setPropertyUseImdbApp(to: "0")
		}
		
        if let useYoutubeApp = useYoutubeApp
        {
            AnalyticsClient.setPropertyUseYouTubeApp(to: useYoutubeApp ? "1" : "0")
        }
		else
        {
			UserDefaults(suiteName: Constants.movieStartsGroup)?.set(false, forKey: Constants.prefsUseYoutubeApp)
			UserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
            AnalyticsClient.setPropertyUseYouTubeApp(to: "0")
		}

        NotificationManager.setUserPropertyForNotifications()

		// start watch session (if there is a watch)
		WatchSessionManager.sharedManager.startSession()
		
        // set delegate for user notifications
        let center = UNUserNotificationCenter.current()
        center.delegate = notificationDelegate

        // getting version of the last launch to find out if we need to set the "migrate" flag
		
		let oldVersion = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsVersion)

		if let oldVersion = oldVersion as? Int {
			versionOfPreviousLaunch = oldVersion
		}

		// if this is a new version: write it to disc
		if (versionOfPreviousLaunch != Constants.versionCurrent) {
			// write current version to disc
			UserDefaults(suiteName: Constants.movieStartsGroup)?.set(Constants.versionCurrent, forKey: Constants.prefsVersion)
			UserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
			
			// check if movie database exists locally
			
			if (databaseFileExists()) {
				// movie database file exists -> check if we need to migrate the database to a new version
				
				if (versionOfPreviousLaunch < Constants.version1_3) {
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
		
        UIApplication.configureLinearNetworkActivityIndicatorIfNeeded()
        
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {}
	func applicationDidEnterBackground(_ application: UIApplication) {}
	func applicationWillEnterForeground(_ application: UIApplication) {}
	func applicationDidBecomeActive(_ application: UIApplication) {}
	func applicationWillTerminate(_ application: UIApplication) {}

	
    // MARK: - Misc.

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

