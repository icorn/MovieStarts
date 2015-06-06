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
        let cell = tableView.dequeueReusableCellWithIdentifier("NowCell", forIndexPath: indexPath) as! UITableViewCell

		cell.textLabel?.text = self.movies?[indexPath.row].origTitle

        return cell
    }

	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if let saveMovies = self.movies, saveStoryboard = self.storyboard {
			var movieController: MovieViewController = saveStoryboard.instantiateViewControllerWithIdentifier("MovieViewController") as! MovieViewController
			movieController.movie = saveMovies[indexPath.row]
			
//			self.presentViewController(movieController, animated: true, completion: nil)

			navigationController?.pushViewController(movieController, animated: true)
			
/*

			F3aInfoContent *infoContent = [[F3aInfoContent alloc] init];
			infoContent.nid = ((F3aInfonid*)selectedObject).nid;
			infoContent.nidString = ((F3aInfonid*)selectedObject).name;
			
			F3aFilmDetailTableController *filmDetailTableController = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonMovieList"];
			filmDetailTableController.infoContent = infoContent;
			
			[self.navigationController pushViewController:filmDetailTableController animated:YES];

*/
			
			
			
		}
	}
	
}

