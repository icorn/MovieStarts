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
	let ROW_TYPE_EMPTY	= "MovieEmptyRow"

	
	// MARK: - Functions of WKInterfaceController
	
	
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

		// add localized menu item to context menu
		
		var menuIcon = UIImage(named: "refreshMenuItem@2x.png")

		if let menuIcon = menuIcon {
			addMenuItemWithImage(menuIcon, title: NSLocalizedString("menuItemRefresh", comment: ""), action: Selector("refreshButtonTapped"))
		}
		
		// load movie data
		loadMovieData()
	}
	
	
	func loadMovieData() {
		
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
					if let date0 = $0.releaseDate, date1 = $1.releaseDate, title0 = $0.sortTitle, title1 = $1.sortTitle {
						if ($0.isNowPlaying() && $1.isNowPlaying()) {
							// both movies are playing now: sort by title
							return title0.compare(title1) == NSComparisonResult.OrderedAscending
						}
						else if (date0 != date1) {
							// dates are different: compare dates
							return date0.compare(date1) == NSComparisonResult.OrderedAscending
						}
						else {
							// dates are equal: compare titles
							return title0.compare(title1) == NSComparisonResult.OrderedAscending
						}
					}
					else {
						// this should never happen
						return true
					}
				}
				
			}
		}
		
		// set up the table

		if (favoriteMovies.count > 0) {
			// set up table with favorite movies
			setUpFavorites(favoriteMovies)
		}
		else {
			// no favorite movies, tell the user
			movieTable.setRowTypes([ROW_TYPE_EMPTY])
			let row: MovieEmptyRow? = movieTable.rowControllerAtIndex(0) as? MovieEmptyRow
			row?.textLabel.setText(NSLocalizedString("WatchNoFavorites", comment: ""))
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
	
	
	func refreshButtonTapped() {
		loadMovieData()
	}
	
	private func setUpFavorites(movies: [MovieRecord]) {
		var oldDate: NSDate? = nil
		var rowTypeArray: [String] = []
		var rowContentArray: [AnyObject] = []
	
		// find out the necessary row-types
	
		for (movieIndex, movie) in enumerate(movies) {
			if let releaseDate = movie.releaseDate {
				if (movie.isNowPlaying() && (rowTypeArray.count == 0)) {
					// it's a current movie, but there is no section yet
					rowContentArray.append(NSLocalizedString("WatchNowPlaying", comment: ""))
					rowTypeArray.append(ROW_TYPE_DATE)
				}
				else if ((movie.isNowPlaying() == false) && ((oldDate == nil) || (oldDate != movie.releaseDate))) {
					// upcoming movies: a new sections starts
					rowContentArray.append(movie.releaseDateString)
					rowTypeArray.append(ROW_TYPE_DATE)
					oldDate = releaseDate
				}
	
				// add movie-row
				rowContentArray.append(movie)
				rowTypeArray.append(ROW_TYPE_MOVIE)
			}
		}
	
		// set row-types and fill table
	
		self.movieTable.setRowTypes(rowTypeArray)
	
		for (index, content) in enumerate(rowContentArray) {
			if (content is String) {
				let row: MovieDateRow? = movieTable.rowControllerAtIndex(index) as? MovieDateRow
	
				if let dateString: String? = content as? String {
					row?.dateLabel.setText(dateString)
				}
	
			}
			else if (content is MovieRecord) {
				var movie = (content as! MovieRecord)
				let row: MovieRow? = movieTable.rowControllerAtIndex(index) as? MovieRow
				row?.titleLabel.setText((movie.title != nil) ? movie.title! : movie.origTitle!)
				row?.detailLabel.setText(DetailTitleMaker.makeMovieDetailTitle(movie))
				row?.posterImage.setImage(movie.thumbnailImage.0)
				row?.movie = movie
			}
		}
	}
	
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
