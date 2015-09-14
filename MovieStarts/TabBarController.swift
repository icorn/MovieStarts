//
//  TabBarController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 24.02.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit
import CloudKit


class TabBarController: UITabBarController {

	var nowMovies: [MovieRecord] = []
	var upcomingMovies: [[MovieRecord]] = []
	var upcomingSections: [String] = []
	var favoriteMovies: [[MovieRecord]] = []
	var favoriteSections: [String] = []
	
	let userDefaults = NSUserDefaults(suiteName: Constants.MOVIESTARTS_GROUP)

	@IBOutlet weak var movieTabBar: UITabBar!

	
	// MARK: - UIViewController

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		if let saveItems = movieTabBar.items {
			if (saveItems.count == 4) {
				
				// set tab bar titles
				
				(saveItems[0] as! UITabBarItem).title = NSLocalizedString("NowPlayingTabBar", comment: "")
				(saveItems[1] as! UITabBarItem).title = NSLocalizedString("UpcomingTabBar", comment: "")
				(saveItems[2] as! UITabBarItem).title = NSLocalizedString("FavoritesTabBar", comment: "")
				(saveItems[3] as! UITabBarItem).title = NSLocalizedString("SettingsTabBar", comment: "")
				
				// set tab bar images

				(saveItems[0] as! UITabBarItem).image = UIImage(named: "Video.png")
				(saveItems[1] as! UITabBarItem).image = UIImage(named: "Calendar.png")
				(saveItems[2] as! UITabBarItem).image = UIImage(named: "favorite.png")
				(saveItems[3] as! UITabBarItem).image = UIImage(named: "Settings.png")
			}
		}
    }
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	override func supportedInterfaceOrientations() -> Int {
		
		if let svc = selectedViewController {
			return svc.supportedInterfaceOrientations()
		}
		else {
			return Int(UIInterfaceOrientationMask.Portrait.rawValue)
		}
	}
	
	
	/**
		Puts all movies into the categories now, upcoming, and/or favorites.
	
		:param: allMovies	All the movies to put into categories
	*/
	func setUpMovies(allMovies: [MovieRecord]) {
		
		// iterate over all movies and sort them into one of three lists (and ignore the ones without release date)
		
		nowMovies = []
		var upcoming: [MovieRecord] = []
		var favorites: [MovieRecord] = []
		
		for movie in allMovies {
			if let saveDate = movie.releaseDate {
				if movie.isNowPlaying() {
					nowMovies.append(movie)
				}
				else {
					upcoming.append(movie)
				}
				
				if (contains(Favorites.IDs, movie.id)) {
					favorites.append(movie)
				}
			}
		}
		
		nowMovies.sort {
			if let otherTitle = $1.sortTitle {
				return $0.sortTitle?.localizedCaseInsensitiveCompare(otherTitle) == NSComparisonResult.OrderedAscending
			}
			return true
		}

		upcoming.sort {
			if let date0 = $0.releaseDate, date1 = $1.releaseDate {
				return date0.compare(date1) == NSComparisonResult.OrderedAscending
			}
			else {
				return true
			}
		}

		favorites.sort {
			if let date0 = $0.releaseDate, date1 = $1.releaseDate {
				return date0.compare(date1) == NSComparisonResult.OrderedAscending
			}
			else {
				return true
			}
		}
		
		// put upcoming movies in sections
		
		var previousDate: NSDate? = nil
		var currentSection = -1
		upcomingMovies = []
		upcomingSections = []

		for movie in upcoming {
			if ((previousDate == nil) || (previousDate != movie.releaseDate)) {
				// a new sections starts: create new array and add to film-array
				var newMovieArray: [MovieRecord] = []
				upcomingMovies.append(newMovieArray)
				upcomingSections.append(movie.releaseDateStringLong)
				currentSection++
			}
			
			// add movie to current section
			upcomingMovies[currentSection].append(movie)
			
			// sort current section by name
			upcomingMovies[currentSection].sort {
				if let otherTitle = $1.sortTitle {
					return $0.sortTitle?.localizedCaseInsensitiveCompare(otherTitle) == NSComparisonResult.OrderedAscending
				}
				return true
			}
			
			previousDate = movie.releaseDate
		}
		
		
		// put favorites in sections
		
		previousDate = nil
		currentSection = -1
		favoriteMovies = []
		favoriteSections = []
		
		for movie in favorites {
			if (movie.isNowPlaying() && (currentSection == -1)) {
				// it's a current movie, but there is no section for it yet
				var newMovieArray: [MovieRecord] = []
				favoriteMovies.append(newMovieArray)
				favoriteSections.append(NSLocalizedString("NowPlayingLong", comment: ""))
				currentSection++
			}
			else if ((movie.isNowPlaying() == false) && ((previousDate == nil) || (previousDate != movie.releaseDate))) {
				// upcoming movies:
				// a new sections starts: create new array and add to film-array
				var newMovieArray: [MovieRecord] = []
				favoriteMovies.append(newMovieArray)
				favoriteSections.append(movie.releaseDateStringLong)
				currentSection++
			}
			
			// add movie to current section
			favoriteMovies[currentSection].append(movie)
			
			// sort current section by name
			favoriteMovies[currentSection].sort {
				if let otherTitle = $1.sortTitle {
					return $0.sortTitle?.localizedCaseInsensitiveCompare(otherTitle) == NSComparisonResult.OrderedAscending
				}
				return true
			}
			
			previousDate = movie.releaseDate
		}
	}
	
	
	func updateMovies(allMovies: [MovieRecord], database: Database?) {
/*
		if (userDefaults?.objectForKey(Constants.PREFS_LATEST_DB_SUCCESSFULL_UPDATE) != nil) {
			var latestUpdate: NSDate? = userDefaults?.objectForKey(Constants.PREFS_LATEST_DB_SUCCESSFULL_UPDATE) as! NSDate?
		
			if let latestUpdate = latestUpdate {
				var hoursSinceLastUpdate = abs(Int(latestUpdate.timeIntervalSinceNow)) / 60 / 60
				
				if (hoursSinceLastUpdate < Constants.HOURS_BETWEEN_DB_UPDATES) {
					// last update was inside the tolerance: don't get new update
					return
				}
			}
		}
*/

		// check internet connection
		
		if IJReachability.isConnectedToNetwork() == false {
			NSLog("Movie update: no network, we just don't update")
			return
		}

		// check iCloud status
		
		database?.checkCloudKit({ (status: CKAccountStatus, error: NSError!) -> () in
			
			var errorWindow: MessageWindow?
			
			switch status {
			case .Available:
				self.getUpdatedMoviesFromDatabase(allMovies, database: database)
				
			case .NoAccount:
				NSLog("CloudKit error on update: no account")
				dispatch_async(dispatch_get_main_queue()) {
					errorWindow = MessageWindow(parent: self.view, darkenBackground: true, titleStringId: "iCloudError", textStringId: "iCloudNoAccountUpdate", buttonStringId: "Close", handler: {
						errorWindow?.close()
					})
				}
				
			case .Restricted:
				NSLog("CloudKit error on update: Restricted")
				dispatch_async(dispatch_get_main_queue()) {
					errorWindow = MessageWindow(parent: self.view, darkenBackground: true, titleStringId: "iCloudError", textStringId: "iCloudRestrictedUpdate", buttonStringId: "Close", handler: {
						errorWindow?.close()
					})
				}
				
			case .CouldNotDetermine:
				NSLog("CloudKit error on update: CouldNotDetermine")
				dispatch_async(dispatch_get_main_queue()) {
					errorWindow = MessageWindow(parent: self.view, darkenBackground: true, titleStringId: "iCloudError", textStringId: "iCloudCouldNotDetermineUpdate", buttonStringId: "Close", handler: {
						errorWindow?.close()
					})
				}
			}
		})
	}
	
	
	private func getUpdatedMoviesFromDatabase(allMovies: [MovieRecord], database: Database?) {
		
		database?.getUpdatedMovies(allMovies,
			addNewMovieHandler: { (movie: MovieRecord) in
				
				// add new movie
				
				dispatch_async(dispatch_get_main_queue()) {
					if movie.isNowPlaying() {
						NSLog("Adding \(movie.title!) to NOW PLAYING")
						self.nowPlayingController?.addMovie(movie)
					}
					else {
						NSLog("Adding \(movie.title!) to UPCOMING")
						self.upcomingController?.addMovie(movie)
					}
				}
			},
			
			updateMovieHandler: { (movie: MovieRecord) in

				// update movie

				// there are several possibilities:
				// 1a) movie was and is now-playing, movie cell stays in same position, only "invisible" changes
				// 1b) movie was and is now-playing, movie cell stays in same position, changes in visible data, change cell with animation
				// 1c) movie was and is now-playing, movie cell moves because of name-change
				
				// 2a) movie was and is upcoming, movie cell stays in same position (same date, same name), only "invisible" changes
				// 2b) movie was and is upcoming, movie cell stays in same position (same date, same name), changes in visible data, change cell with animation
				// 2c) movie was and is upcoming, movie cell moves in current section (same date, name has changed)
				// 2d) movie was and is upcoming, movie cell moves from one section to another (date has changed)

				// 3) movie was upcoming, is now now-playing
				// 4) movie was now-playing, is now upcoming (unlikely)
				
				// the last two remove the cell from one *tab* and add it to another.
				
				var movieIsInUpcomingList = self.isMovieInUpcomingList(movie)
				var movieIsInNowPlayingList = self.isMovieInNowPlayingList(movie)
				
				dispatch_async(dispatch_get_main_queue()) {
					if (movie.isNowPlaying() && movieIsInNowPlayingList) {
						// movie was and is now-playing
						NSLog("Updating \(movie.title!) in NOW PLAYING")
						self.nowPlayingController?.updateMovie(movie)
					}
					else if (!movie.isNowPlaying() && movieIsInUpcomingList) {
						// movie was and is upcoming
						NSLog("Updating \(movie.title!) in UPCOMING")
						self.upcomingController?.updateMovie(movie)
					}
					else if (!movie.isNowPlaying() && movieIsInNowPlayingList) {
						// movie was now-playing, is now upcoming
						NSLog("Moving \(movie.title!) in from NOW PLAYING to UPCOMING")
						self.nowPlayingController?.removeMovie(movie)
						self.upcomingController?.addMovie(movie)
					}
					else if (movie.isNowPlaying() && movieIsInUpcomingList) {
						// movie was upcoming, is now now-playing
						NSLog("Moving \(movie.title!) in from UPCOMING to NOW PLAYING")
						self.upcomingController?.removeMovie(movie)
						self.nowPlayingController?.addMovie(movie)
					}
					
					if (contains(Favorites.IDs, movie.id)) {
						// also, update the favorites
						NSLog("Updating \(movie.title!) in FAVORITES")
						self.favoriteController?.updateFavorite(movie)
					}
				}
			},
			
			completionHandler: { (movies: [MovieRecord]?) in
				UIApplication.sharedApplication().networkActivityIndicatorVisible = false
			},

			errorHandler: { (errorMessage: String) in
				UIApplication.sharedApplication().networkActivityIndicatorVisible = false
				NSLog(errorMessage)
			},
			
			updatePosterHandler: { (tmdbId: Int) in
				// update thumbnail poster if needed
				dispatch_async(dispatch_get_main_queue()) {
					if (self.nowPlayingController?.updateThumbnail(tmdbId) == false) {
						self.upcomingController?.updateThumbnail(tmdbId)
					}
					
					self.favoriteController?.updateThumbnail(tmdbId)
				}
			}
		)
	}
	

	var nowPlayingController: NowTableViewController? {
		get {
			return findTableViewController()
		}
	}
	
	var upcomingController: UpcomingTableViewController? {
		get {
			return findTableViewController()
		}
	}
	
	var favoriteController: FavoriteTableViewController? {
		get {
			return findTableViewController()
		}
	}
	
	private func findTableViewController<T>() -> T? {
		if let tabBarVcs = viewControllers {
			for tabBarVc in tabBarVcs {
				if tabBarVc is UINavigationController {
					for navVc in (tabBarVc as! UINavigationController).viewControllers {
						if navVc is T {
							return navVc as? T
						}
					}
				}
			}
		}
		
		return nil
	}

	private func isMovieInNowPlayingList(newMovie: MovieRecord) -> Bool {
		for movie in nowMovies {
			if (movie.id == newMovie.id) {
				return true
			}
		}
		
		return false
	}

	private func isMovieInUpcomingList(newMovie: MovieRecord) -> Bool {
		for section in upcomingMovies {
			for movie in section {
				if (movie.id == newMovie.id) {
					return true
				}
			}
		}
		
		return false
	}
}
