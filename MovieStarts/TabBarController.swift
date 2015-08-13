//
//  TabBarController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 24.02.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

	var allMovies: [MovieRecord] = []
	var nowMovies: [MovieRecord] = []
	var upcomingMovies: [MovieRecord] = []
	var favoriteMovies: [MovieRecord] = []
	//	var bestMovies: [MovieRecord] = []
	
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
	
	func updateFavorites() {
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
		
	}
	
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
}
