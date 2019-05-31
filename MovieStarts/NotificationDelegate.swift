//
//  NotificationDelegate.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 16.05.18.
//  Copyright © 2018 Oliver Eichhorn. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit


class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate
{
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        // foreground notification
        showNotification(notification)
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void)
    {
        // background notification
        if (response.actionIdentifier == UNNotificationDefaultActionIdentifier)
        {
            showNotification(response.notification)
        }
        
        completionHandler()
    }
    
    
    private func showNotification(_ notification: UNNotification)
    {
        let userInfo = notification.request.content.userInfo
        
        if let movieIDs = userInfo[Constants.notificationUserInfoId] as? [String],
            let movieTitles = userInfo[Constants.notificationUserInfoName] as? [String],
            let movieDate = userInfo[Constants.notificationUserInfoDate] as? String,
            let notificationDay = userInfo[Constants.notificationUserInfoDay] as? Int,
            movieTitles.count > 0,
            movieIDs.count > 0
        {
            DispatchQueue.main.async {
                if (movieTitles.count == 1)
                {
                    // only one movie
                    NotificationManager.notifyAboutOneMovie(appDelegate: UIApplication.shared.delegate as! AppDelegate,
                                                            movieID: movieIDs[0],
                                                            movieTitle: movieTitles[0],
                                                            movieDate: movieDate,
                                                            notificationDay: notificationDay)
                }
                else
                {
                    // multiple movies
                    NotificationManager.notifyAboutMultipleMovies(appDelegate: UIApplication.shared.delegate as! AppDelegate,
                                                                  movieIDs: movieIDs,
                                                                  movieTitles: movieTitles,
                                                                  movieDate: movieDate,
                                                                  notificationDay: notificationDay)
                }
            }
        }
    }
}
