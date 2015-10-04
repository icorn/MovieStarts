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
		super.viewDidLoad()
		navigationItem.title = NSLocalizedString("UpcomingLong", comment: "")
	}

	
	func addMovie(newMovie: MovieRecord) {
		tableView.beginUpdates()
		addMoviePrivate(newMovie)
		tableView.endUpdates()
	}
	
	
	private func addMoviePrivate(newMovie: MovieRecord) {
		// search apropriate section for the new movie
		let sectionToSearchFor = newMovie.releaseDateStringLong
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
	}
	
	
	func removeMovie(movieToRemove: MovieRecord) {
		tableView.beginUpdates()
		
		var indexPathForExistingMovie: NSIndexPath?
		
		for (sectionIndex, section) in moviesInSections.enumerate() {
			for (movieIndex, movie) in section.enumerate() {
				if (movie.id == movieToRemove.id) {
					indexPathForExistingMovie = NSIndexPath(forRow: movieIndex, inSection: sectionIndex)
					break
				}
			}
		}

		if let indexPathForExistingMovie = indexPathForExistingMovie {
			moviesInSections[indexPathForExistingMovie.section].removeAtIndex(indexPathForExistingMovie.row)
			tableView.deleteRowsAtIndexPaths([indexPathForExistingMovie], withRowAnimation: UITableViewRowAnimation.Automatic)
		}
		
		tableView.endUpdates()
	}

	
	func updateMovie(updatedMovie: MovieRecord) {
		tableView.beginUpdates()
		
		// find the index of the existing movie in the table
		
		var indexPathForExistingMovie: NSIndexPath?
		
		for (sectionIndex, section) in moviesInSections.enumerate() {
			for (movieIndex, movie) in section.enumerate() {
				if (movie.id == updatedMovie.id) {
					indexPathForExistingMovie = NSIndexPath(forRow: movieIndex, inSection: sectionIndex)
					break
				}
			}
		}
		
		// check for changes
		
		if let indexPathForExistingMovie = indexPathForExistingMovie {
			if ((moviesInSections[indexPathForExistingMovie.section][indexPathForExistingMovie.row].title != updatedMovie.title) ||
				(moviesInSections[indexPathForExistingMovie.section][indexPathForExistingMovie.row].releaseDate != updatedMovie.releaseDate))
			{
				// the title or the date has changed. we have to move the table cell to a new position.
				
				// remove movie from old position
				moviesInSections[indexPathForExistingMovie.section].removeAtIndex(indexPathForExistingMovie.row)
				tableView.deleteRowsAtIndexPaths([indexPathForExistingMovie], withRowAnimation: UITableViewRowAnimation.Automatic)
				
				// add it at new position
				addMoviePrivate(updatedMovie)
			}
			else if (moviesInSections[indexPathForExistingMovie.section][indexPathForExistingMovie.row].hasVisibleChanges(updatedMovie)) {
				// some data has changed which is shown in the table cell -> change the cell with an animation
				moviesInSections[indexPathForExistingMovie.section][indexPathForExistingMovie.row] = updatedMovie
				tableView.reloadRowsAtIndexPaths([indexPathForExistingMovie], withRowAnimation: UITableViewRowAnimation.Automatic)
			}
			else {
				// some data has changed which is now visible in the table cell -> change the cell, no animation
				moviesInSections[indexPathForExistingMovie.section][indexPathForExistingMovie.row] = updatedMovie
				tableView.reloadRowsAtIndexPaths([indexPathForExistingMovie], withRowAnimation: UITableViewRowAnimation.None)
			}
		}
		
		tableView.endUpdates()
	}

}

