//
//  InterfaceController.swift
//  MovieStarts WatchKit Extension
//
//  Created by Oliver Eichhorn on 24.02.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

	@IBOutlet weak var menuTable: WKInterfaceTable!
	
	let assetNameUpcoming 	= "WatchCalendar"
	let assetNameNowPlaying = "WatchVideo1"
	let assetNameOldPlaying = "WatchVideo2"
	
	var allMovies: [MovieRecord] = []
	var nowMovies: [MovieRecord] = []
	var bestMovies: [MovieRecord] = []
	var upcomingMovies: [MovieRecord] = []
	
	
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

		self.cacheImages()

		// load movie data
		
		var fileUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(Constants.MOVIESTARTS_GROUP)
		
		if ((fileUrl != nil) && (fileUrl!.path != nil)) {
			var moviesPlistFile: String? = fileUrl!.path!.stringByAppendingPathComponent("MoviesUSA.plist")
			var loadedDictArray: [NSDictionary]? = NSArray(contentsOfFile: moviesPlistFile!) as? [NSDictionary]
			
			if let saveDictArray = loadedDictArray {
				self.allMovies = movieDictsToMovieRecords(saveDictArray)

				var today = NSDate()
				
				// iterate over all movies and sort them into one of three lists (and ignore the ones without release date)
				for movie in self.allMovies {
					if let saveDate = movie.releaseDate {
						if (saveDate.compare(today) == NSComparisonResult.OrderedDescending) {
							self.upcomingMovies.append(movie)
						}
						else {
							self.nowMovies.append(movie)
							
							if ((movie.voteCount > 10) && (movie.voteAverage >= 7.0)) {
								self.bestMovies.append(movie)
							}
						}
					}
				}

				self.upcomingMovies.sort {
					return $0.releaseDate!.compare($1.releaseDate!) == NSComparisonResult.OrderedAscending
				}

				self.nowMovies.sort {
					return $0.origTitle < $1.origTitle
				}

				self.bestMovies.sort {
					return $0.voteAverage > $1.voteAverage
				}
			}
		}
		
		// set up the table
		
		let menuTitleArray = ["Now Playing", "Recommended", "Upcoming"]
		let menuImageArray = [assetNameNowPlaying, assetNameOldPlaying, assetNameUpcoming]
		
		menuTable.setNumberOfRows(menuTitleArray.count, withRowType: "StartSceneTableRow")
		
		for (index, title) in enumerate(menuTitleArray) {
			let row: StartSceneTableRow? = menuTable.rowControllerAtIndex(index) as? StartSceneTableRow
			row?.rowLabel.setText(title)
			row?.rowImage.setImageNamed(menuImageArray[index])
		}
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

	override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
		
		if (rowIndex == 0) {
			// Current new movies
			pushControllerWithName("NowController", context: self.nowMovies)
		}
		else if (rowIndex == 1) {
			// Current older movies
			pushControllerWithName("NowController", context: self.bestMovies)
		}
		else if (rowIndex == 2) {
			// Upcoming movies
			pushControllerWithName("UpcomingController", context: self.upcomingMovies)
		}
	}
	
	
	func cacheImages() {
		var upcomingImage = UIImage(named: assetNameUpcoming)
		var nowPlayingImage = UIImage(named: assetNameNowPlaying)
		var oldPlayingImage = UIImage(named: assetNameOldPlaying)

		if let saveUpcomingImage = upcomingImage {
			WKInterfaceDevice.currentDevice().addCachedImage(saveUpcomingImage, name: assetNameUpcoming)
		}
		
		if let saveNowPlayingImage = nowPlayingImage {
			WKInterfaceDevice.currentDevice().addCachedImage(saveNowPlayingImage, name: assetNameNowPlaying)
		}

		if let saveOldPlayingImage = oldPlayingImage {
			WKInterfaceDevice.currentDevice().addCachedImage(saveOldPlayingImage, name: assetNameOldPlaying)
		}
	}
	
	
	func movieDictsToMovieRecords(dictArray: NSArray) -> [MovieRecord] {
		var movieRecordArray: [MovieRecord] = []
		
		for dict in dictArray {
			movieRecordArray.append(MovieRecord(dict: dict as [String : AnyObject]))
		}
		
		return movieRecordArray
	}

}

