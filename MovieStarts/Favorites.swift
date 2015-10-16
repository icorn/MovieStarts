//
//  Globals.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 25.07.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation

struct Favorites {
	
	static var IDs:[String] = []
	
	/**
		Writes the favorites to the device.
	*/
	static func saveFavorites() {
		let userDefaults = NSUserDefaults(suiteName: Constants.MOVIESTARTS_GROUP)
		userDefaults?.setObject(IDs, forKey: Constants.PREFS_FAVORITES)
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
	}
	
	/**
		Removes a movie ID from favorites.
	
		- parameter id:	the movie id to be removed
	*/
	static func removeMovie(movie: MovieRecord, tabBarController: TabBarController?) {
		for (var i=0; i < Favorites.IDs.count; i++) {
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
