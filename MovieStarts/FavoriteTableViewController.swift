//
//  UpcomingTableViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 11.02.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit

class FavoriteTableViewController: MovieTableViewController {

	override func viewDidLoad() {
		updateMoviesAndSections()
		
		super.viewDidLoad()
		navigationItem.title = NSLocalizedString("FavoritesLong", comment: "")
	}

	
	func updateMoviesAndSections() {
		if let movieTabBarController = movieTabBarController {
			
			// put movies into sections
			
			var previousDate: NSDate? = nil
			var currentSection = -1
			moviesInSections = []
			sections = []
			
			for movie in movieTabBarController.favoriteMovies {
				if ((previousDate == nil) || (previousDate != movie.releaseDate)) {
					// a new sections starts: create new array and add to film-array
					var newMovieArray: [MovieRecord] = []
					moviesInSections.append(newMovieArray)
					sections.append(movie.releaseDateStringLong)
					currentSection++
				}
				
				// add movie to current section
				moviesInSections[currentSection].append(movie)
				previousDate = movie.releaseDate
			}
		}
	}
}

