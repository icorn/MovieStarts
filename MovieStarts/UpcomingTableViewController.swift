//
//  UpcomingTableViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 11.02.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit

class UpcomingTableViewController: MovieTableViewController {

	override func viewDidLoad() {
		currentTab = MovieTab.Upcoming

/*
		if let movieTabBarController = movieTabBarController {

			// put movies into sections
			
			var previousDate: NSDate? = nil
			var currentSection = -1
			moviesInSections = []

			for movie in movieTabBarController.upcomingMovies {
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
*/		
		super.viewDidLoad()
		navigationItem.title = NSLocalizedString("UpcomingLong", comment: "")
	}

	
	func addMovie(newMovie: MovieRecord) {
		tableView.beginUpdates()

		// search apropriate section for the new movie
		var sectionToSearchFor = newMovie.releaseDateStringLong
		var foundSectionIndex: Int?
		
		for sectionIndex in 0 ..< sections.count {
			if (sections[sectionIndex] == sectionToSearchFor) {
				foundSectionIndex = sectionIndex
				break
			}
		}
		
		if let foundSectionIndex = foundSectionIndex {
			// the section for the new movie already exists
			addMovieToExistingSection(foundSectionIndex, newMovie: newMovie)
		}
		else {
			// the section doesn't exist yet
			addMovieToNewSection(sectionToSearchFor, newMovie: newMovie)
		}

		tableView.endUpdates()
	}
}

