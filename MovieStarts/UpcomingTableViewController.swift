//
//  UpcomingTableViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 11.02.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit

class UpcomingTableViewController: MovieTableViewController {

	override func getMovieFromIndexPath(indexPath: NSIndexPath) -> MovieRecord {
		return moviesInSections[indexPath.section][indexPath.row]
	}
	
	override func viewDidLoad() {
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
		
		super.viewDidLoad()
		navigationItem.title = NSLocalizedString("UpcomingLong", comment: "")
	}
	
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return sections.count
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		if (moviesInSections.count > section) {
			return moviesInSections[section].count
		}
		else {
			return 0
		}
	}

	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if (sections.count > section) {
			return sections[section]
		}
		else {
			return nil
		}
	}
}

