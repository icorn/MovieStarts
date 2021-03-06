//
//  NotificationManager.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 29.01.16.
//  Copyright © 2016 Oliver Eichhorn. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications


class NotificationManager {

	static let secondsInDay = (60 * 60 * 24) as TimeInterval
	
	
	// MARK: - Public functions
	
	
	static func removeAllFavoriteNotifications()
    {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
		NSLog("Removed all notifications")
	}
	
	static func updateFavoriteNotifications(favoriteMovies: [[MovieRecord]]?)
    {
		let notificationsOn: Bool? = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsNotifications) as? Bool
		
		if let notificationsOn = notificationsOn , notificationsOn == true {
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
		      let notificationDay = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsNotificationDay) as? Int,
		      let notificationTime = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsNotificationTime) as? Int
		else {
			return
		}

		let now = Date()
		var fireMovies: [Date : [MovieRecord]] = [:]
		
		// now put upcoming favorites into date-groups
		for movie in flatMovies {
			// calculate alarm-time for the movie
			guard let releaseTime = movie.releaseDateInLocalTimezone else { continue }
			var alarmTime = releaseTime.addingTimeInterval(TimeInterval(notificationDay) * NotificationManager.secondsInDay)
			alarmTime = alarmTime.setHour(notificationTime)

			// Only add movies whose alarm is in the future
			if (now.compare(alarmTime as Date) == ComparisonResult.orderedAscending) {
				if (fireMovies[alarmTime as Date] == nil) {
					fireMovies[alarmTime as Date] = [movie]
				}
				else {
					fireMovies[alarmTime as Date]?.append(movie)
				}
			}
		}
		
		// add a notification for each group
		for fireDate in fireMovies.keys
        {
            addFavoriteNotification(movies: fireMovies[fireDate], fireDate: fireDate, notificationDay: notificationDay)
		}
        
        NSLog("Updated \(fireMovies.keys.count) notifications")
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
			let movieCountString = NSLocalizedString("\(movieCount)", comment: "").capitalized
			
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
		let messageBody = NotificationManager.generateNotificationText(movieCount: 1, notificationDay: notificationDay, firstMovieTitle: movieTitle, movieDate: movieDate)
		
		var messageWindow: MessageWindow?
		messageWindow = MessageWindow(parent: appDelegate.movieTabBarController!.view, darkenBackground: true, titleStringId: "NotificationMsgWindowTitle",
			textString: messageBody, buttonStringIds: ["Close", "ShowMovie"], handler: { (buttonIndex) -> () in
			
			messageWindow?.close()
			
			if (buttonIndex == 1) {
				appDelegate.movieTabBarController?.selectedIndex = Constants.tabIndexFavorites
				appDelegate.favoriteViewController?.showFavoriteMovie(movieID)
			}
		})
	}
	
	static func notifyAboutMultipleMovies(appDelegate: AppDelegate, movieIDs: [String], movieTitles: [String], movieDate: String, notificationDay: Int) {
		var messageBody = NotificationManager.generateNotificationText(movieCount: movieIDs.count, notificationDay: notificationDay, firstMovieTitle: movieTitles[0], movieDate: movieDate) + ":\n"
		
		for title in movieTitles {
			messageBody += "\n\u{25CF} " + title
		}
		
		var messageWindow: MessageWindow?
		messageWindow = MessageWindow(parent: appDelegate.movieTabBarController!.view, darkenBackground: true, titleStringId: "NotificationMsgWindowTitle",
			textString: messageBody, textStringAlignment: NSTextAlignment.left, buttonStringIds: ["Close"], handler: { (buttonIndex) -> () in
			
			messageWindow?.close()
		})
	}

    
    static func setUserPropertyForNotifications()
    {
        let notificationsOn: Bool? = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsNotifications) as? Bool
        
        if let notificationsOn = notificationsOn, notificationsOn == true
        {
            AnalyticsClient.setPropertyUseNotifications(to: "1")
        }
        else
        {
            AnalyticsClient.setPropertyUseNotifications(to: "0")
        }
    }

    
	// MARK: - Private functions
	
	fileprivate static func addFavoriteNotification(movies: [MovieRecord]?, fireDate: Date, notificationDay: Int)
    {
		guard let movies = movies , movies.count > 0 else { return }
        
        let fireDateComponents = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: fireDateComponents,
                                                    repeats: false)
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("NotificationMsgWindowTitle", comment: "")
        content.body = NotificationManager.generateNotificationText(movieCount: movies.count,
                                                                    notificationDay: notificationDay,
                                                                    firstMovieTitle: movies[0].title[movies[0].currentCountry.languageArrayIndex],
                                                                    movieDate: movies[0].releaseDateStringLong)
        content.sound = UNNotificationSound.default
        
        if (movies.count == 1)
        {
            content.userInfo =
            [
                Constants.notificationUserInfoId     : [movies[0].id],
                Constants.notificationUserInfoName   : [movies[0].title[movies[0].currentCountry.languageArrayIndex]],
                Constants.notificationUserInfoDate   : movies[0].releaseDateStringLong,
                Constants.notificationUserInfoDay    : notificationDay
            ]
            NSLog("Added notification at \(fireDate) for '\(movies[0].title[movies[0].currentCountry.languageArrayIndex])'")
        }
        else
        {
            content.body = content.body + "."
            
            content.userInfo =
            [
                Constants.notificationUserInfoId    : movies.map { $0.id },
                Constants.notificationUserInfoName  : movies.map { $0.title[$0.currentCountry.languageArrayIndex] },
                Constants.notificationUserInfoDate  : movies[0].releaseDateStringLong,
                Constants.notificationUserInfoDay   : notificationDay
            ]
            
            NSLog("Added notification at \(fireDate) for \(movies.count) movies")
        }
		
        let request = UNNotificationRequest(identifier: movies[0].id,
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request,
                                               withCompletionHandler:
            { (error) in
                if let error = error
                {
                    // TODO
                    NSLog("Error adding the notification: \(error.localizedDescription)")
                }
            }
        )
	}
}

