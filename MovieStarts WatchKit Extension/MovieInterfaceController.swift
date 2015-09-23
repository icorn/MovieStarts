//
//  MovieInterfaceController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 06.03.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import WatchKit
import Foundation


class MovieInterfaceController: WKInterfaceController {

	@IBOutlet weak var movieTable: WKInterfaceTable!
	
	let ROW_TYPE_MOVIE	= "MovieRow"
	let ROW_TYPE_DATE	= "MovieDateRow"

	
	// MARK: - Functions of WKInterfaceController
	
	
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
		
		// load movie data
		
		var favoriteMovies: [MovieRecord] = []
		var fileUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(Constants.MOVIESTARTS_GROUP)
		
		if ((fileUrl != nil) && (fileUrl!.path != nil)) {
			
			// get all movies from the iPhone
			
			var moviesPlistFile: String? = fileUrl!.path!.stringByAppendingPathComponent("MoviesUSA.plist")
			var loadedDictArray: [NSDictionary]? = NSArray(contentsOfFile: moviesPlistFile!) as? [NSDictionary]
			
			if let loadedDictArray = loadedDictArray {
				var allMovies: [MovieRecord] = movieDictsToMovieRecords(loadedDictArray)

				// only keep the favorite ones
				
				var favorites: [String]? = NSUserDefaults(suiteName: Constants.MOVIESTARTS_GROUP)?.objectForKey(Constants.PREFS_FAVORITES) as! [String]?

				if let favorites = favorites {
					for movie in allMovies {
						if contains(favorites, movie.id) {
							favoriteMovies.append(movie)
						}
					}
				}
				
				favoriteMovies.sort {
					return $0.releaseDate!.compare($1.releaseDate!) == NSComparisonResult.OrderedAscending
				}
				
			}
		}
		
		// set up the table

		var oldDate = NSDate(timeIntervalSince1970: 0)
		
		var rowTypeArray: [String] = []
		var rowContentArray: [AnyObject] = []

		// find out the necessary row-types
		
		for (movieIndex, movie) in enumerate(favoriteMovies) {
			if let saveDate = movie.releaseDate {
				if (saveDate != oldDate) {
					// different date than the movie before in the list: add date-row
					rowContentArray.append(saveDate)
					rowTypeArray.append(ROW_TYPE_DATE)
					oldDate = saveDate
				}
				
				// add movie-row
				rowContentArray.append(movie)
				rowTypeArray.append(ROW_TYPE_MOVIE)
			}
		}

		// set row-types and fill table
		
		self.movieTable.setRowTypes(rowTypeArray)

		for (index, content) in enumerate(rowContentArray) {
			if (content is NSDate) {
				let row: MovieDateRow? = movieTable.rowControllerAtIndex(index) as? MovieDateRow
				row?.dateLabel.setText(movieDateToString(content as! NSDate))
			}
			else if (content is MovieRecord) {
				var movie = (content as! MovieRecord)
				let row: MovieRow? = movieTable.rowControllerAtIndex(index) as? MovieRow
				row?.titleLabel.setText((movie.title != nil) ? movie.title! : movie.origTitle!)
				row?.detailLabel.setText(WatchKitUtil.makeMovieDetailTitle(movie))
				row?.posterImage.setImage(movie.thumbnailImage.0)
				row?.movie = movie
			}
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
		
		var row: AnyObject? = movieTable.rowControllerAtIndex(rowIndex)
		
		if (row is MovieRow) {
			if let movie = (row as! MovieRow).movie {
				pushControllerWithName("DetailController", context: movie)
			}
		}
	}
	

	// MARK: - Private helper-functions
	
	
	private func movieDateToString(releaseDate: NSDate) -> String {
		
		var gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
		gregorian?.timeZone = NSTimeZone(abbreviation: "GMT")!
		var retval = ""
		
		if let saveGregorian = gregorian {
			var components = saveGregorian.components(NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitYear, fromDate: releaseDate)
			retval = "\(components.month).\(components.day).\(components.year)"
		}

		return retval
	}
	
	private func movieDictsToMovieRecords(dictArray: NSArray) -> [MovieRecord] {
		var movieRecordArray: [MovieRecord] = []
		
		for dict in dictArray {
			movieRecordArray.append(MovieRecord(dict: dict as! [String : AnyObject]))
		}
		
		return movieRecordArray
	}


}

