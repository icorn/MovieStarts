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
        let cell = tableView.dequeueReusableCellWithIdentifier("NowCell", forIndexPath: indexPath) as! MovieTableViewCell

        // setting up titleText
        cell.titleText?.text = self.movies?[indexPath.row].title
        cell.titleText?.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        // setting up subtitleText
        cell.subtitleText?.text = "bla"
        cell.subtitleText?.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        // setting up thumbnail
        var thumbnailImagePath = self.movies?[indexPath.row].thumbnailImagePath

        if let thumbnailImagePath = thumbnailImagePath {
            cell.posterImage.image = UIImage(contentsOfFile: thumbnailImagePath)
        }
        
        cell.posterImage?.setTranslatesAutoresizingMaskIntoConstraints(false)
        cell.posterImage?.contentMode = UIViewContentMode.ScaleToFill
        
        cell.addConstraints([
            
            // constraints for posterImage
            
            NSLayoutConstraint(item: cell.posterImage, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: cell, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 10.0),
            NSLayoutConstraint(item: cell.posterImage, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: cell, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 10.0),
            NSLayoutConstraint(item: cell.posterImage, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 67.0),
            NSLayoutConstraint(item: cell.posterImage, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 100.0),

            // constraints for titleText
            
            NSLayoutConstraint(item: cell.posterImage, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: cell.titleText, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: -10.0),
            NSLayoutConstraint(item: cell.titleText, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: cell, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 10.0),
            NSLayoutConstraint(item: cell.titleText, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: cell, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: -30.0),
            
            // constraints for subtitleText
            
            NSLayoutConstraint(item: cell.posterImage, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: cell.subtitleText, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: -10.0),
            NSLayoutConstraint(item: cell.subtitleText, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: cell.titleText, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 5.0),
            NSLayoutConstraint(item: cell.subtitleText, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: cell, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: -30.0),
        ])

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

