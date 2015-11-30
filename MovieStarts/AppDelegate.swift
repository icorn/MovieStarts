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
		}
		
		if useYoutubeApp == nil {
			NSUserDefaults(suiteName: Constants.movieStartsGroup)?.setObject(false, forKey: Constants.prefsUseYoutubeApp)
		}
		
		// start watch session (if there is a watch)
		
		WatchSessionManager.sharedManager.startSession()
		
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

}

