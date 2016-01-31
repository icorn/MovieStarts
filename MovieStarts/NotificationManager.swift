//
//  NotificationManager.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 29.01.16.
//  Copyright © 2016 Oliver Eichhorn. All rights reserved.
//

import Foundation
import UIKit


class NotificationManager {

	
	// MARK: - Public functions
	
	
	static func removeAllFavoriteNotifications() {
		UIApplication.sharedApplication().cancelAllLocalNotifications()
		NSLog("Removed all notifications")
	}
	
	static func updateFavoriteNotifications(favoriteMovies: [[MovieRecord]]?) {
		// first clean up the old stuff
		removeAllFavoriteNotifications()
		
		let now = NSDate()
		
		NSLog("Now: \(now)")
		
		// now add all the upcoming favorites
		guard let flatMovies = (favoriteMovies?.flatMap { $0 }) else { return }
		
		for movie in flatMovies {
			
			// TODO: Only movies whose alarm is in the future
			
			
			NSLog("\(movie.releaseDate[movie.currentCountry.countryArrayIndex]) for '\(movie.title[movie.currentCountry.countryArrayIndex])'")
			
			
			
			
			addFavoriteNotification(movie)
			
			
			
			
			
			
			// temporary
//			break
		}
	}
	

	// MARK: - Private functions

	
	private static func addFavoriteNotification(favoriteMovie: MovieRecord) {
		let notification = UILocalNotification()
		

		
		
		// temporary
		let fireDate = NSDate().dateByAddingTimeInterval(100)
		
		
		
		
		notification.fireDate = fireDate
		notification.alertBody = "'" + favoriteMovie.title[favoriteMovie.currentCountry.languageArrayIndex] + "' kommt in's Kino!"
		notification.alertTitle = "Film-Alarm"
		notification.hasAction = true
		notification.timeZone = NSTimeZone.defaultTimeZone()
		notification.userInfo = [Constants.notificationUserInfo : favoriteMovie.id]
		notification.soundName = UILocalNotificationDefaultSoundName
		
		// notification.applicationIconBadgeNumber = 1
		// notification.alertLaunchImage = nil
		// notification.alertAction = nil // "View" is default
		// notification.category = nil
		
		UIApplication.sharedApplication().scheduleLocalNotification(notification)
		
		NSLog("Added notification at \(notification.fireDate) for '\(favoriteMovie.title[favoriteMovie.currentCountry.languageArrayIndex])'")
	}
	
	private static func removeFavoriteNotification(favoriteMovie: MovieRecord) {
		if let scheduledNotifications = UIApplication.sharedApplication().scheduledLocalNotifications {
			for notification in scheduledNotifications {
				if notification.userInfo?[Constants.notificationUserInfo] as? String == favoriteMovie.id {
					NSLog("Cancelled notification for '\(favoriteMovie.title[favoriteMovie.currentCountry.languageArrayIndex])'")
					UIApplication.sharedApplication().cancelLocalNotification(notification)
					break
				}
			}
		}
	}

	
}