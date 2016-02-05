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

	static let secondsInDay = (60 * 60 * 24) as NSTimeInterval
	
	
	// MARK: - Public functions
	
	
	static func removeAllFavoriteNotifications() {
		UIApplication.sharedApplication().cancelAllLocalNotifications()
		NSLog("Removed all notifications")
	}
	
	static func updateFavoriteNotifications(favoriteMovies: [[MovieRecord]]?) {
		let notificationsOn: Bool? = NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsNotifications) as? Bool
		
		if let notificationsOn = notificationsOn where notificationsOn == true {
			// notifications are turned on, let's proceed
		}
		else {
			// notifications are not turned on
			return
		}
		
		// first clean up the old stuff
		removeAllFavoriteNotifications()
		
		// preparation
		guard let flatMovies = (favoriteMovies?.flatMap { $0 }),
		      let notificationDay = NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsNotificationDay) as? Int,
		      let notificationTime = NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsNotificationTime) as? Int
		else {
			return
		}

		let now = NSDate()
		var fireMovies: [NSDate : [MovieRecord]] = [:]
		
		// now put upcoming favorites into date-groups
		for movie in flatMovies {
			// calculate alarm-time for the movie
			guard let releaseTime = movie.releaseDateInLocalTimezone else { continue }
			var alarmTime = releaseTime.dateByAddingTimeInterval(NSTimeInterval(notificationDay) * NotificationManager.secondsInDay)
			alarmTime = alarmTime.setHour(notificationTime)

			// Only add movies whose alarm is in the future
			if (now.compare(alarmTime) == NSComparisonResult.OrderedAscending) {
				if (fireMovies[alarmTime] == nil) {
					fireMovies[alarmTime] = [movie]
				}
				else {
					fireMovies[alarmTime]?.append(movie)
				}
			}
		}
		
		// add a notification for each group
		for fireDate in fireMovies.keys {
			addFavoriteNotification(fireMovies[fireDate], fireDate: /*now.dateByAddingTimeInterval(30)*/ fireDate, notificationDay: notificationDay)
		}
	}
	
	static func generateNotificationText(movieCount: Int, notificationDay: Int, firstMovieTitle: String, movieDate: String) -> String {
		var retval = ""
		
		if (movieCount == 1) {
			switch(notificationDay) {
			case 0: retval = "\"" + firstMovieTitle + "\" " + NSLocalizedString("OneMovieReleasedToday", comment: "")
			case -1: retval = "\"" + firstMovieTitle + "\" " + NSLocalizedString("OneMovieReleasedTomorrow", comment: "")
			case -2: retval = "\"" + firstMovieTitle + "\" " + NSLocalizedString("OneMovieReleasedAfterTomorrow", comment: "")
			default: retval = "\"" + firstMovieTitle + "\" " + NSLocalizedString("OneMovieReleasedSoon1", comment: "") + movieDate +
				NSLocalizedString("OneMovieReleasedSoon2", comment: "")
			}
		}
		else {
			let movieCountString = NSLocalizedString("\(movieCount)", comment: "").capitalizedString
			
			switch(notificationDay) {
			case 0: retval = "\(movieCountString) " + NSLocalizedString("MoviesReleasedToday", comment: "")
			case -1: retval = "\(movieCountString) " + NSLocalizedString("MoviesReleasedTomorrow", comment: "")
			case -2: retval = "\(movieCountString) " + NSLocalizedString("MoviesReleasedAfterTomorrow", comment: "")
			default: retval = "\(movieCountString) " + NSLocalizedString("MoviesReleasedSoon1", comment: "") + movieDate +
				NSLocalizedString("MoviesReleasedSoon2", comment: "")
			}
		}
		
		return retval
	}
	
	
	static func notifyAboutOneMovie(appDelegate: AppDelegate, movieID: String, movieTitle: String, movieDate: String, notificationDay: Int) {
		let messageBody = NotificationManager.generateNotificationText(1, notificationDay: notificationDay, firstMovieTitle: movieTitle, movieDate: movieDate)
		
		var messageWindow: MessageWindow?
		messageWindow = MessageWindow(parent: appDelegate.movieTabBarController!.view, darkenBackground: true, titleStringId: "NotificationMsgWindowTitle",
			textString: messageBody, buttonStringIds: ["Close", "ShowMovie"], handler: { (buttonIndex) -> () in
			
			messageWindow?.close()
			
			if (buttonIndex == 1) {
				appDelegate.movieTabBarController?.selectedIndex = Constants.tabIndexFavorites
				appDelegate.favoriteTableViewController?.showFavoriteMovie(movieID)
			}
		})
	}
	
	static func notifyAboutMultipleMovies(appDelegate: AppDelegate, movieIDs: [String], movieTitles: [String], movieDate: String, notificationDay: Int) {
		var messageBody = NotificationManager.generateNotificationText(movieIDs.count, notificationDay: notificationDay, firstMovieTitle: movieTitles[0], movieDate: movieDate) + ":\n"
		
		for title in movieTitles {
			messageBody += "\n\u{25CF} " + title
		}
		
		var messageWindow: MessageWindow?
		messageWindow = MessageWindow(parent: appDelegate.movieTabBarController!.view, darkenBackground: true, titleStringId: "NotificationMsgWindowTitle",
			textString: messageBody, textStringAlignment: NSTextAlignment.Left, buttonStringIds: ["Close"], handler: { (buttonIndex) -> () in
			
			messageWindow?.close()
		})
	}


	// MARK: - Private functions

	
	private static func addFavoriteNotification(movies: [MovieRecord]?, fireDate: NSDate, notificationDay: Int) {
		guard let movies = movies where movies.count > 0 else { return }
		
		let notification = UILocalNotification()
		
		notification.fireDate = fireDate
		notification.hasAction = true
		notification.soundName = UILocalNotificationDefaultSoundName
		notification.alertBody = NotificationManager.generateNotificationText(
			movies.count,
			notificationDay: notificationDay,
			firstMovieTitle: movies[0].title[movies[0].currentCountry.languageArrayIndex],
			movieDate: movies[0].releaseDateStringLong)

//		notification.applicationIconBadgeNumber = movies.count
//		notification.timeZone = NSTimeZone.defaultTimeZone()
// 		notification.alertLaunchImage = nil
// 		notification.alertAction = nil // "View" is default
// 		notification.category = nil
//		notification.alertTitle = "Film-Alarm"

		if (movies.count == 1) {
			notification.userInfo = [
				Constants.notificationUserInfoId 	: [movies[0].id],
				Constants.notificationUserInfoName 	: [movies[0].title[movies[0].currentCountry.languageArrayIndex]],
				Constants.notificationUserInfoDate 	: movies[0].releaseDateStringLong,
				Constants.notificationUserInfoDay 	: notificationDay
			]
			NSLog("Added notification at \(fireDate) for '\(movies[0].title[movies[0].currentCountry.languageArrayIndex])'")
		}
		else {
			if let alertBody = notification.alertBody {
				notification.alertBody = alertBody + "."
			}
			
			notification.userInfo = [
				Constants.notificationUserInfoId	: movies.flatMap { $0.id },
				Constants.notificationUserInfoName	: movies.flatMap { $0.title[$0.currentCountry.languageArrayIndex] },
				Constants.notificationUserInfoDate 	: movies[0].releaseDateStringLong,
				Constants.notificationUserInfoDay 	: notificationDay
			]
			NSLog("Added notification at \(fireDate) for \(movies.count) movies")
		}
		
		UIApplication.sharedApplication().scheduleLocalNotification(notification)
	}

}

