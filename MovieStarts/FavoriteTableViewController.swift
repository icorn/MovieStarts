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
		updateMoviesAndSections()
		checkForEmptyList()
		
		super.viewDidLoad()
		navigationItem.title = NSLocalizedString("FavoritesLong", comment: "")
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		checkForEmptyList()
	}
	
	func updateMoviesAndSections() {
/*
		if let movieTabBarController = movieTabBarController {
			
			// put movies into sections
			
			var previousDate: NSDate? = nil
			var currentSection = -1
			moviesInSections = []
			sections = []
			
			for movie in movieTabBarController.favoriteMovies {
				if (movie.isNowPlaying() && (currentSection == -1)) {
					// it's a current movie, but there is no section for it yet
					var newMovieArray: [MovieRecord] = []
					moviesInSections.append(newMovieArray)
					sections.append(NSLocalizedString("NowPlayingLong", comment: ""))
					currentSection++
				}
				else if ((movie.isNowPlaying() == false) && ((previousDate == nil) || (previousDate != movie.releaseDate))) {
					// upcoming movies:
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
	}
	
	private func checkForEmptyList() {
		if (count(moviesInSections) == 0) {
			// there are no favorites: show message in background view and hide separators
			
			var noEntriesBackView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.height))
			var headlineHeight: CGFloat = 40
			var textInset: CGFloat = 10
			
			var headlineLabel = UILabel(frame: CGRect(x: 0, y: tableView.frame.height / 4, width: tableView.frame.width, height: headlineHeight))
			headlineLabel.textColor = UIColor.grayColor()
			headlineLabel.font = UIFont.boldSystemFontOfSize(30)
			headlineLabel.text = NSLocalizedString("NoFavorites", comment: "")
			headlineLabel.textAlignment = NSTextAlignment.Center
			noEntriesBackView.addSubview(headlineLabel)
			
			var textLabel = UILabel(frame: CGRect(x: textInset, y: tableView.frame.height / 4 + headlineHeight + 20, width: tableView.frame.width - 2 * textInset, height: 0))
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

		// search apropriate section for the new favorite
		var sectionToSearch: String!
		
		if newFavorite.isNowPlaying() {
			sectionToSearch = NSLocalizedString("NowPlayingLong", comment: "")
		}
		else {
			sectionToSearch = newFavorite.releaseDateStringLong
		}
			
		var foundSectionIndex: Int?
		
		for sectionIndex in 0 ..< sections.count {
			if (sections[sectionIndex] == sectionToSearch) {
				foundSectionIndex = sectionIndex
				break
			}
		}

		if let foundSectionIndex = foundSectionIndex {
			// the section for the new favorite already exists
			addFavoriteToExistingSection(foundSectionIndex, newFavorite: newFavorite)
		}
		else {
			// the section doesn't exist yet
			addFavoriteToNewSection(sectionToSearch, newFavorite: newFavorite)
		}
		
		tableView.endUpdates()
	}

	
	func removeFavorite(removedFavoriteId: String) {
		tableView.beginUpdates()

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
			var indexPath: NSIndexPath = NSIndexPath(forRow: rowId, inSection: sectionId)
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
			
			// remove movie from datasource
			moviesInSections[sectionId].removeAtIndex(rowId)

			// if the section is now empty: remove it also
			if moviesInSections[sectionId].isEmpty {
				// remove section from datasource
				moviesInSections.removeAtIndex(sectionId)
				sections.removeAtIndex(sectionId)
				
				// remove section from table
				var indexSet: NSIndexSet = NSIndexSet(index: sectionId)
				tableView.deleteSections(indexSet, withRowAnimation: UITableViewRowAnimation.Automatic)
			}
		}
		
		tableView.endUpdates()
	}
	
	
	private func addFavoriteToExistingSection(foundSectionIndex: Int, newFavorite: MovieRecord) {
		
		// add new movie to the section, then sort it
		moviesInSections[foundSectionIndex].append(newFavorite)
		moviesInSections[foundSectionIndex].sort {
			if let otherTitle = $1.title {
				return $0.title?.localizedCaseInsensitiveCompare(otherTitle) == NSComparisonResult.OrderedAscending
			}
			return true
		}
		
		// get position of new movie after sorting so we can insert it
		for movieIndex in 0 ..< moviesInSections[foundSectionIndex].count {
			if (moviesInSections[foundSectionIndex][movieIndex].id == newFavorite.id) {
				tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: movieIndex, inSection: foundSectionIndex)], withRowAnimation: UITableViewRowAnimation.Automatic)
				break
			}
		}
	}
	
	
	private func addFavoriteToNewSection(sectionName: String, newFavorite: MovieRecord) {
		
		if newFavorite.isNowPlaying() {
			// special case: insert the "now playing" section (which is always first) with the movie
			sections.insert(sectionName, atIndex: 0)
			moviesInSections.insert([newFavorite], atIndex: 0)
			tableView.insertSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
			tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
		}
		else {
			// normal case: insert a section for the release date with the movie
			// but first check out, at which position the new section should be inserted
			
			var newSectionIndex: Int?
			
			for sectionIndex in 0 ..< moviesInSections.count {
				// from every section, get the first movie an compare releasedates
				if (moviesInSections[sectionIndex].count > 0) {
					if let existingDate = moviesInSections[sectionIndex][0].releaseDate, newFavoriteDate = newFavorite.releaseDate {
						if (existingDate.compare(newFavoriteDate) == NSComparisonResult.OrderedDescending) {
							// insert the new section here
							newSectionIndex = sectionIndex
							break
						}
					}
				}
			}
			
			if let newSectionIndex = newSectionIndex {
				// insert new section
				sections.insert(sectionName, atIndex: newSectionIndex)
				moviesInSections.insert([newFavorite], atIndex: newSectionIndex)
				tableView.insertSections(NSIndexSet(index: newSectionIndex), withRowAnimation: UITableViewRowAnimation.Automatic)
				tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: newSectionIndex)], withRowAnimation: UITableViewRowAnimation.Automatic)
			}
			else {
				// append new section at the end
				sections.append(sectionName)
				moviesInSections.append([newFavorite])
				tableView.insertSections(NSIndexSet(index: sections.count-1), withRowAnimation: UITableViewRowAnimation.Automatic)
				tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: sections.count-1)], withRowAnimation: UITableViewRowAnimation.Automatic)
			}
		}
	}
	
}

