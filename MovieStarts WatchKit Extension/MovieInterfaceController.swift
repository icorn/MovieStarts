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
		
		let menuIcon = UIImage(named: "refreshMenuItem@2x.png")

		if let menuIcon = menuIcon {
			addMenuItemWithImage(menuIcon, title: NSLocalizedString("menuItemRefresh", comment: ""), action: Selector("refreshButtonTapped"))
		}
		
		// load movie data
		loadMovieData()
	}
	
	
	func loadMovieData() {
		
		var favoriteMovies: [WatchMovieRecord] = []
		let fileUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(Constants.MOVIESTARTS_GROUP)
		
		if let fileUrl = fileUrl, fileUrlPath = fileUrl.path {
			
			// get all movies from the iPhone
			
//			let moviesPlistFile: String? = fileUrlPath.stringByAppendingPathComponent("MoviesUSA.plist")
			
			var moviesPlistFile = fileUrlPath
			
			if moviesPlistFile.hasSuffix("/") {
				moviesPlistFile.appendContentsOf("MoviesUSA.plist")
			}
			else {
				moviesPlistFile.appendContentsOf("/MoviesUSA.plist")
			}
			
			let loadedDictArray: [NSDictionary]? = NSArray(contentsOfFile: moviesPlistFile) as? [NSDictionary]
			
			if let loadedDictArray = loadedDictArray {
				let allMovies: [WatchMovieRecord] = movieDictsToMovieRecords(loadedDictArray)

				// only keep the favorite ones
				
				let favorites: [String]? = NSUserDefaults(suiteName: Constants.MOVIESTARTS_GROUP)?.objectForKey(Constants.PREFS_FAVORITES) as? [String]

				if let favorites = favorites {
					for movie in allMovies {
						if favorites.contains(movie.id) {
							favoriteMovies.append(movie)
						}
					}
				}
				
				favoriteMovies.sortInPlace {
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
		
		let row: AnyObject? = movieTable.rowControllerAtIndex(rowIndex)
		
		if let row = row as? MovieRow {
			if let movie = row.movie {
				pushControllerWithName("DetailController", context: movie)
			}
		}
	}

	
	// MARK: - Private helper-functions
	
	
	func refreshButtonTapped() {
		loadMovieData()
	}
	
	private func setUpFavorites(movies: [WatchMovieRecord]) {
		var oldDate: NSDate? = nil
		var rowTypeArray: [String] = []
		var rowContentArray: [AnyObject] = []
	
		// find out the necessary row-types
	
		for movie in movies {
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
		
		
/*
		for (movieIndex, movie) in movies.enumerate() {
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
*/
		
		// set row-types and fill table
	
		self.movieTable.setRowTypes(rowTypeArray)
	
		for (index, content) in rowContentArray.enumerate() {
			if (content is String) {
				let row: MovieDateRow? = movieTable.rowControllerAtIndex(index) as? MovieDateRow
	
				if let dateString: String? = content as? String {
					row?.dateLabel.setText(dateString)
				}
	
			}
			else if let content = content as? WatchMovieRecord {
				let movie = content
				let row: MovieRow? = movieTable.rowControllerAtIndex(index) as? MovieRow
				row?.titleLabel.setText(movie.title ?? movie.origTitle)
				row?.detailLabel.setText(DetailTitleMaker.makeMovieDetailTitle(movie))
				row?.posterImage.setImage(movie.thumbnailImage.0)
				row?.movie = movie
			}
		}
	}
	
	private func movieDateToString(releaseDate: NSDate) -> String {
		
		var retval = ""
		let gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
		let gmtZone = NSTimeZone(abbreviation: "GMT")
		
		if let gmtZone = gmtZone {
			gregorian?.timeZone = gmtZone
			
			if let saveGregorian = gregorian {
				let components = saveGregorian.components([NSCalendarUnit.Day, NSCalendarUnit.Month, NSCalendarUnit.Year], fromDate: releaseDate)
				retval = "\(components.month).\(components.day).\(components.year)"
			}
		}
		
		return retval
	}
	
	private func movieDictsToMovieRecords(dictArray: NSArray) -> [WatchMovieRecord] {
		var movieRecordArray: [WatchMovieRecord] = []
		
		for dict in dictArray {
			if let dict = dict as? [String : AnyObject] {
				movieRecordArray.append(WatchMovieRecord(dict: dict))
			}
		}
		
		return movieRecordArray
	}

}

