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
		currentTab = MovieTab.Favorites
		checkForEmptyList()
		
		super.viewDidLoad()
		navigationItem.title = NSLocalizedString("FavoritesLong", comment: "")
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		checkForEmptyList()
	}
	
	private func checkForEmptyList() {
		if (moviesInSections.count == 0) {
			// there are no favorites: show message in background view and hide separators
			
			let noEntriesBackView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.height))
			let headlineHeight: CGFloat = 40
			let textInset: CGFloat = 10
			
			let headlineLabel = UILabel(frame: CGRect(x: 0, y: tableView.frame.height / 4, width: tableView.frame.width, height: headlineHeight))
			headlineLabel.textColor = UIColor.grayColor()
			headlineLabel.font = UIFont.boldSystemFontOfSize(30)
			headlineLabel.text = NSLocalizedString("NoFavorites", comment: "")
			headlineLabel.textAlignment = NSTextAlignment.Center
			noEntriesBackView.addSubview(headlineLabel)
			
			let textLabel = UILabel(frame: CGRect(x: textInset, y: tableView.frame.height / 4 + headlineHeight + 20, width: tableView.frame.width - 2 * textInset, height: 0))
			textLabel.textColor = UIColor.grayColor()
			textLabel.font = UIFont.boldSystemFontOfSize(18)
			textLabel.text = NSLocalizedString("HowToAddFavorites", comment: "")
			textLabel.textAlignment = NSTextAlignment.Center
			textLabel.numberOfLines = 0
			textLabel.sizeToFit()
			noEntriesBackView.addSubview(textLabel)
			
			tableView.separatorStyle =  UITableViewCellSeparatorStyle.None
			tableView.backgroundView = noEntriesBackView
		}
		else {
			// there are favorites: no background view and normal separators
			
			tableView.backgroundView = nil
			tableView.separatorStyle =  UITableViewCellSeparatorStyle.SingleLine
		}
	}
	
	
	func addFavorite(newFavorite: MovieRecord) {
		tableView.beginUpdates()
		addFavoritePrivate(newFavorite)
		tableView.endUpdates()
	}

	private func addFavoritePrivate(newFavorite: MovieRecord) {
		// search apropriate section for the new favorite
		var sectionToSearchFor: String!
		
		if newFavorite.isNowPlaying() {
			sectionToSearchFor = NSLocalizedString("NowPlayingLong", comment: "")
		}
		else {
			sectionToSearchFor = newFavorite.releaseDateStringLong
		}
		
		var foundSectionIndex: Int?
		
		for sectionIndex in 0 ..< sections.count {
			if (sections[sectionIndex] == sectionToSearchFor) {
				foundSectionIndex = sectionIndex
				break
			}
		}
		
		if let foundSectionIndex = foundSectionIndex {
			// the section for the new favorite already exists
			addMovieToExistingSection(foundSectionIndex, newMovie: newFavorite)
		}
		else {
			// the section doesn't exist yet
			addMovieToNewSection(sectionToSearchFor, newMovie: newFavorite)
		}
		
	}
	
	func removeFavorite(removedFavoriteId: String) {
		tableView.beginUpdates()
		removeFavoritePrivate(removedFavoriteId)
		tableView.endUpdates()
	}
	
	
	private func removeFavoritePrivate(removedFavoriteId: String) {
		var rowId: Int?
		var sectionId: Int?
		
		// search favorite
		for sectionIndex: Int in 0 ..< moviesInSections.count {
			for movieIndex: Int in 0 ..< moviesInSections[sectionIndex].count {
				if (moviesInSections[sectionIndex][movieIndex].id == removedFavoriteId) {
					rowId = movieIndex
					sectionId = sectionIndex
					break
				}
			}
		}
		
		if let rowId = rowId, sectionId = sectionId {
			// remove cell
			let indexPath: NSIndexPath = NSIndexPath(forRow: rowId, inSection: sectionId)
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
			
			// remove movie from datasource
			moviesInSections[sectionId].removeAtIndex(rowId)
			
			// if the section is now empty: remove it also
			if moviesInSections[sectionId].isEmpty {
				// remove section from datasource
				moviesInSections.removeAtIndex(sectionId)
				sections.removeAtIndex(sectionId)
				
				// remove section from table
				let indexSet: NSIndexSet = NSIndexSet(index: sectionId)
				tableView.deleteSections(indexSet, withRowAnimation: UITableViewRowAnimation.Automatic)
			}
		}
	}
	
	
	func updateFavorite(updatedMovie: MovieRecord) {
		tableView.beginUpdates()
		
		// find the index of the existing movie in the table
		
		var indexPathForUpdateMovie: NSIndexPath?
		
		for (sectionIndex, section) in moviesInSections.enumerate() {
			for (movieIndex, movie) in section.enumerate() {
				if (movie.id == updatedMovie.id) {
					indexPathForUpdateMovie = NSIndexPath(forRow: movieIndex, inSection: sectionIndex)
					break
				}
			}
		}
		
		// check for changes
		
		if let indexPathForUpdateMovie = indexPathForUpdateMovie {
			if ((moviesInSections[indexPathForUpdateMovie.section][indexPathForUpdateMovie.row].title != updatedMovie.title) ||
				(moviesInSections[indexPathForUpdateMovie.section][indexPathForUpdateMovie.row].releaseDate != updatedMovie.releaseDate))
			{
				// the title or the date has changed. we have to move the table cell to a new position.
				removeFavoritePrivate(updatedMovie.id)
				addFavoritePrivate(updatedMovie)
			}
			else if (moviesInSections[indexPathForUpdateMovie.section][indexPathForUpdateMovie.row].hasVisibleChanges(updatedMovie)) {
				// some data has changed which is shown in the table cell -> change the cell with an animation
				moviesInSections[indexPathForUpdateMovie.section][indexPathForUpdateMovie.row] = updatedMovie
				tableView.reloadRowsAtIndexPaths([indexPathForUpdateMovie], withRowAnimation: UITableViewRowAnimation.Automatic)
			}
			else {
				// some data has changed which is now visible in the table cell -> change the cell, no animation
				moviesInSections[indexPathForUpdateMovie.section][indexPathForUpdateMovie.row] = updatedMovie
				tableView.reloadRowsAtIndexPaths([indexPathForUpdateMovie], withRowAnimation: UITableViewRowAnimation.None)
			}
		}
		
		tableView.endUpdates()
		
		WatchSessionManager.sharedManager.updateFavoritesOnWatch()
	}
	
}

