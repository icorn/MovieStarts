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

	var genreDict: [Int: String] = [:]
	var nowMovies: [MovieRecord] = []
	var upcomingMovies: [[MovieRecord]] = []
	var upcomingSections: [String] = []
	var favoriteMovies: [[MovieRecord]] = []
	var favoriteSections: [String] = []
	var thisIsTheFirstLaunch = false
	var migrationHasFailedInThisSession = false
	
	@IBOutlet weak var movieTabBar: UITabBar!

	
	// MARK: - UIViewController

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		if let saveItems = movieTabBar.items {
			if (saveItems.count == 4) {
				
				// set tab bar titles
				
				saveItems[Constants.tabIndexNowPlaying].title = NSLocalizedString("NowPlayingTabBar", comment: "")
				saveItems[Constants.tabIndexUpcoming].title = NSLocalizedString("UpcomingTabBar", comment: "")
				saveItems[Constants.tabIndexFavorites].title = NSLocalizedString("FavoritesTabBar", comment: "")
				saveItems[Constants.tabIndexSettings].title = NSLocalizedString("SettingsTabBar", comment: "")
				
				// set tab bar images

				saveItems[Constants.tabIndexNowPlaying].image = UIImage(named: "Video.png")
				saveItems[Constants.tabIndexUpcoming].image = UIImage(named: "Calendar.png")
				saveItems[Constants.tabIndexFavorites].image = UIImage(named: "favorite.png")
				saveItems[Constants.tabIndexSettings].image = UIImage(named: "Settings.png")
			}
		}
    }

	override func viewDidLoad() {
		super.viewDidLoad()
		
		if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate, let notification = appDelegate.movieReleaseNotification {
			// we have a notification for the user
			guard let userInfo = notification.userInfo,
				let movieIDs = userInfo[Constants.notificationUserInfoId] as? [String] where movieIDs.count > 0,
				let movieTitles = userInfo[Constants.notificationUserInfoName] as? [String] where movieTitles.count > 0,
				let movieDate = userInfo[Constants.notificationUserInfoDate] as? String,
				let notificationDay = userInfo[Constants.notificationUserInfoDay] as? Int else {
					return
			}
			
			if (movieTitles.count == 1) {
				// only one movie: go directly to the movie
				selectedIndex = Constants.tabIndexFavorites
				self.favoriteController?.showFavoriteMovie(movieIDs[0])
			}
			else {
				// multiple movies
				NotificationManager.notifyAboutMultipleMovies(appDelegate, movieIDs: movieIDs, movieTitles: movieTitles, movieDate: movieDate, notificationDay: notificationDay)
			}
			
			appDelegate.movieReleaseNotification = nil
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	func loadGenresFromFile() {
		let genreDatabase = GenreDatabase(finishHandler: nil, errorHandler: nil)
		genreDict = genreDatabase.readGenresFromFile()
	}

	
	/**
		Puts all movies into the categories now, upcoming, and/or favorites.
	
		- parameter allMovies:	All the movies to put into categories
	*/
	func setUpMovies(allMovies: [MovieRecord]) {
		
		// iterate over all movies and sort them into one of three lists (and ignore the ones without release date)
		
		nowMovies = []
		var upcoming: [MovieRecord] = []
		var favorites: [MovieRecord] = []
		
		for movie in allMovies {
			if (movie.isHidden == false) {
				if movie.isNowPlaying() {
					nowMovies.append(movie)
				}
				else {
					upcoming.append(movie)
				}
				
				if (Favorites.IDs.contains(movie.id)) {
					favorites.append(movie)
				}
			}
		}
		
		nowMovies.sortInPlace {
			let otherTitle = $1.sortTitle[$1.currentCountry.languageArrayIndex]
			return $0.sortTitle[$0.currentCountry.languageArrayIndex].localizedCaseInsensitiveCompare(otherTitle) == NSComparisonResult.OrderedAscending
		}

		upcoming.sortInPlace {
			let date0 = $0.releaseDate[$0.currentCountry.countryArrayIndex], date1 = $1.releaseDate[$1.currentCountry.countryArrayIndex]
			return date0.compare(date1) == NSComparisonResult.OrderedAscending
		}

		favorites.sortInPlace {
			let date0 = $0.releaseDate[$0.currentCountry.countryArrayIndex], date1 = $1.releaseDate[$1.currentCountry.countryArrayIndex]
			return date0.compare(date1) == NSComparisonResult.OrderedAscending
		}
		
		// put upcoming movies in sections
		
		var previousDate: NSDate? = nil
		var currentSection = -1
		upcomingMovies = []
		upcomingSections = []

		for movie in upcoming {
			if ((previousDate == nil) || (previousDate != movie.releaseDate[movie.currentCountry.countryArrayIndex])) {
				// a new sections starts: create new array and add to film-array
				let newMovieArray: [MovieRecord] = []
				upcomingMovies.append(newMovieArray)
				upcomingSections.append(movie.releaseDateStringLong)
				currentSection += 1
			}
			
			// add movie to current section
			upcomingMovies[currentSection].append(movie)
			
			// sort current section by name
			upcomingMovies[currentSection].sortInPlace {
				let otherTitle = $1.sortTitle[$1.currentCountry.languageArrayIndex]
				return $0.sortTitle[$0.currentCountry.languageArrayIndex].localizedCaseInsensitiveCompare(otherTitle) == NSComparisonResult.OrderedAscending
			}
			
			previousDate = movie.releaseDate[movie.currentCountry.countryArrayIndex]
		}
		
		
		// put favorites in sections
		
		previousDate = nil
		currentSection = -1
		favoriteMovies = []
		favoriteSections = []
		
		for movie in favorites {
			if (movie.isNowPlaying() && (currentSection == -1)) {
				// it's a current movie, but there is no section for it yet
				let newMovieArray: [MovieRecord] = []
				favoriteMovies.append(newMovieArray)
				favoriteSections.append(NSLocalizedString("NowPlayingLong", comment: ""))
				currentSection += 1
			}
			else if ((movie.isNowPlaying() == false) && ((previousDate == nil) || (previousDate != movie.releaseDate[movie.currentCountry.countryArrayIndex]))) {
				// upcoming movies:
				// a new sections starts: create new array and add to film-array
				let newMovieArray: [MovieRecord] = []
				favoriteMovies.append(newMovieArray)
				favoriteSections.append(movie.releaseDateStringLong)
				currentSection += 1
			}
			
			// add movie to current section
			favoriteMovies[currentSection].append(movie)
			
			// sort current section by name
			favoriteMovies[currentSection].sortInPlace {
				let otherTitle = $1.sortTitle[$1.currentCountry.languageArrayIndex]
				return $0.sortTitle[$0.currentCountry.languageArrayIndex].localizedCaseInsensitiveCompare(otherTitle) == NSComparisonResult.OrderedAscending
			}
			
			previousDate = movie.releaseDate[movie.currentCountry.countryArrayIndex]
		}
		
		NotificationManager.updateFavoriteNotifications(favoriteMovies)
	}
	
	
	func updateMovies(allMovies: [MovieRecord], database: MovieDatabase?) {
		let userDefaults = NSUserDefaults(suiteName: Constants.movieStartsGroup)

		if (userDefaults?.objectForKey(Constants.prefsLatestDbSuccessfullUpdate) != nil) {
			let latestSuccessfullUpdate: NSDate? = userDefaults?.objectForKey(Constants.prefsLatestDbSuccessfullUpdate) as? NSDate
		
			if let latestSuccessfullUpdate = latestSuccessfullUpdate {
				let hoursSinceLastSuccessfullUpdate = abs(Int(latestSuccessfullUpdate.timeIntervalSinceNow)) / 60 / 60
				
				if (hoursSinceLastSuccessfullUpdate < Constants.hoursBetweenDbUpdates) {
					// last successfull update was inside the tolerance: don't get new update
					return
				}
			}
		}

		// check iCloud status
		
		database?.checkCloudKit({ [unowned self] (status: CKAccountStatus, error: NSError?) -> () in
			
			var errorWindow: MessageWindow?
			
			switch status {
			case .Available:
				self.getUpdatedMoviesFromDatabase(allMovies, database: database)
				
			case .NoAccount:
				NSLog("CloudKit error on update: no account")
				dispatch_async(dispatch_get_main_queue()) {
					errorWindow = MessageWindow(parent: self.view, darkenBackground: true, titleStringId: "iCloudError", textStringId: "iCloudNoAccountUpdate", buttonStringIds: ["Close"],
						handler: { (buttonIndex) -> () in
							errorWindow?.close()
						}
					)
				}
				
			case .Restricted:
				NSLog("CloudKit error on update: Restricted")
				dispatch_async(dispatch_get_main_queue()) {
					errorWindow = MessageWindow(parent: self.view, darkenBackground: true, titleStringId: "iCloudError", textStringId: "iCloudRestrictedUpdate", buttonStringIds: ["Close"],
						handler: { (buttonIndex) -> () in
							errorWindow?.close()
						}
					)
				}
				
			case .CouldNotDetermine:
				NSLog("CloudKit error on update: CouldNotDetermine")
				dispatch_async(dispatch_get_main_queue()) {
					errorWindow = MessageWindow(parent: self.view, darkenBackground: true, titleStringId: "iCloudError", textStringId: "iCloudCouldNotDetermineUpdate", buttonStringIds: ["Close"],
						handler: { (buttonIndex) -> () in
							errorWindow?.close()
						}
					)
				}
			}
		})
	}
	
	
	private func getUpdatedMoviesFromDatabase(allMovies: [MovieRecord], database: MovieDatabase?) {
		let prefsCountryString = (NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
		
		guard let country = MovieCountry(rawValue: prefsCountryString) else {
			NSLog("ERROR getting country from preferences")
			return
		}
		
		database?.updateThumbnailHandler = updateThumbnailHandler

		database?.getUpdatedMovies(allMovies, country: country,
			addNewMovieHandler: { [unowned self] (movie: MovieRecord) in

				if (!movie.isHidden) {
					// add new movie
					
					dispatch_async(dispatch_get_main_queue()) {
						let title = movie.title[movie.currentCountry.languageArrayIndex]

						if movie.isNowPlaying() {
							print("Adding \(title) to NOW PLAYING")
							self.nowPlayingController?.addMovie(movie)
						}
						else {
							print("Adding \(title) to UPCOMING")
							self.upcomingController?.addMovie(movie)
						}
					}
				}
			},
			
			updateMovieHandler: { [unowned self] (movie: MovieRecord) in

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
				
				let movieIsInUpcomingList = self.isMovieInUpcomingList(movie)
				let movieIsInNowPlayingList = self.isMovieInNowPlayingList(movie)
				
				dispatch_async(dispatch_get_main_queue()) {
					if (movie.isNowPlaying() && movieIsInNowPlayingList) {
						// movie was and is now-playing
						
						if movie.isHidden {
							self.nowPlayingController?.removeMovie(movie)
						}
						else {
							let title = movie.title[movie.currentCountry.languageArrayIndex]
							print("Updating \(title) in NOW PLAYING")
							self.nowPlayingController?.updateMovie(movie)
						}
					}
					else if (!movie.isNowPlaying() && movieIsInUpcomingList) {
						// movie was and is upcoming
						
						if movie.isHidden {
							self.upcomingController?.removeMovie(movie)
						}
						else {
							let title = movie.title[movie.currentCountry.languageArrayIndex]
							print("Updating \(title) in UPCOMING")
							self.upcomingController?.updateMovie(movie)
						}
					}
					else if (!movie.isNowPlaying() && movieIsInNowPlayingList) {
						// movie was now-playing, is now upcoming
						
						if movie.isHidden {
							self.nowPlayingController?.removeMovie(movie)
						}
						else {
							let title = movie.title[movie.currentCountry.languageArrayIndex]
							print("Moving \(title) in from NOW PLAYING to UPCOMING")
							self.nowPlayingController?.removeMovie(movie)
							self.upcomingController?.addMovie(movie)
						}
					}
					else if (movie.isNowPlaying() && movieIsInUpcomingList) {
						// movie was upcoming, is now now-playing
						
						if movie.isHidden {
							self.upcomingController?.removeMovie(movie)
						}
						else {
							let title = movie.title[movie.currentCountry.languageArrayIndex]
							print("Moving \(title) in from UPCOMING to NOW PLAYING")
							self.upcomingController?.removeMovie(movie)
							self.nowPlayingController?.addMovie(movie)
						}
					}
					
					if (Favorites.IDs.contains(movie.id)) {
						// also, update the favorites
						
						if movie.isHidden {
							self.favoriteController?.removeFavorite(movie.id)
						}
						else {
							let title = movie.title[movie.currentCountry.languageArrayIndex]
							print("Updating \(title) in FAVORITES")
							self.favoriteController?.updateFavorite(movie)
						}
					}
				}
			},
			
			removeMovieHandler: { [unowned self] (movie: MovieRecord) in
				
				// remove movie
				dispatch_async(dispatch_get_main_queue()) {
					self.nowPlayingController?.removeMovie(movie)
					self.upcomingController?.removeMovie(movie)
				
					if (Favorites.IDs.contains(movie.id)) {
						self.favoriteController?.removeFavorite(movie.id)
					}
				}
			},
			
			completionHandler: { [unowned self] (movies: [MovieRecord]?) in
				UIApplication.sharedApplication().networkActivityIndicatorVisible = false
				self.loadGenresFromFile()
			},

			errorHandler: { (errorMessage: String) in
				UIApplication.sharedApplication().networkActivityIndicatorVisible = false
				NSLog(errorMessage)
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
	
	
	func updateThumbnailHandler(tmdbId: Int) {
		// update thumbnail poster if needed
		dispatch_async(dispatch_get_main_queue()) {
			if (self.nowPlayingController?.updateThumbnail(tmdbId) == false) {
				self.upcomingController?.updateThumbnail(tmdbId)
			}
	
			self.favoriteController?.updateThumbnail(tmdbId)
		}
	}

	private func findTableViewController<T>() -> T? {
		if let tabBarVcs = viewControllers {
			for tabBarVc in tabBarVcs {
				if let tabBarVc = tabBarVc as? UINavigationController {
					for navVc in tabBarVc.viewControllers {
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
