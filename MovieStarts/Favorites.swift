//
//  Globals.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 25.07.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation
//import Crashlytics


struct Favorites {
	
	static var IDs:[String] = []
	
	/**
		Writes the favorites to the device.
	*/
	static func saveFavorites() {
		let userDefaults = UserDefaults(suiteName: Constants.movieStartsGroup)
		userDefaults?.set(IDs, forKey: Constants.prefsFavorites)
		userDefaults?.synchronize()
	}

	/**
		Add a new movie ID to favorites.
	
		- parameter id:	the new favorite movie id
	*/
	static func addMovie(_ movie: MovieRecord, tabBarController: TabBarController?)
    {
		Favorites.IDs.append(movie.id)
		Favorites.saveFavorites()
		tabBarController?.favoriteController?.addFavorite(movie)
		WatchSessionManager.sharedManager.sendNewFavoriteToWatch(movie)

        guard let tabBarController = tabBarController else { return }
        
        // if needed: show push-hint

        let notificationsOn: Bool? = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsNotifications) as? Bool
        
        if let notificationsOn = notificationsOn , notificationsOn == true
        {
            // notifications are turned on, we can return
            return
        }
        
        let pushHintAlreadyShown = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsPushHintAlreadyShown) as? Bool

        if (pushHintAlreadyShown == nil)
        {
            // hint not already shown: show it
            var msgWindow: MessageWindow?

            DispatchQueue.main.async
            {
                msgWindow = MessageWindow(parent: tabBarController.view,
                                            darkenBackground: true,
                                            titleStringId: "PushHintTitle",
                                            textStringId: "PushHintText",
                                            buttonStringIds: ["Close"],
                                            handler: { (buttonIndex) -> () in
                                                msgWindow?.close()
                                            })
            }
                
            UserDefaults(suiteName: Constants.movieStartsGroup)?.set(true, forKey: Constants.prefsPushHintAlreadyShown)
            UserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
        }

		#if RELEASE
/*
			let imdbId = (movie.imdbId != nil) ? movie.imdbId! : "<unknown ID>"
			let title = (movie.origTitle != nil) ? movie.origTitle! : "<unknown title>"
            Answers.logCustomEvent(withName: "Add Favorite", customAttributes: ["Title": title, "IMDb-ID": imdbId])
 */
		#endif
	}
	
	/**
		Removes a movie ID from favorites.
	
		- parameter id:	the movie id to be removed
	*/
    static func removeMovie(_ movie: MovieRecord, tabBarController: TabBarController?) {
		
		for i in 0 ..< Favorites.IDs.count {
			if (Favorites.IDs[i] == movie.id) {
				Favorites.IDs.remove(at: i)
				Favorites.saveFavorites()
				tabBarController?.favoriteController?.removeFavorite(movie.id)
				WatchSessionManager.sharedManager.sendRemoveFavoriteToWatch(movie)
				return
			}
		}
	}

}
