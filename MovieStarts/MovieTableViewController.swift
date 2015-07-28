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
	
	// MARK: - UIViewController

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

	// MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if moviesInSections.count > 0 {
			return sections.count
		}
		else {
			return 1
		}
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if (moviesInSections.count > section) {
			return moviesInSections[section].count
		}
		else {
			return movies.count
		}
    }
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if (sections.count > section) {
			return sections[section]
		}
		else {
			return nil
		}
	}
	
	// MARK: - UITableView
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieTableViewCell", forIndexPath: indexPath) as! MovieTableViewCell
		
		var movie: MovieRecord?
		
		if moviesInSections.count > 0 {
			movie = moviesInSections[indexPath.section][indexPath.row]
		}
		else {
			movie = movies[indexPath.row]
		}
		
		if let movie = movie {
			cell.posterImage.image = movie.thumbnailImage.0
			cell.titleText.text = movie.title
			cell.tag = Constants.tagTableCell
		
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
			
			// add favorite-icon
			
			if contains(Favorites.IDs, movie.id) {
				addFavoriteIconToCell(cell)
			}
			else {
				removeFavoriteIconFromCell(cell)
				
/*
				var favImageView: UIImageView? = cell.viewWithTag(Constants.tagFavoriteView) as? UIImageView
				
				if let favImageView = favImageView {
					favImageView.removeFromSuperview()
				}
*/
			}
		}
		
        return cell
    }
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		if let saveStoryboard = self.storyboard {
			var movieController: MovieViewController = saveStoryboard.instantiateViewControllerWithIdentifier("MovieViewController") as! MovieViewController
			
			if moviesInSections.count > 0 {
				movieController.movie = moviesInSections[indexPath.section][indexPath.row]
			}
			else {
				movieController.movie = movies[indexPath.row]
			}
			
			navigationController?.pushViewController(movieController, animated: true)
		}
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 116
	}
	
	override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
		var movieID: String!
		
		if moviesInSections.count > 0 {
			movieID = moviesInSections[indexPath.section][indexPath.row].id
		}
		else {
			movieID = movies[indexPath.row].id
		}

		var title: String!
		var backColor: UIColor!
		
		if (contains(Favorites.IDs, movieID)) {
			title = NSLocalizedString("RemoveFromFavoritesShort", comment: "")
			backColor = UIColor.redColor()
		}
		else {
			title = NSLocalizedString("AddToFavoritesShort", comment: "")
			backColor = UIColor.blueColor()
		}
		
		var favAction: UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: title, handler: {
			(action: UITableViewRowAction!, path: NSIndexPath!) -> () in

				// find out movie id
			
				var movieID: String!
				if self.moviesInSections.count > 0 {
					movieID = self.moviesInSections[indexPath.section][indexPath.row].id
				}
				else {
					movieID = self.movies[indexPath.row].id
				}
			
				// add or remove movie as favorite
			
				var currentCell: UITableViewCell? = self.tableView.cellForRowAtIndexPath(indexPath)

				if (contains(Favorites.IDs, movieID)) {
					// movie is favorite: remove it as favorite and remove favorite-icon
					Favorites.removeMovieID(movieID)
					self.removeFavoriteIconFromCell(currentCell)
				}
				else {
					// movie was no favorite: add to as favorite and add favorite-icon
					Favorites.addMovieID(movieID)

					var contentView: UIView? = currentCell?.viewWithTag(Constants.tagTableCell)
					
					if let contentView = contentView {
						self.addFavoriteIconToCell(contentView)
					}
				}
			
				self.tableView.setEditing(false, animated: true)
			}
		)
		
		favAction.backgroundColor = backColor
		
		return [favAction]
	}
	
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		// Bug in iOS 8: This function is not called, but without it, swiping is not enabled
	}
	
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}

	
	// MARK: - Private helper functions
	
	private func addFavoriteIconToCell(cell: UIView) {
		var favImage = UIImage(named: "favoritecorner")
		
		if let favImage = favImage {
			var favView = UIImageView(frame: CGRect(x: cell.frame.maxX - favImage.size.width, y: 0, width: favImage.size.width, height: favImage.size.height))
			favView.image = favImage
			favView.tag = Constants.tagFavoriteView
			cell.addSubview(favView)
		}
	}

	private func removeFavoriteIconFromCell(cell: UITableViewCell?) {
		var favImageView: UIImageView? = cell?.viewWithTag(Constants.tagFavoriteView) as? UIImageView
		
		if let favImageView = favImageView {
			favImageView.removeFromSuperview()
		}
	}
}

