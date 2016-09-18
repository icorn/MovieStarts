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
		currentTab = MovieTab.upcoming
		super.viewDidLoad()
		navigationItem.title = NSLocalizedString("UpcomingLong", comment: "")
	}

	
	func addMovie(_ newMovie: MovieRecord) {
		tableView.beginUpdates()
		addMoviePrivate(newMovie)
		tableView.endUpdates()
	}
	
	
	fileprivate func addMoviePrivate(_ newMovie: MovieRecord) {
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
			addMovieToExistingSection(foundSectionIndex: foundSectionIndex, newMovie: newMovie)
		}
		else {
			// the section doesn't exist yet
			addMovieToNewSection(sectionName: sectionToSearchFor, newMovie: newMovie)
		}
	}
	
	
	func removeMovie(_ movieToRemove: MovieRecord) {
		tableView.beginUpdates()
		
		var indexPathForExistingMovie: IndexPath?
		
		for (sectionIndex, section) in moviesInSections.enumerated() {
			for (movieIndex, movie) in section.enumerated() {
				if (movie.id == movieToRemove.id) {
					indexPathForExistingMovie = IndexPath(row: movieIndex, section: sectionIndex)
					break
				}
			}
		}

		if let indexPathForExistingMovie = indexPathForExistingMovie {
			moviesInSections[(indexPathForExistingMovie as NSIndexPath).section].remove(at: (indexPathForExistingMovie as NSIndexPath).row)
			
			// if the section is now empty: remove it also
			if moviesInSections[(indexPathForExistingMovie as NSIndexPath).section].isEmpty {
				// remove section from datasource
				moviesInSections.remove(at: (indexPathForExistingMovie as NSIndexPath).section)
				sections.remove(at: (indexPathForExistingMovie as NSIndexPath).section)
				
				// remove section from table
				let indexSet: IndexSet = IndexSet(integer: (indexPathForExistingMovie as NSIndexPath).section)
				tableView.deleteSections(indexSet, with: UITableViewRowAnimation.automatic)
			}
			
			tableView.deleteRows(at: [indexPathForExistingMovie], with: UITableViewRowAnimation.automatic)
		}
		
		tableView.endUpdates()
	}

	
	func updateMovie(_ updatedMovie: MovieRecord) {
		tableView.beginUpdates()
		
		// find the index of the existing movie in the table
		
		var indexPathForExistingMovie: IndexPath?
		
		for (sectionIndex, section) in moviesInSections.enumerated() {
			for (movieIndex, movie) in section.enumerated() {
				if (movie.id == updatedMovie.id) {
					indexPathForExistingMovie = IndexPath(row: movieIndex, section: sectionIndex)
					break
				}
			}
		}
		
		// check for changes
		
		if let indexPathForExistingMovie = indexPathForExistingMovie {
			if ((moviesInSections[(indexPathForExistingMovie as NSIndexPath).section][(indexPathForExistingMovie as NSIndexPath).row].title != updatedMovie.title) ||
				(moviesInSections[(indexPathForExistingMovie as NSIndexPath).section][(indexPathForExistingMovie as NSIndexPath).row].releaseDate != updatedMovie.releaseDate))
			{
				// the title or the date has changed. we have to move the table cell to a new position.
				
				// remove movie from old position
				moviesInSections[(indexPathForExistingMovie as NSIndexPath).section].remove(at: (indexPathForExistingMovie as NSIndexPath).row)
				tableView.deleteRows(at: [indexPathForExistingMovie], with: UITableViewRowAnimation.automatic)
				
				// add it at new position
				addMoviePrivate(updatedMovie)
			}
			else if (moviesInSections[(indexPathForExistingMovie as NSIndexPath).section][(indexPathForExistingMovie as NSIndexPath).row].hasVisibleChanges(updatedMovie: updatedMovie)) {
				// some data has changed which is shown in the table cell -> change the cell with an animation
				moviesInSections[(indexPathForExistingMovie as NSIndexPath).section][(indexPathForExistingMovie as NSIndexPath).row] = updatedMovie
				tableView.reloadRows(at: [indexPathForExistingMovie], with: UITableViewRowAnimation.automatic)
			}
			else {
				// some data has changed which is now visible in the table cell -> change the cell, no animation
				moviesInSections[(indexPathForExistingMovie as NSIndexPath).section][(indexPathForExistingMovie as NSIndexPath).row] = updatedMovie
				tableView.reloadRows(at: [indexPathForExistingMovie], with: UITableViewRowAnimation.none)
			}
		}
		
		tableView.endUpdates()
	}

}

