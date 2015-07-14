//
//  UpcomingTableViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 11.02.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit

class UpcomingTableViewController: MovieTableViewController {

	override var movies: [MovieRecord] {
		get {
			if let movieTabBarController = movieTabBarController {
				return movieTabBarController.upcomingMovies
			}
			else {
				return []
			}
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.title = NSLocalizedString("UpcomingLong", comment: "")
	}
}

