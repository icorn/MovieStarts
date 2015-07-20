//
//  NowTableViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 14.07.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit

class NowTableViewController: MovieTableViewController {

	override func getMovieFromIndexPath(indexPath: NSIndexPath) -> MovieRecord {
		return movies[indexPath.row]
	}

	override func viewDidLoad() {
		if let movieTabBarController = movieTabBarController {
			movies = movieTabBarController.nowMovies
		}
        super.viewDidLoad()
		navigationItem.title = NSLocalizedString("NowPlayingLong", comment: "")
    }

}
