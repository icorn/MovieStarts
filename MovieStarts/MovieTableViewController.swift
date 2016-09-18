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
			return navigationController?.parent as? TabBarController
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

	var nowMovies: [MovieRecord] {
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
				if (currentTab == MovieTab.upcoming) {
					return tbc.upcomingSections
				}
				else if (currentTab == MovieTab.favorites) {
					return tbc.favoriteSections
				}
			}
			
			return []
		}
		
		set {
			if let tbc = movieTabBarController {
				if (currentTab == MovieTab.upcoming) {
					tbc.upcomingSections = newValue
				}
				else if (currentTab == MovieTab.favorites) {
					tbc.favoriteSections = newValue
				}
			}
		}
	}
	
	var moviesInSections: [[MovieRecord]] {
		get {
			if let tbc = movieTabBarController {
				if (currentTab == MovieTab.upcoming) {
					return tbc.upcomingMovies
				}
				else if (currentTab == MovieTab.favorites) {
					return tbc.favoriteMovies
				}
			}
			return []
		}
		
		set {
			if let tbc = movieTabBarController {
				if (currentTab == MovieTab.upcoming) {
					tbc.upcomingMovies = newValue
				}
				else if (currentTab == MovieTab.favorites) {
					tbc.favoriteMovies = newValue
				}
			}
		}
	}
	
	
	// MARK: - UIViewController

	override func viewDidLoad() {
        super.viewDidLoad()
		tableView.register(UINib(nibName: "MovieTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieTableViewCell")
    }
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		// reload to update favorite-icon if we come back from detail view.
		tableView.reloadData()
		
		// check what's "now playing" and what not. this changes after midnight.
		checkNowPlayingStatus()
	
		if (migrateDatabaseIfNeeded() == false) {
			// no database migration needed: if last update is long enough ago: check CloudKit for update
			guard let tbc = movieTabBarController else { return }
			let databaseUpdater = MovieDatabaseUpdater(recordType: Constants.dbRecordTypeMovie, viewForError: nil)

			if let allMovies = databaseUpdater.readDatabaseFromFile() {
				tbc.updateMovies(allMovies: allMovies, databaseUpdater: databaseUpdater)
			}
		}
		
		// check if we had notifications turned on in the app, but turned off in the system
		let notificationsTurnedOnInSettings: Bool? = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsNotifications) as? Bool
		
		if let notificationsTurnedOnInSettings = notificationsTurnedOnInSettings , notificationsTurnedOnInSettings == true {
			if let currentSettings = UIApplication.shared.currentUserNotificationSettings , currentSettings.types.contains(UIUserNotificationType.alert) {
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
					UserDefaults(suiteName: Constants.movieStartsGroup)?.set(false, forKey: Constants.prefsNotifications)
					UserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
					NotificationManager.removeAllFavoriteNotifications()
				}
			}
		}
	}

	
	// MARK: - UITableViewDataSource

	
    override func numberOfSections(in tableView: UITableView) -> Int {
		if (currentTab == MovieTab.nowPlaying) {
			return 1
		}
		else {
			return sections.count
		}
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if (moviesInSections.count > section) {
			return moviesInSections[section].count
		}
		else {
			return nowMovies.count
		}
    }
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if (sections.count > section) {
			return sections[section]
		}
		else {
			return nil
		}
	}
	
	// MARK: - UITableView
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell", for: indexPath) as? MovieTableViewCell
		
		var movie: MovieRecord?
		
		if moviesInSections.count > 0 {
			movie = moviesInSections[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
		}
		else {
			movie = nowMovies[(indexPath as NSIndexPath).row]
		}
		
		if let movie = movie, let cell = cell {
			cell.posterImage.image = movie.thumbnailImage.0
			cell.titleText.text = movie.title[movie.currentCountry.languageArrayIndex]
			cell.tag = Constants.tagTableCell
		
			// show labels with subtitles

			var subtitleLabels = [cell.subtitleText1, cell.subtitleText2, cell.subtitleText3]
			
			for (index, subtitle) in movie.getSubtitleArray(genreDict: genreDict).enumerated() {
				subtitleLabels[index]?.isHidden = false
				subtitleLabels[index]?.text = subtitle
			}
			
			// hide unused labels
			
			for index in movie.getSubtitleArray(genreDict: genreDict).count ..< subtitleLabels.count {
				subtitleLabels[index]?.isHidden = true
			}
		
			// vertically "center" the labels
			let moveY = (subtitleLabels.count - movie.getSubtitleArray(genreDict: genreDict).count) * 19
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
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if let saveStoryboard = self.storyboard {
			let movieController: MovieViewController? = saveStoryboard.instantiateViewController(withIdentifier: "MovieViewController") as? MovieViewController
			
			if let movieController = movieController {
				if moviesInSections.count > 0 {
					movieController.movie = moviesInSections[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
				}
				else {
					movieController.movie = nowMovies[(indexPath as NSIndexPath).row]
				}
				
				navigationController?.pushViewController(movieController, animated: true)
			}
			
		}
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 116
	}
	
	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		var movieID: String!
		
		// find ID of edited movie
		
		if moviesInSections.count > 0 {
			movieID = moviesInSections[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row].id
		}
		else {
			movieID = nowMovies[(indexPath as NSIndexPath).row].id
		}

		// set title and color of button
		
		var title: String!
		var backColor: UIColor!
		
		if (Favorites.IDs.contains(movieID)) {
			title = NSLocalizedString("RemoveFromFavoritesShort", comment: "")
			backColor = UIColor.red
		}
		else {
			title = NSLocalizedString("AddToFavoritesShort", comment: "")
			backColor = UIColor.blue
		}
		
		// define button-action
		
		let favAction: UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: title, handler: {
			[unowned self] (action: UITableViewRowAction, path: IndexPath) -> () in

				// find out movie id
			
				var movie: MovieRecord!
				if self.moviesInSections.count > 0 {
					movie = self.moviesInSections[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
				}
				else {
					movie = self.nowMovies[(indexPath as NSIndexPath).row]
				}
			
				// add or remove movie as favorite
			
				let currentCell: UITableViewCell? = self.tableView.cellForRow(at: indexPath)

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
			
				if self.isKind(of: FavoriteTableViewController.self) {
					// immediately refresh favorite-tableview
					self.viewDidLoad()
				}
			}
		)
		
		favAction.backgroundColor = backColor
		
		return [favAction]
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		// Bug in iOS 8: This function is not called, but without it, swiping is not enabled
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}

	
	// MARK: - Private helper functions
	
	fileprivate func addFavoriteIconToCell(_ cell: MovieTableViewCell?) {
		if let cell = cell {
			let borderWidth = cell.frame.width - cell.contentView.frame.width
			cell.favoriteCornerHorizontalSpace.constant = -8 - borderWidth
			cell.favoriteCorner.isHidden = false
		}
	}
	
	fileprivate func removeFavoriteIconFromCell(_ cell: MovieTableViewCell?) {
		cell?.favoriteCorner.isHidden = true
	}
	
	fileprivate func checkNowPlayingStatus() {
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
		for (sectionIndex, favoriteSection) in (movieTabBarController.favoriteMovies).enumerated() {
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


	/**
		Checks if we have a new version of the app, which needs to migrate the database (or show some information to the user).
		- returns: TRUE if a database migration will be performed, FALSE otherwise
	*/
	fileprivate func migrateDatabaseIfNeeded() -> Bool {
		
		var retval = false
		
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let tbc = self.movieTabBarController else {
			return retval;
		}

		if tbc.migrationHasFailedInThisSession {
			return retval;
		}
		
		let migrateFromVersion = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsMigrateFromVersion) as? Int

		if let migrateFromVersion = migrateFromVersion , migrateFromVersion < Constants.version2_0 {
			
			// we have to migrate the database from an older version to version 2.0: Get new database fields for all records
			
			appDelegate.versionOfPreviousLaunch = Constants.version2_0
			retval = true
			var updateWindow: MessageWindow?
			var updateCounter = 0
			
			DispatchQueue.main.async {
				updateWindow = MessageWindow(parent: tbc.view,
				                             darkenBackground: true,
				                             titleStringId: "UpdateDatabaseTitle",
				                             textStringId: "UpdateDatabaseText",
											 buttonStringIds: [],
											 handler: { (buttonIndex) -> () in } )
				
				updateWindow?.showProgressIndicator(NSLocalizedString("RatingUpdateStart", comment: ""))
				
				let prefsCountryString = (UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
				guard let country = MovieCountry(rawValue: prefsCountryString) else {
					NSLog("ERROR getting country from preferences")
					return
				}
				
				let databaseMigrator = MovieDatabaseMigrator(recordType: Constants.dbRecordTypeMovie, viewForError: self.view)
				
				databaseMigrator.getMigrationMovies(
					country: country,
					updateMovieHandler: { [unowned self] (movie: MovieRecord) in
						
						// update the just received movie
						updateCounter += 1
						var updated = false
						
						for (nowIndex, nowMovie) in self.nowMovies.enumerated() {
							if (nowMovie.tmdbId == movie.tmdbId) {
								self.nowMovies[nowIndex].migrate(updateRecord: movie, updateKeys: databaseMigrator.queryKeys)
								updated = true
								break
							}
						}
						
						if (updated == false) {
							for (upcomingSectionIndex, upcomingMovieSection) in tbc.upcomingMovies.enumerated() {
								for (upcomingMovieIndex, upcomingMovie) in upcomingMovieSection.enumerated() {
									if (upcomingMovie.tmdbId == movie.tmdbId) {
										tbc.upcomingMovies[upcomingSectionIndex][upcomingMovieIndex].migrate(updateRecord: movie, updateKeys: databaseMigrator.queryKeys)
										break
									}
								}
							}
						}
						
						for (favoriteSectionIndex, favoriteMovieSection) in tbc.favoriteMovies.enumerated() {
							for (favoriteMovieIndex, favoriteMovie) in favoriteMovieSection.enumerated() {
								if (favoriteMovie.tmdbId == movie.tmdbId) {
									tbc.favoriteMovies[favoriteSectionIndex][favoriteMovieIndex].migrate(updateRecord: movie, updateKeys: databaseMigrator.queryKeys)
									break
								}
							}
						}
						
						updateWindow?.updateProgressIndicator("\(updateCounter) " + NSLocalizedString("RatingUpdateProgress", comment: ""))
					},
					
					completionHandler: { (movies: [MovieRecord]?) in
						UIApplication.shared.isNetworkActivityIndicatorVisible = false
						DispatchQueue.main.async {
							updateWindow?.close()
						}
						
						// Don't forget to remove the migrate-flag from the prefs
						UserDefaults(suiteName: Constants.movieStartsGroup)?.removeObject(forKey: Constants.prefsMigrateFromVersion)
						UserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
					},
					
					errorHandler: { (errorMessage: String) in
						UIApplication.shared.isNetworkActivityIndicatorVisible = false
						DispatchQueue.main.async {
							
							// error in migration
							updateWindow?.close()
							tbc.migrationHasFailedInThisSession = true
							
							// tell user about the error
							var infoWindow: MessageWindow?
							
							DispatchQueue.main.async {
								infoWindow = MessageWindow(parent: tbc.view, darkenBackground: true, titleStringId: "UpdateFailedHeadline", textStringId: "UpdateFailedText",
									buttonStringIds: ["Close"], handler: { (buttonIndex) -> () in
										infoWindow?.close()
									}
								)
							}
						}
						
						NSLog(errorMessage)
					}
				)
			}
		}
		
		return retval
	}
	
	
	// MARK: - Helper functions for the children classes (TabViewControllers)


	func addMovieToExistingSection(foundSectionIndex: Int, newMovie: MovieRecord) {
		
		// add new movie to the section, then sort it
		moviesInSections[foundSectionIndex].append(newMovie)
		moviesInSections[foundSectionIndex].sort {
			let otherTitle = $1.sortTitle[$1.currentCountry.languageArrayIndex]
			
			if (otherTitle.characters.count > 0) {
				return $0.sortTitle[$0.currentCountry.languageArrayIndex].localizedCaseInsensitiveCompare(otherTitle) == ComparisonResult.orderedAscending
			}
			return true
		}
		
		// get position of new movie after sorting so we can insert it
		for movieIndex in 0 ..< moviesInSections[foundSectionIndex].count {
			if (moviesInSections[foundSectionIndex][movieIndex].id == newMovie.id) {
				tableView.insertRows(at: [IndexPath(row: movieIndex, section: foundSectionIndex)], with: UITableViewRowAnimation.automatic)
				break
			}
		}
	}
	
	func addMovieToNewSection(sectionName: String, newMovie: MovieRecord) {
		
		if newMovie.isNowPlaying() {
			// special case: insert the "now playing" section (which is always first) with the movie
			sections.insert(sectionName, at: 0)
			moviesInSections.insert([newMovie], at: 0)
			tableView.insertSections(IndexSet(integer: 0), with: UITableViewRowAnimation.automatic)
			tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.automatic)
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

					if (existingDate.compare(newFavoriteDate as Date) == ComparisonResult.orderedDescending) {
						// insert the new section here
						newSectionIndex = sectionIndex
						break
					}
				}
			}
			
			if let newSectionIndex = newSectionIndex {
				// insert new section
				sections.insert(sectionName, at: newSectionIndex)
				moviesInSections.insert([newMovie], at: newSectionIndex)
				tableView.insertSections(IndexSet(integer: newSectionIndex), with: UITableViewRowAnimation.automatic)
				tableView.insertRows(at: [IndexPath(row: 0, section: newSectionIndex)], with: UITableViewRowAnimation.automatic)
			}
			else {
				// append new section at the end
				sections.append(sectionName)
				moviesInSections.append([newMovie])
				tableView.insertSections(IndexSet(integer: sections.count-1), with: UITableViewRowAnimation.automatic)
				tableView.insertRows(at: [IndexPath(row: 0, section: sections.count-1)], with: UITableViewRowAnimation.automatic)
			}
		}
	}

	func updateThumbnail(tmdbId: Int) -> Bool {
		var updated = false
		
		for (sectionIndex, section) in moviesInSections.enumerated() {
			for (movieIndex, movie) in section.enumerated() {
				if (movie.tmdbId == tmdbId) {
					tableView.beginUpdates()
					tableView.reloadRows(at: [IndexPath(row: movieIndex, section: sectionIndex)], with: UITableViewRowAnimation.none)
					tableView.endUpdates()
					updated = true
					break
				}
			}
		}
		
		return updated
	}

}

