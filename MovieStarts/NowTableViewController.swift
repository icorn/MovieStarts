//
//  NowTableViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 14.07.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit

class NowTableViewController: MovieTableViewController {

	override var movies: [MovieRecord] {
		get {
			if let movieTabBarController = movieTabBarController {
				return movieTabBarController.nowMovies
			}
			else {
				return []
			}
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		navigationItem.title = NSLocalizedString("NowPlayingLong", comment: "")
    }

}
