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

		Database.getAllMovies(Constants.RECORD_TYPE_USA,
			completionHandler: { (movies: [MovieRecord]?) in
				self.movies = movies
				self.tableView.reloadData()
			},
			errorHandler: { (errorMessage: String) in
				println(errorMessage)
			}
		)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("NowCell", forIndexPath: indexPath) as UITableViewCell

		cell.textLabel?.text = self.movies?[indexPath.row].origTitle

        return cell
    }

}
