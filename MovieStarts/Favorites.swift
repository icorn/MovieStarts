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
		var userDefaults = NSUserDefaults(suiteName: Constants.MOVIESTARTS_GROUP)
		userDefaults?.setObject(IDs, forKey: Constants.PREFS_FAVORITES)
		userDefaults?.synchronize()
	}

	/**
		Add a new movie ID to favorites.
	
		:param: id	the new favorite movie id
	*/
	static func addMovie(movie: MovieRecord, tabBarController: TabBarController?) {
		Favorites.IDs.append(movie.id)
		Favorites.saveFavorites()
		tabBarController?.favoriteController?.addFavorite(movie)
	}
	
	/**
		Removes a movie ID from favorites.
	
		:param: id	the movie id to be removed
	*/
	static func removeMovieID(id: String, tabBarController: TabBarController?) {
		for (var i=0; i < Favorites.IDs.count; i++) {
			if (Favorites.IDs[i] == id) {
				Favorites.IDs.removeAtIndex(i)
				Favorites.saveFavorites()
				tabBarController?.favoriteController?.removeFavorite(id)
				return
			}
		}
	}

}
