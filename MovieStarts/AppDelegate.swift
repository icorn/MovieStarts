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
		
		var appPathUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(Constants.MOVIESTARTS_GROUP)

		if let appPathUrl = appPathUrl, absolutePath = appPathUrl.path {
			var fileManager = NSFileManager.defaultManager()
			var error: NSErrorPointer = nil

			// create thumbnail folder
			
			if (fileManager.createDirectoryAtPath(absolutePath + Constants.THUMBNAIL_FOLDER, withIntermediateDirectories: true, attributes: nil, error: error) == false) {
				println("Error creating folder for thumbnails at \(absolutePath + Constants.THUMBNAIL_FOLDER).")
				if (error != nil) {
					println(error.debugDescription)
				}
			}
			
			// create big poster folder
			
			if (fileManager.createDirectoryAtPath(absolutePath + Constants.BIG_POSTER_FOLDER, withIntermediateDirectories: true, attributes: nil, error: error) == false) {
				println("Error creating folder for big posters at \(absolutePath + Constants.BIG_POSTER_FOLDER).")
				if (error != nil) {
					println(error.debugDescription)
				}
			}
		}

		// read favorites from file
		var favorites: [String]? = NSUserDefaults(suiteName: Constants.MOVIESTARTS_GROUP)?.objectForKey(Constants.PREFS_FAVORITES) as! [String]?
		
		if let favorites = favorites {
			Favorites.IDs = favorites
		}
		
		// set some colors, etc.
		UITabBar.appearance().tintColor = UIColor(red: 0.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0)
		UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14.0)], forState: .Normal)
		UINavigationBar.appearance().tintColor = UIColor.whiteColor()
		UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
		
		// check if use-app-prefs are stored. If not, set them to "false"
		var useImdbApp: Bool? = NSUserDefaults(suiteName: Constants.MOVIESTARTS_GROUP)?.objectForKey(Constants.PREFS_USE_IMDB_APP) as! Bool?
		var useYoutubeApp: Bool? = NSUserDefaults(suiteName: Constants.MOVIESTARTS_GROUP)?.objectForKey(Constants.PREFS_USE_YOUTUBE_APP) as! Bool?
		
		if useImdbApp == nil {
			NSUserDefaults(suiteName: Constants.MOVIESTARTS_GROUP)?.setObject(false, forKey: Constants.PREFS_USE_IMDB_APP)
		}
		
		if useYoutubeApp == nil {
			NSUserDefaults(suiteName: Constants.MOVIESTARTS_GROUP)?.setObject(false, forKey: Constants.PREFS_USE_YOUTUBE_APP)
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

}

