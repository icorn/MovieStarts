//
//  NowTableViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 14.07.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit

class NowTableViewController: MovieTableViewController {

	override func viewDidLoad() {
		currentTab = MovieTab.NowPlaying

        super.viewDidLoad()
		navigationItem.title = NSLocalizedString("NowPlayingLong", comment: "")
    }

	func addMovie(newMovie: MovieRecord) {
		tableView.beginUpdates()
		
		var indexForInsert: Int?
		
		for movieIndex in 0 ..< movies.count {
			if let titleFromArray = movies[movieIndex].title, newMovieTitle = newMovie.title {
				if newMovieTitle.localizedCaseInsensitiveCompare(titleFromArray) == NSComparisonResult.OrderedAscending {
					// we found the right index for the new movie
					indexForInsert = movieIndex
					break
				}
			}
		}
		
		if let indexForInsert = indexForInsert {
			// insert new movie 
			movies.insert(newMovie, atIndex: indexForInsert)
			tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: indexForInsert, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
		}
		else {
			movies.append(newMovie)
			tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: movies.count-1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
		}
		
		tableView.endUpdates()
	}

}
