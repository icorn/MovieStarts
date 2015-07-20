//
//  MovieTableViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 11.02.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit
import CloudKit


class MovieTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {

	var movies: [MovieRecord] = []
	var moviesInSections: [[MovieRecord]] = []
	var sections: [String] = []

	var movieTabBarController: TabBarController? {
		get {
			return navigationController?.parentViewController as? TabBarController
		}
	}

	override func viewDidLoad() {
        super.viewDidLoad()

		if let movieTabBarController = movieTabBarController {
			self.tableView.reloadData()
		}
		
		tableView.registerNib(UINib(nibName: "MovieTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieTableViewCell")
    }
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	func getMovieFromIndexPath(indexPath: NSIndexPath) -> MovieRecord {
		// dummy, will be overwritten
		return MovieRecord(dict: [:])
	}
	
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return movies.count
    }

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieTableViewCell", forIndexPath: indexPath) as! MovieTableViewCell
		let movie = getMovieFromIndexPath(indexPath)
			
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
		cell.titleTextTopSpaceConstraint.constant = CGFloat(moveY / 2) - 4
		
        return cell
    }
    
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		if let saveStoryboard = self.storyboard {
			var movieController: MovieViewController = saveStoryboard.instantiateViewControllerWithIdentifier("MovieViewController") as! MovieViewController
			movieController.movie = getMovieFromIndexPath(indexPath)
			navigationController?.pushViewController(movieController, animated: true)
		}
	}
	
}

