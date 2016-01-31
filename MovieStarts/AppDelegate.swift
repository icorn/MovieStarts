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
				
				let alert = UIAlertController(title: notification.alertTitle!, message: notification.alertBody!, preferredStyle: UIAlertControllerStyle.Alert)
				let alertAction = UIAlertAction(title: "OK Blank", style: UIAlertActionStyle.Default, handler: nil)
				alert.addAction(alertAction)
				self.movieTabBarController?.presentViewController(alert, animated: true, completion: nil)
				
				
				
				UITabBar.appearance().tintColor = UIColor(red: 255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
				UINavigationBar.appearance().tintColor = UIColor.greenColor()

				
				
				// TODO: Only setting to 0 if launched by click on notification. Can't be correct. What about starting normal?
				// Then the badge stays.
				
				application.applicationIconBadgeNumber = 0
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
		
/*
		if (notificationSettings.types.contains(UIUserNotificationType.Sound)) {
			NSLog("- Sound")
		}
		if (notificationSettings.types.contains(UIUserNotificationType.Badge)) {
			NSLog("- Badge")
		}
*/
	}
	
	
	func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
		let state = application.applicationState

		if (state == UIApplicationState.Active) {
			// app was in foreground
			let alert = UIAlertController(title: notification.alertTitle!, message: notification.alertBody!, preferredStyle: UIAlertControllerStyle.Alert)
			let alertAction = UIAlertAction(title: "OK Foreground", style: UIAlertActionStyle.Default, handler: nil)
			alert.addAction(alertAction)
			self.movieTabBarController?.presentViewController(alert, animated: true, completion: nil)
		}
		else if (state == UIApplicationState.Inactive) {
			// app was in background, but in memory
			let alert = UIAlertController(title: notification.alertTitle!, message: notification.alertBody!, preferredStyle: UIAlertControllerStyle.Alert)
			let alertAction = UIAlertAction(title: "OK Background", style: UIAlertActionStyle.Default, handler: nil)
			alert.addAction(alertAction)
			self.movieTabBarController?.presentViewController(alert, animated: true, completion: nil)
		}

		// Set icon badge number to zero
		application.applicationIconBadgeNumber = 0
	}

}

