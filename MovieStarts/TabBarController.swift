//
//  TabBarController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 24.02.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

	var nowMovies: [MovieRecord] = []
	var upcomingMovies: [[MovieRecord]] = []
	var upcomingSections: [String] = []
	var favoriteMovies: [[MovieRecord]] = []
	var favoriteSections: [String] = []
	
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
			if let otherTitle = $1.title {
				return $0.title?.localizedCaseInsensitiveCompare(otherTitle) == NSComparisonResult.OrderedAscending
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
//			return $0.releaseDate!.compare($1.releaseDate!) == NSComparisonResult.OrderedAscending
		}

		favorites.sort {
			if let date0 = $0.releaseDate, date1 = $1.releaseDate {
				return date0.compare(date1) == NSComparisonResult.OrderedAscending
			}
			else {
				return true
			}
			//			return $0.releaseDate!.compare($1.releaseDate!) == NSComparisonResult.OrderedAscending
			
/*
			if let otherTitle = $1.title {
				return $0.title?.localizedCaseInsensitiveCompare(otherTitle) == NSComparisonResult.OrderedAscending
			}
			
			return true
*/
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
				if let otherTitle = $1.title {
					return $0.title?.localizedCaseInsensitiveCompare(otherTitle) == NSComparisonResult.OrderedAscending
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
				if let otherTitle = $1.title {
					return $0.title?.localizedCaseInsensitiveCompare(otherTitle) == NSComparisonResult.OrderedAscending
				}
				return true
			}
			
			previousDate = movie.releaseDate
		}
	}
	
	
	func updateMovies(allMovies: [MovieRecord]) {
		
		// TODO : check if last update-check was more than 24 hours ago. if yes, check for update.
		
		var database = Database(recordType: Constants.RECORD_TYPE_USA)
		
		database.getUpdatedMovies(allMovies,
			addNewMovieHandler: { (movie: MovieRecord) in
				
				// add new movie
				
				dispatch_async(dispatch_get_main_queue()) {
					if movie.isNowPlaying() {
						self.nowPlayingController?.addMovie(movie)
					}
					else {
						self.upcomingController?.addMovie(movie)
					}
				}
			},
			
			updateMovieHandler: { (movie: MovieRecord) in

				// update movie
				
				dispatch_async(dispatch_get_main_queue()) {
//					tabBarController.updateMovie(movie)
				}
			}
		)
	}
	
	
	
/*
	func addNewMovie(movie: MovieRecord) {
		allMovies.append(movie)
		
		if let saveDate = movie.releaseDate {
			if movie.isNowPlaying() {
				println("Add new movie to now: \(movie.title)")
				nowMovies.append(movie)
			}
			else {
				println("Add new movie to upcoming: \(movie.title)")
				upcomingMovies.append(movie)
			}
		}

		sortLists()
		updateFavorites()

	}

	func updateMovie(movie: MovieRecord) {

		// update allMovies-list
		
		for index in 0 ..< allMovies.count {
			if (allMovies[index].id == movie.id) {
				allMovies[index] = movie
				break
			}
		}

		// update now-list
		
		var foundInNow = false
		
		for index in 0 ..< nowMovies.count {
			if (nowMovies[index].id == movie.id) {
				if (movie.isNowPlaying()) {
					// update-movie is in now-list and is still playing now: movie is in correct list, just update record
					println("Updating movie in now: \(movie.title)")
					nowMovies[index] = movie
				}
				else {
					// update-movie is in now-list, but is playing in the future. Move to upcoming-list.
					println("*** Updating movie from now to upcoming: \(movie.title)")
					nowMovies.removeAtIndex(index)
					upcomingMovies.append(movie)
				}
				foundInNow = true
				break
			}
		}

		// update upcoming-list
		
		if !foundInNow {
			for index in 0 ..< upcomingMovies.count {
				if (upcomingMovies[index].id == movie.id) {
					if (movie.isNowPlaying()) {
						// update-movie is in upcoming-list, but is playing now: Move to now-list.
						println("*** Updating movie from upcoming to now: \(movie.title)")
						upcomingMovies.removeAtIndex(index)
						nowMovies.append(movie)
					}
					else {
						// update-movie is in upcoming-list and is still upcoming. Just update the record.
						println("Updating movie in upcoming: \(movie.title)")
						upcomingMovies[index] = movie
					}
					break
				}
			}
		}
		
		// sort that all
		
		sortLists()
		updateFavorites()
	}
*/
	
	
	func updateFavorites() {
/*
		
		favoriteMovies = []

		// find all favorite movies
		
		for movie in allMovies {
			if (contains(Favorites.IDs, movie.id)) {
				favoriteMovies.append(movie)
			}
		}
		
		
		// sort them by date
		
		favoriteMovies.sort {
			return $0.releaseDate!.compare($1.releaseDate!) == NSComparisonResult.OrderedAscending
		}
		
		// update view controller
		
		if let tabBarVcs = viewControllers {
		
			for tabBarVc in tabBarVcs {
				if tabBarVc is UINavigationController {
					for navVc in (tabBarVc as! UINavigationController).viewControllers {
						if navVc is FavoriteTableViewController {
							(navVc as? FavoriteTableViewController)?.updateMoviesAndSections()
						}
					}
				}
			}
		}

*/
		
	}
	
/*
	func sortLists() {
		upcomingMovies.sort {
			return $0.releaseDate!.compare($1.releaseDate!) == NSComparisonResult.OrderedAscending
		}
		
		nowMovies.sort {
			return $0.title < $1.title
		}
	}
*/
	
/*
	override func shouldAutorotate() -> Bool {
		if let svc = selectedViewController {
			return svc.shouldAutorotate()
		}
		else {
			return false
		}
	}
*/
	
	
	var nowPlayingController: NowTableViewController? {
		get {
			return findTableViewController()
			
/*
			if let tabBarVcs = viewControllers {
				for tabBarVc in tabBarVcs {
					if tabBarVc is UINavigationController {
						for navVc in (tabBarVc as! UINavigationController).viewControllers {
							if navVc is NowTableViewController {
								return navVc as? NowTableViewController
							}
						}
					}
				}
			}
			
			return nil
*/
		}
	}
	
	var upcomingController: UpcomingTableViewController? {
		get {
			return findTableViewController()

/*
			if let tabBarVcs = viewControllers {
				for tabBarVc in tabBarVcs {
					if tabBarVc is UINavigationController {
						for navVc in (tabBarVc as! UINavigationController).viewControllers {
							if navVc is UpcomingTableViewController {
								return navVc as? UpcomingTableViewController
							}
						}
					}
				}
			}
			
			return nil
*/
		}
	}
	
	var favoriteController: FavoriteTableViewController? {
		get {
			return findTableViewController()

/*
			if let tabBarVcs = viewControllers {
				for tabBarVc in tabBarVcs {
					if tabBarVc is UINavigationController {
						for navVc in (tabBarVc as! UINavigationController).viewControllers {
							if navVc is FavoriteTableViewController {
								return navVc as? FavoriteTableViewController
							}
						}
					}
				}
			}
			
			return nil
*/
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
}
