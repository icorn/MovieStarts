//
//  NowTableViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 11.02.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit
import CloudKit


class NowTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {

	var movies: [MovieRecord]?

	
	override func viewDidLoad() {
        super.viewDidLoad()

		var tabBarController = navigationController?.parentViewController as? TabBarController
		
		if let saveTabBarController = tabBarController {
			self.movies = saveTabBarController.movies
			self.tableView.reloadData()
		}
		
		tableView.registerNib(UINib(nibName: "MovieTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieTableViewCell")
		navigationItem.title = NSLocalizedString("NowPlayingLong", comment: "")
    }
	
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if let saveMovies = self.movies {
			return 1
		}
		else {
			return 0
		}
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let saveMovies = self.movies {
			return saveMovies.count
		}
		else {
			return 0
		}
    }

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieTableViewCell", forIndexPath: indexPath) as! MovieTableViewCell

		if let movie = self.movies?[indexPath.row] {
			
			cell.posterImage.image = movie.thumbnailImage.0
			cell.titleText.text = movie.title
		
			// show labels with subtitles

			var subtitleLabels = [cell.subtitleText1, cell.subtitleText2, cell.subtitleText3]
			
			for (index, subtitle) in enumerate(movie.subtitleArray) {
				subtitleLabels[index]?.hidden = false
				subtitleLabels[index]?.text = subtitle
			}
			
			// hide unused labels
			
			for (var index = movie.subtitleArray.count; index < subtitleLabels.count; index++) {
				subtitleLabels[index]?.hidden = true
			}
		
			// vertically "center" the labels
			var moveY = (subtitleLabels.count - movie.subtitleArray.count) * 19
			cell.titleTextTopSpaceConstraint.constant = /*8 +*/ CGFloat(moveY / 2) - 4
		}
		
        return cell
    }

    
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if let saveMovies = self.movies, saveStoryboard = self.storyboard {
			var movieController: MovieViewController = saveStoryboard.instantiateViewControllerWithIdentifier("MovieViewController") as! MovieViewController
			movieController.movie = saveMovies[indexPath.row]
			navigationController?.pushViewController(movieController, animated: true)
		}
	}
	
}

