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
		currentTab = MovieTab.nowPlaying

        super.viewDidLoad()
		navigationItem.title = NSLocalizedString("NowPlayingLong", comment: "")
    }
	
	func addMovie(_ newMovie: MovieRecord) {
		tableView.beginUpdates()
		
		var indexForInsert: Int?
		
		for (index, movie) in nowMovies.enumerated() {
			let titleFromArray = movie.sortTitle[movie.currentCountry.languageArrayIndex], newMovieTitle = newMovie.sortTitle[movie.currentCountry.languageArrayIndex]
			
			if newMovieTitle.localizedCaseInsensitiveCompare(titleFromArray) == ComparisonResult.orderedAscending {
				// we found the right index for the new movie
				indexForInsert = index
				break
			}
		}
		
		if let indexForInsert = indexForInsert {
			// insert new movie 
			nowMovies.insert(newMovie, at: indexForInsert)
			tableView.insertRows(at: [IndexPath(row: indexForInsert, section: 0)], with: UITableViewRowAnimation.automatic)
		}
		else {
			nowMovies.append(newMovie)
			tableView.insertRows(at: [IndexPath(row: nowMovies.count-1, section: 0)], with: UITableViewRowAnimation.automatic)
		}
		
		tableView.endUpdates()
	}
	
	
	func removeMovie(_ movieToRemove: MovieRecord) {
		tableView.beginUpdates()
		
		// find the index of the existing movie in the table
		
		var indexForExistingMovie: Int?
		
		for (index, movie) in nowMovies.enumerated() {
			if (movie.id == movieToRemove.id) {
				indexForExistingMovie = index
				break
			}
		}

		if let indexForExistingMovie = indexForExistingMovie {
			nowMovies.remove(at: indexForExistingMovie)
			tableView.deleteRows(at: [IndexPath(row: indexForExistingMovie, section: 0)], with: UITableViewRowAnimation.automatic)
		}
		
		tableView.endUpdates()
	}
	

	func updateMovie(_ updatedMovie: MovieRecord) {
		tableView.beginUpdates()
		
		// find the index of the existing movie in the table
		
		var indexForExistingMovie: Int?
		
		for (index, movie) in nowMovies.enumerated() {
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
				nowMovies.remove(at: indexForExistingMovie)
				
				// find the new position of the movie
				
				var indexForUpdatedMovie: Int?
				
				for (index, movie) in nowMovies.enumerated() {
					let movieTitle = movie.sortTitle[movie.currentCountry.languageArrayIndex]
					
					if updatedMovie.sortTitle[updatedMovie.currentCountry.languageArrayIndex].localizedCaseInsensitiveCompare(movieTitle) == ComparisonResult.orderedAscending {
						// we found the right index for the new movie
						indexForUpdatedMovie = index
						break
					}
				}

				if let indexForUpdatedMovie = indexForUpdatedMovie {
					// move movie to new position. this is two separate actions, hence the endUpdate and beginUpdate.
					nowMovies.insert(updatedMovie, at: indexForUpdatedMovie)
					tableView.moveRow(at: IndexPath(row: indexForExistingMovie, section: 0), to: IndexPath(row: indexForUpdatedMovie, section: 0))
                    tableView.endUpdates()

                    tableView.beginUpdates()
                    tableView.reloadRows(at: [IndexPath(row: indexForUpdatedMovie, section: 0)], with: UITableViewRowAnimation.none)
				}
				else {
 
					// move movie to the end. this is two separate actions, hence the endUpdate and beginUpdate.
					nowMovies.append(updatedMovie)
					tableView.moveRow(at: IndexPath(row: indexForExistingMovie, section: 0), to: IndexPath(row: nowMovies.count-1, section: 0))
                    tableView.endUpdates()

                    tableView.beginUpdates()
                    tableView.reloadRows(at: [IndexPath(row: nowMovies.count-1, section: 0)], with: UITableViewRowAnimation.automatic)
				}
			}
			else if (nowMovies[indexForExistingMovie].hasVisibleChanges(updatedMovie: updatedMovie)) {
				// some data has changed which is shown in the table cell -> change the cell with an animation
				nowMovies[indexForExistingMovie] = updatedMovie
				tableView.reloadRows(at: [IndexPath(row: indexForExistingMovie, section: 0)], with: UITableViewRowAnimation.automatic)
			}
			else {
				// some data has changed which is now visible in the table cell -> change the cell, no animation
				nowMovies[indexForExistingMovie] = updatedMovie
				tableView.reloadRows(at: [IndexPath(row: indexForExistingMovie, section: 0)], with: UITableViewRowAnimation.none)
			}
		}
		
		tableView.endUpdates()
	}

	
	override func updateThumbnail(tmdbId: Int) -> Bool {
		var updated = false
		
		for (index, movie) in nowMovies.enumerated() {
			if (movie.tmdbId == tmdbId) {
				tableView.beginUpdates()
				tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.none)
				tableView.endUpdates()
				updated = true
				break
			}
		}
		
		return updated
	}

}

