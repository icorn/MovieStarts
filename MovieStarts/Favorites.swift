//
//  Globals.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 25.07.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation
import Crashlytics


struct Favorites {
	
	static var IDs:[String] = []
	
	/**
		Writes the favorites to the device.
	*/
	static func saveFavorites() {
		let userDefaults = NSUserDefaults(suiteName: Constants.movieStartsGroup)
		userDefaults?.setObject(IDs, forKey: Constants.prefsFavorites)
		userDefaults?.synchronize()
	}

	/**
		Add a new movie ID to favorites.
	
		- parameter id:	the new favorite movie id
	*/
	static func addMovie(movie: MovieRecord, tabBarController: TabBarController?) {
		Favorites.IDs.append(movie.id)
		Favorites.saveFavorites()
		tabBarController?.favoriteController?.addFavorite(movie)
		WatchSessionManager.sharedManager.sendNewFavoriteToWatch(movie)

		let imdbId = (movie.imdbId != nil) ? movie.imdbId! : "<unknown ID>"
		let title = (movie.origTitle != nil) ? movie.origTitle! : "<unknown title>"
		
		Answers.logCustomEventWithName("Add Favorite", customAttributes: ["Title": title, "IMDb-ID": imdbId])
	}
	
	/**
		Removes a movie ID from favorites.
	
		- parameter id:	the movie id to be removed
	*/
	static func removeMovie(movie: MovieRecord, tabBarController: TabBarController?) {
		
		for i in 0 ..< Favorites.IDs.count {
			if (Favorites.IDs[i] == movie.id) {
				Favorites.IDs.removeAtIndex(i)
				Favorites.saveFavorites()
				tabBarController?.favoriteController?.removeFavorite(movie.id)
				WatchSessionManager.sharedManager.sendRemoveFavoriteToWatch(movie)
				return
			}
		}
	}

}
