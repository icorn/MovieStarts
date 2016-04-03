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
		
		for (index, movie) in nowMovies.enumerate() {
			let titleFromArray = movie.sortTitle[movie.currentCountry.languageArrayIndex], newMovieTitle = newMovie.sortTitle[movie.currentCountry.languageArrayIndex]
			
			if newMovieTitle.localizedCaseInsensitiveCompare(titleFromArray) == NSComparisonResult.OrderedAscending {
				// we found the right index for the new movie
				indexForInsert = index
				break
			}
		}
		
		if let indexForInsert = indexForInsert {
			// insert new movie 
			nowMovies.insert(newMovie, atIndex: indexForInsert)
			tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: indexForInsert, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
		}
		else {
			nowMovies.append(newMovie)
			tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: nowMovies.count-1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
		}
		
		tableView.endUpdates()
	}
	
	
	func removeMovie(movieToRemove: MovieRecord) {
		tableView.beginUpdates()
		
		// find the index of the existing movie in the table
		
		var indexForExistingMovie: Int?
		
		for (index, movie) in nowMovies.enumerate() {
			if (movie.id == movieToRemove.id) {
				indexForExistingMovie = index
				break
			}
		}

		if let indexForExistingMovie = indexForExistingMovie {
			nowMovies.removeAtIndex(indexForExistingMovie)
			tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexForExistingMovie, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
		}
		
		tableView.endUpdates()
	}
	

	func updateMovie(updatedMovie: MovieRecord) {
		tableView.beginUpdates()
		
		// find the index of the existing movie in the table
		
		var indexForExistingMovie: Int?
		
		for (index, movie) in nowMovies.enumerate() {
			if (movie.id == updatedMovie.id) {
				indexForExistingMovie = index
				break
			}
		}
		
		// check for changes
		
		if let indexForExistingMovie = indexForExistingMovie {
			if (nowMovies[indexForExistingMovie].title != updatedMovie.title) {
				// the title has changed. we have to move and update the table cell to a new position.
				
				// remove movie from old position
				nowMovies.removeAtIndex(indexForExistingMovie)
				
				// find the new position of the movie
				
				var indexForUpdatedMovie: Int?
				
				for (index, movie) in nowMovies.enumerate() {
					let movieTitle = movie.sortTitle[movie.currentCountry.languageArrayIndex]
					
					if updatedMovie.sortTitle[updatedMovie.currentCountry.languageArrayIndex].localizedCaseInsensitiveCompare(movieTitle) == NSComparisonResult.OrderedAscending {
						// we found the right index for the new movie
						indexForUpdatedMovie = index
						break
					}
				}

				if let indexForUpdatedMovie = indexForUpdatedMovie {
					// move movie to new position
					nowMovies.insert(updatedMovie, atIndex: indexForUpdatedMovie)
					tableView.moveRowAtIndexPath(NSIndexPath(forRow: indexForExistingMovie, inSection: 0), toIndexPath: NSIndexPath(forRow: indexForUpdatedMovie, inSection: 0))
				}
				else {
					// move movie to the end
					nowMovies.append(updatedMovie)
					tableView.moveRowAtIndexPath(NSIndexPath(forRow: indexForExistingMovie, inSection: 0), toIndexPath: NSIndexPath(forRow: nowMovies.count-1, inSection: 0))
				}
			}
			else if (nowMovies[indexForExistingMovie].hasVisibleChanges(updatedMovie)) {
				// some data has changed which is shown in the table cell -> change the cell with an animation
				nowMovies[indexForExistingMovie] = updatedMovie
				tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexForExistingMovie, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
			}
			else {
				// some data has changed which is now visible in the table cell -> change the cell, no animation
				nowMovies[indexForExistingMovie] = updatedMovie
				tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: indexForExistingMovie, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
			}
		}
		
		tableView.endUpdates()
	}

	
	override func updateThumbnail(tmdbId: Int) -> Bool {
		var updated = false
		
		for (index, movie) in nowMovies.enumerate() {
			if (movie.tmdbId == tmdbId) {
				tableView.beginUpdates()
				tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
				tableView.endUpdates()
				updated = true
				break
			}
		}
		
		return updated
	}

}

