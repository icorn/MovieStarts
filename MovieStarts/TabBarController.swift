//
//  TabBarController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 24.02.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit
import CloudKit


class TabBarController: UITabBarController
{
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

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if let saveItems = movieTabBar.items {
			if (saveItems.count == 4) {
				
				// set tab bar titles
				
				saveItems[Constants.tabIndexNowPlaying].title = NSLocalizedString("NowPlayingTabBar", comment: "")
				saveItems[Constants.tabIndexUpcoming].title = NSLocalizedString("UpcomingTabBar", comment: "")
				saveItems[Constants.tabIndexFavorites].title = NSLocalizedString("FavoritesTabBar", comment: "")
				saveItems[Constants.tabIndexSettings].title = NSLocalizedString("SettingsTabBar", comment: "")
				
				// set tab bar images

				saveItems[Constants.tabIndexNowPlaying].image = UIImage(named: "video")
				saveItems[Constants.tabIndexUpcoming].image = UIImage(named: "calendar")
				saveItems[Constants.tabIndexFavorites].image = UIImage(named: "favorite")
				saveItems[Constants.tabIndexSettings].image = UIImage(named: "settings")
			}
		}
    }

	override func viewDidLoad()
    {
		super.viewDidLoad()

        // hack: load all children of tabbarcontroller to be able to delete and add movies before children are visible

        for viewController in self.viewControllers!
        {
            if let navController = viewController as? UINavigationController {
                for child in navController.children {
                    // access "view" to force loading it
                    child.view.isHidden = false
                }
            }
        }

		if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let notification = appDelegate.movieReleaseNotification
        {
			// we have a notification for the user
            let userInfo = notification.content.userInfo
            
			if let movieIDs = userInfo[Constants.notificationUserInfoId] as? [String] , movieIDs.count > 0,
               let movieTitles = userInfo[Constants.notificationUserInfoName] as? [String] , movieTitles.count > 0,
               let movieDate = userInfo[Constants.notificationUserInfoDate] as? String,
               let notificationDay = userInfo[Constants.notificationUserInfoDay] as? Int
            {
                if (movieTitles.count == 1) {
                    // only one movie: go directly to the movie
                    selectedIndex = Constants.tabIndexFavorites
                    self.favoriteController?.showFavoriteMovie(movieIDs[0])
                }
                else {
                    // multiple movies
                    NotificationManager.notifyAboutMultipleMovies(appDelegate: appDelegate, movieIDs: movieIDs, movieTitles: movieTitles, movieDate: movieDate, notificationDay: notificationDay)
                }
                
                appDelegate.movieReleaseNotification = nil
			}
        }
	}


    func loadGenresFromFile()
    {
		let genreDatabase = GenreDatabase(finishHandler: nil, errorHandler: nil)
		genreDict = genreDatabase.readGenresFromFile()
	}

	
	/**
		Puts all movies into the categories now, upcoming, and/or favorites.
	
		- parameter allMovies:	All the movies to put into categories
	*/
	func setUpMovies(_ allMovies: [MovieRecord]) {
		
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
		
		nowMovies.sort {
			let otherTitle = $1.sortTitle[$1.currentCountry.languageArrayIndex]
			return $0.sortTitle[$0.currentCountry.languageArrayIndex].localizedCaseInsensitiveCompare(otherTitle) == ComparisonResult.orderedAscending
		}

		upcoming.sort {
			let date0 = $0.releaseDate[$0.currentCountry.countryArrayIndex], date1 = $1.releaseDate[$1.currentCountry.countryArrayIndex]
			return date0.compare(date1 as Date) == ComparisonResult.orderedAscending
		}

		favorites.sort {
			let date0 = $0.releaseDate[$0.currentCountry.countryArrayIndex], date1 = $1.releaseDate[$1.currentCountry.countryArrayIndex]
			return date0.compare(date1 as Date) == ComparisonResult.orderedAscending
		}
		
		// put upcoming movies in sections
		
		var previousDate: Date? = nil
		var currentSection = -1
		upcomingMovies = []
		upcomingSections = []

		for movie in upcoming {
			if ((previousDate == nil) || (previousDate != movie.releaseDate[movie.currentCountry.countryArrayIndex] as Date)) {
				// a new sections starts: create new array and add to film-array
				let newMovieArray: [MovieRecord] = []
				upcomingMovies.append(newMovieArray)
				upcomingSections.append(movie.releaseDateStringLong)
				currentSection += 1
			}
			
			// add movie to current section
			upcomingMovies[currentSection].append(movie)
			
			// sort current section by name
			upcomingMovies[currentSection].sort {
				let otherTitle = $1.sortTitle[$1.currentCountry.languageArrayIndex]
				return $0.sortTitle[$0.currentCountry.languageArrayIndex].localizedCaseInsensitiveCompare(otherTitle) == ComparisonResult.orderedAscending
			}
			
			previousDate = movie.releaseDate[movie.currentCountry.countryArrayIndex] as Date
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
			else if ((movie.isNowPlaying() == false) && ((previousDate == nil) || (previousDate != movie.releaseDate[movie.currentCountry.countryArrayIndex] as Date))) {
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
			favoriteMovies[currentSection].sort {
				let otherTitle = $1.sortTitle[$1.currentCountry.languageArrayIndex]
				return $0.sortTitle[$0.currentCountry.languageArrayIndex].localizedCaseInsensitiveCompare(otherTitle) == ComparisonResult.orderedAscending
			}
			
			previousDate = movie.releaseDate[movie.currentCountry.countryArrayIndex] as Date
		}
		
		NotificationManager.updateFavoriteNotifications(favoriteMovies: favoriteMovies)
	}
	

    func updateMovies(_ allMovies: [MovieRecord], onlyIfUpdateIsTooOld checkLastUpdate: Bool)
    {
        if (checkLastUpdate && (MovieDatabaseUpdater.isLastMovieUpdateOlderThan(minutes: Constants.hoursBetweenDbUpdates * 60) == false))
        {
            return
        }
        
		// check iCloud status
		
		MovieDatabaseUpdater.sharedInstance.checkCloudKit(handler:
        { [weak self] (status: CKAccountStatus, error: Error?) -> () in
			
			var errorWindow: MessageWindow?
			
			switch status {
			case .available:
				self?.getUpdatedMoviesFromDatabase(allMovies: allMovies)
				
			case .noAccount:
				NSLog("CloudKit error on update: no account")
                NotificationCenter.default.post(name: NSNotification.Name(MovieDatabaseUpdater.MovieUpdateFinishNotification), object: nil)
                DispatchQueue.main.async
                {
                    if let view = self?.view
                    {
                        errorWindow = MessageWindow(parent: view,
                                                    darkenBackground: true,
                                                    titleStringId: "iCloudError",
                                                    textStringId: "iCloudNoAccountUpdate",
                                                    buttonStringIds: ["Close"],
                            handler: { (buttonIndex) -> () in
                                errorWindow?.close()
                            }
                        )
                    }
				}
				
			case .restricted:
				NSLog("CloudKit error on update: Restricted")
                NotificationCenter.default.post(name: NSNotification.Name(MovieDatabaseUpdater.MovieUpdateFinishNotification), object: nil)
				DispatchQueue.main.async
                {
                    if let view = self?.view
                    {
                        errorWindow = MessageWindow(parent: view,
                                                    darkenBackground: true,
                                                    titleStringId: "iCloudError",
                                                    textStringId: "iCloudRestrictedUpdate",
                                                    buttonStringIds: ["Close"],
                            handler: { (buttonIndex) -> () in
                                errorWindow?.close()
                            }
                        )
                    }
				}
				
			case .couldNotDetermine:
				NSLog("CloudKit error on update: CouldNotDetermine")
                NotificationCenter.default.post(name: NSNotification.Name(MovieDatabaseUpdater.MovieUpdateFinishNotification), object: nil)
				DispatchQueue.main.async
                {
                    if let view = self?.view
                    {
                        errorWindow = MessageWindow(parent: view,
                                                    darkenBackground: true,
                                                    titleStringId: "iCloudError",
                                                    textStringId: "iCloudCouldNotDetermineUpdate",
                                                    buttonStringIds: ["Close"],
                            handler: { (buttonIndex) -> () in
                                errorWindow?.close()
                            }
                        )
                    }
				}
                
            @unknown default:
                // TODO
                NSLog("Unknown error updating.")
            }
		})
	}

	
	fileprivate func getUpdatedMoviesFromDatabase(allMovies: [MovieRecord])
    {
		let prefsCountryString = (UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
		
		guard let country = MovieCountry(rawValue: prefsCountryString) else
        {
			NSLog("ERROR getting country from preferences")
            NotificationCenter.default.post(name: NSNotification.Name(MovieDatabaseUpdater.MovieUpdateFinishNotification), object: nil)
			return
		}
		
		MovieDatabaseUpdater.sharedInstance.updateThumbnailHandler = updateThumbnailHandler

		DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async
        {
            MovieDatabaseUpdater.sharedInstance.getUpdatedMovies(
                allMovies,
                country: country,
                addNewMovieHandler: { [weak self] (movie: MovieRecord) in

                    if (!movie.isHidden) {
                        // add new movie
                        
                        DispatchQueue.main.async {
                            let title = movie.title[movie.currentCountry.languageArrayIndex]

                            if movie.isNowPlaying() {
                                print("Adding \(title) to NOW PLAYING")
                                self?.nowPlayingController?.addMovie(movie)
                            }
                            else {
                                print("Adding \(title) to UPCOMING")
                                self?.upcomingController?.addMovie(movie)
                            }
                        }
                    }
                },
                
                updateMovieHandler: { [weak self] (movie: MovieRecord) in

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
                    
                    let movieIsInUpcomingList = self?.isMovieInUpcomingList(newMovie: movie) ?? false
                    let movieIsInNowPlayingList = self?.isMovieInNowPlayingList(newMovie: movie) ?? false
                    
                    DispatchQueue.main.async
                    {
                        if (movie.isNowPlaying() && movieIsInNowPlayingList)
                        {
                            // movie was and is now-playing
                            
                            if movie.isHidden
                            {
                                self?.nowPlayingController?.removeMovie(movie)
                            }
                            else
                            {
                                let title = movie.title[movie.currentCountry.languageArrayIndex]
                                print("Updating \(title) in NOW PLAYING")
                                self?.nowPlayingController?.updateMovie(movie)
                            }
                        }
                        else if (!movie.isNowPlaying() && movieIsInUpcomingList)
                        {
                            // movie was and is upcoming
                            
                            if movie.isHidden
                            {
                                self?.upcomingController?.removeMovie(movie)
                            }
                            else
                            {
                                let title = movie.title[movie.currentCountry.languageArrayIndex]
                                print("Updating \(title) in UPCOMING")
                                self?.upcomingController?.updateMovie(movie)
                            }
                        }
                        else if (!movie.isNowPlaying() && movieIsInNowPlayingList)
                        {
                            // movie was now-playing, is now upcoming
                            
                            if movie.isHidden
                            {
                                self?.nowPlayingController?.removeMovie(movie)
                            }
                            else
                            {
                                let title = movie.title[movie.currentCountry.languageArrayIndex]
                                print("Moving \(title) in from NOW PLAYING to UPCOMING")
                                self?.nowPlayingController?.removeMovie(movie)
                                self?.upcomingController?.addMovie(movie)
                            }
                        }
                        else if (movie.isNowPlaying() && movieIsInUpcomingList)
                        {
                            // movie was upcoming, is now now-playing
                            
                            if movie.isHidden
                            {
                                self?.upcomingController?.removeMovie(movie)
                            }
                            else
                            {
                                let title = movie.title[movie.currentCountry.languageArrayIndex]
                                print("Moving \(title) in from UPCOMING to NOW PLAYING")
                                self?.upcomingController?.removeMovie(movie)
                                self?.nowPlayingController?.addMovie(movie)
                            }
                        }
                        
                        if (Favorites.IDs.contains(movie.id))
                        {
                            // also, update the favorites
                            
                            if movie.isHidden
                            {
                                self?.favoriteController?.removeFavorite(movie.id)
                            }
                            else
                            {
                                let title = movie.title[movie.currentCountry.languageArrayIndex]
                                print("Updating \(title) in FAVORITES")
                                self?.favoriteController?.updateFavorite(movie)
                            }
                        }
                    }
                },
                
                removeMovieHandler: { [weak self] (movie: MovieRecord) in
                    
                    // remove movie
                    DispatchQueue.main.async {
                        self?.nowPlayingController?.removeMovie(movie)
                        self?.upcomingController?.removeMovie(movie)
                    
                        if (Favorites.IDs.contains(movie.id))
                        {
                            self?.favoriteController?.removeFavorite(movie.id)
                        }
                    }
                },
                
                completionHandler: { [weak self] (movies: [MovieRecord]?) in
                    DispatchQueue.main.async
                    {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                    self?.loadGenresFromFile()
                    NotificationCenter.default.post(name: NSNotification.Name(MovieDatabaseUpdater.MovieUpdateFinishNotification), object: nil)
                },

                errorHandler: { (errorMessage: String) in
                    DispatchQueue.main.async
                    {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                    NSLog(errorMessage)
                    NotificationCenter.default.post(name: NSNotification.Name(MovieDatabaseUpdater.MovieUpdateFinishNotification), object: nil)
                }
            )
        }
	}

	var nowPlayingController: NowViewController? {
		get {
			return findTableViewController()
		}
	}
	
	var upcomingController: UpcomingViewController? {
		get {
			return findTableViewController()
		}
	}
	
	var favoriteController: FavoriteViewController? {
		get {
			return findTableViewController()
		}
	}
	
	
	func updateThumbnailHandler(tmdbId: Int) {
		// update thumbnail poster if needed
		DispatchQueue.main.async {
			if (self.nowPlayingController?.updateThumbnail(tmdbId: tmdbId) == false) {
				let _ = self.upcomingController?.updateThumbnail(tmdbId: tmdbId)
			}
	
			let _ = self.favoriteController?.updateThumbnail(tmdbId: tmdbId)
		}
	}

	fileprivate func findTableViewController<T>() -> T? {
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

	fileprivate func isMovieInNowPlayingList(newMovie: MovieRecord) -> Bool {
		for movie in nowMovies {
			if (movie.id == newMovie.id) {
				return true
			}
		}
		
		return false
	}

	fileprivate func isMovieInUpcomingList(newMovie: MovieRecord) -> Bool {
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
