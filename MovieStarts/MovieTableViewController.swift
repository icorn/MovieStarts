//
//  MovieTableViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 11.02.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit
import CloudKit


class MovieTableViewController: UITableViewController {
	
	var currentTab: MovieTab?

	var movieTabBarController: TabBarController? {
		get {
			return navigationController?.parentViewController as? TabBarController
		}
	}
	
	var settingsTableViewController: SettingsTableViewController? {
		var stvc: SettingsTableViewController?
		
		if let viewControllersOfRoot = movieTabBarController?.viewControllers {
			for viewControllerOfRoot in viewControllersOfRoot where viewControllerOfRoot is UINavigationController {
				if let viewControllersOfNav = (viewControllerOfRoot as? UINavigationController)?.viewControllers {
					for viewControllerOfNav in viewControllersOfNav where viewControllerOfNav is SettingsTableViewController {
						stvc = viewControllerOfNav as? SettingsTableViewController
						break
					}
				}
			}
		}
		return stvc
	}

	var genreDict: [Int: String] {
		if let tbc = movieTabBarController {
			return tbc.genreDict
		}
		else {
			return [:]
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
		tableView.registerNib(UINib(nibName: "MovieTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieTableViewCell")
    }
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		// reload to update favorite-icon if we come back from detail view.
		tableView.reloadData()
		
		// check what's "now playing" and what not. this changes after midnight.
		checkNowPlayingStatus()
		
		// if last update is long enough ago: check CloudKit for update
		guard let tbc = movieTabBarController else { return }
		let database = MovieDatabase(recordType: Constants.dbRecordTypeMovie, viewForError: nil)

		if let movies = database.readDatabaseFromFile() {
			tbc.updateMovies(movies, database: database)
		}
		
		// check if we had notifications turned on in the app, but turned off in the system
		let notificationsTurnedOn: Bool? = NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsNotifications) as? Bool
		
		if let notificationsTurnedOn = notificationsTurnedOn where notificationsTurnedOn == true {
			if let currentSettings = UIApplication.sharedApplication().currentUserNotificationSettings() where currentSettings.types.contains(UIUserNotificationType.Alert) {
				// current notifications settings are okay
			}
			else {
				// tell the user, the notifications are no longer working - and it's all his fault ;-)
				var errorWindow: MessageWindow?
				
				if let errorView = self.movieTabBarController?.view {
					errorWindow = MessageWindow(parent: errorView, darkenBackground: true, titleStringId: "NotificationWarnTitle", textStringId: "NotificationWarnText2", buttonStringIds: ["Close"],
						handler: { (buttonIndex) -> () in
							errorWindow?.close()
						}
					)
				}
				
				// also, turn notifications off
				if let settings = settingsTableViewController {
					settings.switchNotifications(false)
				}
				else {
					NSLog("Settings dialog not available. This should never happen.")
					NSUserDefaults(suiteName: Constants.movieStartsGroup)?.setObject(false, forKey: Constants.prefsNotifications)
					NSUserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
					NotificationManager.removeAllFavoriteNotifications()
				}
			}
		}
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
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieTableViewCell", forIndexPath: indexPath) as? MovieTableViewCell
		
		var movie: MovieRecord?
		
		if moviesInSections.count > 0 {
			movie = moviesInSections[indexPath.section][indexPath.row]
		}
		else {
			movie = movies[indexPath.row]
		}
		
		if let movie = movie, cell = cell {
			cell.posterImage.image = movie.thumbnailImage.0
			cell.titleText.text = movie.title[movie.currentCountry.languageArrayIndex]
			cell.tag = Constants.tagTableCell
		
			// show labels with subtitles

			var subtitleLabels = [cell.subtitleText1, cell.subtitleText2, cell.subtitleText3]
			
			for (index, subtitle) in movie.getSubtitleArray(genreDict).enumerate() {
				subtitleLabels[index]?.hidden = false
				subtitleLabels[index]?.text = subtitle
			}
			
			// hide unused labels
			
			for index in movie.getSubtitleArray(genreDict).count ..< subtitleLabels.count {
				subtitleLabels[index]?.hidden = true
			}
		
			// vertically "center" the labels
			let moveY = (subtitleLabels.count - movie.getSubtitleArray(genreDict).count) * 19
			cell.titleTextTopSpaceConstraint.constant = CGFloat(moveY / 2) - 4
			
			// add favorite-icon
			removeFavoriteIconFromCell(cell)
			
			if Favorites.IDs.contains(movie.id) {
				addFavoriteIconToCell(cell)
			}
			
			return cell
		}
		else {
			// this should never happen
			NSLog("*** Error: movie or cell is nil!")
	        return UITableViewCell()
		}
    }
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		if let saveStoryboard = self.storyboard {
			let movieController: MovieViewController? = saveStoryboard.instantiateViewControllerWithIdentifier("MovieViewController") as? MovieViewController
			
			if let movieController = movieController {
				if moviesInSections.count > 0 {
					movieController.movie = moviesInSections[indexPath.section][indexPath.row]
					// print("Selected movie: \(moviesInSections[indexPath.section][indexPath.row])")
				}
				else {
					movieController.movie = movies[indexPath.row]
					// print("Selected movie: \(movies[indexPath.row])")
				}
				
				navigationController?.pushViewController(movieController, animated: true)
			}
			
		}
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 116
	}
	
	override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
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
		
		if (Favorites.IDs.contains(movieID)) {
			title = NSLocalizedString("RemoveFromFavoritesShort", comment: "")
			backColor = UIColor.redColor()
		}
		else {
			title = NSLocalizedString("AddToFavoritesShort", comment: "")
			backColor = UIColor.blueColor()
		}
		
		// define button-action
		
		let favAction: UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: title, handler: {
			[unowned self] (action: UITableViewRowAction, path: NSIndexPath) -> () in

				// find out movie id
			
				var movie: MovieRecord!
				if self.moviesInSections.count > 0 {
					movie = self.moviesInSections[indexPath.section][indexPath.row]
				}
				else {
					movie = self.movies[indexPath.row]
				}
			
				// add or remove movie as favorite
			
				let currentCell: UITableViewCell? = self.tableView.cellForRowAtIndexPath(indexPath)

				if (Favorites.IDs.contains(movie.id)) {
					// movie is favorite: remove it as favorite and remove favorite-icon
					Favorites.removeMovie(movie, tabBarController: self.movieTabBarController)
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
			let borderWidth = cell.frame.width - cell.contentView.frame.width
			cell.favoriteCornerHorizontalSpace.constant = -8 - borderWidth
			cell.favoriteCorner.hidden = false
		}
	}
	
	private func removeFavoriteIconFromCell(cell: MovieTableViewCell?) {
		cell?.favoriteCorner.hidden = true
	}
	
	private func checkNowPlayingStatus() {
		guard let movieTabBarController = movieTabBarController else { return }
		var moviesToDeleteFromUpcomingList: [MovieRecord] = []

		// check upcoming-list and move all now-playing movies to now-playing-list
		for upcomingSection in movieTabBarController.upcomingMovies {
			for upcomingMovie in upcomingSection {
				if (upcomingMovie.isNowPlaying()) {
					// this upcoming movie is no longer upcoming - it's now playing.
					// add movie to "now playing"-list and collect the ID for later deleting
					movieTabBarController.nowPlayingController?.addMovie(upcomingMovie)
					moviesToDeleteFromUpcomingList.append(upcomingMovie)
				}
			}
		}
		
		for movieToDelete in moviesToDeleteFromUpcomingList {
			movieTabBarController.upcomingController?.removeMovie(movieToDelete)
		}

		// check favorite-list and move all now-playing movies to the correct section
		for (sectionIndex, favoriteSection) in (movieTabBarController.favoriteMovies).enumerate() {
			for favoriteMovie in favoriteSection {
				if (favoriteMovie.isNowPlaying()) {
					// this favorite movie is now playing. We check if it's already in the now-playing-section inside the favorites-list.
					if (movieTabBarController.favoriteSections[sectionIndex] != NSLocalizedString("NowPlayingLong", comment: "")) {
						// movie is now-playing, but not in the now-playing-section inside the favorites list: move it!
						movieTabBarController.favoriteController?.removeFavorite(favoriteMovie.id)
						movieTabBarController.favoriteController?.addFavorite(favoriteMovie)
					}
				}
			}
		}
	}

	
	// MARK: - Helper functions for the children classes (TabViewControllers)


	func addMovieToExistingSection(foundSectionIndex: Int, newMovie: MovieRecord) {
		
		// add new movie to the section, then sort it
		moviesInSections[foundSectionIndex].append(newMovie)
		moviesInSections[foundSectionIndex].sortInPlace {
			let otherTitle = $1.sortTitle[$1.currentCountry.languageArrayIndex]
			
			if (otherTitle.characters.count > 0) {
				return $0.sortTitle[$0.currentCountry.languageArrayIndex].localizedCaseInsensitiveCompare(otherTitle) == NSComparisonResult.OrderedAscending
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
					let existingDate = moviesInSections[sectionIndex][0].releaseDate[moviesInSections[sectionIndex][0].currentCountry.countryArrayIndex]
					let newFavoriteDate = newMovie.releaseDate[newMovie.currentCountry.countryArrayIndex]

					if (existingDate.compare(newFavoriteDate) == NSComparisonResult.OrderedDescending) {
						// insert the new section here
						newSectionIndex = sectionIndex
						break
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
		
		for (sectionIndex, section) in moviesInSections.enumerate() {
			for (movieIndex, movie) in section.enumerate() {
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

