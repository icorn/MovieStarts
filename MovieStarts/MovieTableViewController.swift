//
//  MovieTableViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 11.02.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit
import CloudKit


class MovieTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
	
	var currentTab: MovieTab?

	var movieTabBarController: TabBarController? {
		get {
			return navigationController?.parentViewController as? TabBarController
		}
	}

	var movies: [MovieRecord] {
		get {
			if let tbc = movieTabBarController {
				return tbc.nowMovies
			}
			else {
				return []
			}
		}
		
		set {
			if let tbc = movieTabBarController {
				tbc.nowMovies = newValue
			}
		}
	}
	
	var sections: [String] {
		get {
			if let tbc = movieTabBarController {
				if (currentTab == MovieTab.Upcoming) {
					return tbc.upcomingSections
				}
				else if (currentTab == MovieTab.Favorites) {
					return tbc.favoriteSections
				}
			}
			
			return []
		}
		
		set {
			if let tbc = movieTabBarController {
				if (currentTab == MovieTab.Upcoming) {
					tbc.upcomingSections = newValue
				}
				else if (currentTab == MovieTab.Favorites) {
					tbc.favoriteSections = newValue
				}
			}
		}
	}
	
	var moviesInSections: [[MovieRecord]] {
		get {
			if let tbc = movieTabBarController {
				if (currentTab == MovieTab.Upcoming) {
					return tbc.upcomingMovies
				}
				else if (currentTab == MovieTab.Favorites) {
					return tbc.favoriteMovies
				}
			}
			return []
		}
		
		set {
			if let tbc = movieTabBarController {
				if (currentTab == MovieTab.Upcoming) {
					tbc.upcomingMovies = newValue
				}
				else if (currentTab == MovieTab.Favorites) {
					tbc.favoriteMovies = newValue
				}
			}
		}
	}
	
	
	// MARK: - UIViewController

	override func viewDidLoad() {
        super.viewDidLoad()

		if let movieTabBarController = movieTabBarController {
			self.tableView.reloadData()
		}
		
		tableView.registerNib(UINib(nibName: "MovieTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieTableViewCell")
    }
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		// set status bar style to light
		UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
		setNeedsStatusBarAppearanceUpdate()

		// reload to update favorite-icon if we come back from detail view.
		tableView.reloadData()
	}

	// MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if (currentTab == MovieTab.NowPlaying) {
			return 1
		}
		else {
			return sections.count
		}
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if (moviesInSections.count > section) {
			return moviesInSections[section].count
		}
		else {
			return movies.count
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
	
	// MARK: - UITableView
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieTableViewCell", forIndexPath: indexPath) as! MovieTableViewCell
		
		var movie: MovieRecord?
		
		if moviesInSections.count > 0 {
			movie = moviesInSections[indexPath.section][indexPath.row]
		}
		else {
			movie = movies[indexPath.row]
		}
		
		if let movie = movie {
			cell.posterImage.image = movie.thumbnailImage.0
			cell.titleText.text = movie.title
			cell.tag = Constants.tagTableCell
		
			// show labels with subtitles

			var subtitleLabels = [cell.subtitleText1, cell.subtitleText2, cell.subtitleText3]
			
			for (index, subtitle) in enumerate(movie.subtitleArray) {
				subtitleLabels[index]?.hidden = false
				subtitleLabels[index]?.text = subtitle
			}
			
			// hide unused labels
			
			for (var index = movie.subtitleArray.count; index < subtitleLabels.count; index++) {
				subtitleLabels[index]?.hidden = true
			}
		
			// vertically "center" the labels
			var moveY = (subtitleLabels.count - movie.subtitleArray.count) * 19
			cell.titleTextTopSpaceConstraint.constant = CGFloat(moveY / 2) - 4
			
			// add favorite-icon
			removeFavoriteIconFromCell(cell)
			
			if contains(Favorites.IDs, movie.id) {
				addFavoriteIconToCell(cell)
			}
		}
		
        return cell
    }
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		if let saveStoryboard = self.storyboard {
			var movieController: MovieViewController = saveStoryboard.instantiateViewControllerWithIdentifier("MovieViewController") as! MovieViewController
			
			if moviesInSections.count > 0 {
				movieController.movie = moviesInSections[indexPath.section][indexPath.row]
				NSLog("Selected movie: \(moviesInSections[indexPath.section][indexPath.row])")
			}
			else {
				movieController.movie = movies[indexPath.row]
				NSLog("Selected movie: \(movies[indexPath.row])")
			}
			
			navigationController?.pushViewController(movieController, animated: true)
		}
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 116
	}
	
	override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
		var movieID: String!
		
		// find ID of edited movie
		
		if moviesInSections.count > 0 {
			movieID = moviesInSections[indexPath.section][indexPath.row].id
		}
		else {
			movieID = movies[indexPath.row].id
		}

		// set title and color of button
		
		var title: String!
		var backColor: UIColor!
		
		if (contains(Favorites.IDs, movieID)) {
			title = NSLocalizedString("RemoveFromFavoritesShort", comment: "")
			backColor = UIColor.redColor()
		}
		else {
			title = NSLocalizedString("AddToFavoritesShort", comment: "")
			backColor = UIColor.blueColor()
		}
		
		// define button-action
		
		var favAction: UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: title, handler: {
			(action: UITableViewRowAction!, path: NSIndexPath!) -> () in

				// find out movie id
			
				var movie: MovieRecord!
				if self.moviesInSections.count > 0 {
					movie = self.moviesInSections[indexPath.section][indexPath.row]
				}
				else {
					movie = self.movies[indexPath.row]
				}
			
				// add or remove movie as favorite
			
				var currentCell: UITableViewCell? = self.tableView.cellForRowAtIndexPath(indexPath)

				if (contains(Favorites.IDs, movie.id)) {
					// movie is favorite: remove it as favorite and remove favorite-icon
					Favorites.removeMovieID(movie.id, tabBarController: self.movieTabBarController)
					self.removeFavoriteIconFromCell(currentCell as? MovieTableViewCell)
				}
				else {
					// movie was no favorite: add to as favorite and add favorite-icon
					Favorites.addMovie(movie, tabBarController: self.movieTabBarController)
					self.addFavoriteIconToCell(currentCell as? MovieTableViewCell)
				}
			
				self.tableView.setEditing(false, animated: true)
			
				if self.isKindOfClass(FavoriteTableViewController) {
					// immediately refresh favorite-tableview
					self.viewDidLoad()
				}
			}
		)
		
		favAction.backgroundColor = backColor
		
		return [favAction]
	}
	
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		// Bug in iOS 8: This function is not called, but without it, swiping is not enabled
	}
	
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}

	
	// MARK: - Private helper functions
	
	private func addFavoriteIconToCell(cell: MovieTableViewCell?) {
		if let cell = cell {
			var borderWidth = cell.frame.width - cell.contentView.frame.width
			cell.favoriteCornerHorizontalSpace.constant = -8 - borderWidth
			cell.favoriteCorner.hidden = false
		}
	}
	
	private func removeFavoriteIconFromCell(cell: MovieTableViewCell?) {
		cell?.favoriteCorner.hidden = true
	}

	
	// MARK: - Helper functions for the children classes (TabViewControllers)
	
	func addMovieToExistingSection(foundSectionIndex: Int, newMovie: MovieRecord) {
		
		// add new movie to the section, then sort it
		moviesInSections[foundSectionIndex].append(newMovie)
		moviesInSections[foundSectionIndex].sort {
			if let otherTitle = $1.sortTitle {
				return $0.sortTitle?.localizedCaseInsensitiveCompare(otherTitle) == NSComparisonResult.OrderedAscending
			}
			return true
		}
		
		// get position of new movie after sorting so we can insert it
		for movieIndex in 0 ..< moviesInSections[foundSectionIndex].count {
			if (moviesInSections[foundSectionIndex][movieIndex].id == newMovie.id) {
				tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: movieIndex, inSection: foundSectionIndex)], withRowAnimation: UITableViewRowAnimation.Automatic)
				break
			}
		}
	}
	
	func addMovieToNewSection(sectionName: String, newMovie: MovieRecord) {
		
		if newMovie.isNowPlaying() {
			// special case: insert the "now playing" section (which is always first) with the movie
			sections.insert(sectionName, atIndex: 0)
			moviesInSections.insert([newMovie], atIndex: 0)
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
					if let existingDate = moviesInSections[sectionIndex][0].releaseDate, newFavoriteDate = newMovie.releaseDate {
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
				moviesInSections.insert([newMovie], atIndex: newSectionIndex)
				tableView.insertSections(NSIndexSet(index: newSectionIndex), withRowAnimation: UITableViewRowAnimation.Automatic)
				tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: newSectionIndex)], withRowAnimation: UITableViewRowAnimation.Automatic)
			}
			else {
				// append new section at the end
				sections.append(sectionName)
				moviesInSections.append([newMovie])
				tableView.insertSections(NSIndexSet(index: sections.count-1), withRowAnimation: UITableViewRowAnimation.Automatic)
				tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: sections.count-1)], withRowAnimation: UITableViewRowAnimation.Automatic)
			}
		}
	}

	
	func updateThumbnail(tmdbId: Int) -> Bool {
		var updated = false
		
		for (sectionIndex, section) in enumerate(moviesInSections) {
			for (movieIndex, movie) in enumerate(section) {
				if (movie.tmdbId == tmdbId) {
					tableView.beginUpdates()
					tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: movieIndex, inSection: sectionIndex)], withRowAnimation: UITableViewRowAnimation.None)
					tableView.endUpdates()
					updated = true
					break
				}
			}
		}
		
		return updated
	}

}

