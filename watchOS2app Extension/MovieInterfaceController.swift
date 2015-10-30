//
//  MovieInterfaceController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 06.03.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class MovieInterfaceController: WKInterfaceController { //, WCSessionDelegate {

	@IBOutlet var movieTable: WKInterfaceTable!
	
	let ROW_TYPE_MOVIE	= "MovieRow"
	let ROW_TYPE_DATE	= "DateRow"
	let ROW_TYPE_EMPTY	= "EmptyRow"

	
	// MARK: - Functions of WKInterfaceController
	
	override func didAppear() {
		super.didAppear()
		loadMovieDataFromFile()
	}
	
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
		
		WatchSessionManager.sharedManager.rootInterfaceController = self

		// add localized menu item to context menu
		
		let menuIcon = UIImage(named: "refreshMenuItem@2x.png")

		if let menuIcon = menuIcon {
			addMenuItemWithImage(menuIcon, title: NSLocalizedString("menuItemRefresh", comment: ""), action: Selector("refreshButtonTapped"))
		}
		
		// go on depending on launch-status
		
		guard let launchStatus = WatchSessionManager.sharedManager.launchStatus else { return }

		switch (launchStatus) {
			case .ShowMovieList: 	loadMovieDataFromFile()
			case .ConnectError: 	showSingleTextCell(NSLocalizedString("WatchConnectError", comment: ""))
			case .UserShouldStartPhone:	showSingleTextCell(NSLocalizedString("WatchUserShouldStartPhone", comment: ""))
		}
	}
	
	
	func showSingleTextCell(text: String) {
		movieTable.setRowTypes([ROW_TYPE_EMPTY])
		let row: EmptyRow? = movieTable.rowControllerAtIndex(0) as? EmptyRow
		row?.textLabel.setText(text)
	}
	
	
	func loadMovieDataFromFile() {
		var favoriteMovies: [WatchMovieRecord] = []
		let fileManager = NSFileManager.defaultManager()

		guard let documentDir = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first else { return }
		guard let moviesPlistFile = documentDir.URLByAppendingPathComponent(Constants.watchMovieFileName).path else { return }

		let loadedDictArray: [NSDictionary]? = NSArray(contentsOfFile: moviesPlistFile) as? [NSDictionary]
		
		if let loadedDictArray = loadedDictArray {
			favoriteMovies = movieDictsToMovieRecords(loadedDictArray)
			
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

		// set up the table

		if (favoriteMovies.count > 0) {
			// set up table with favorite movies
			setUpFavorites(favoriteMovies)
		}
		else {
			// no favorite movies, tell the user
			movieTable.setRowTypes([ROW_TYPE_EMPTY])
			let row: EmptyRow? = movieTable.rowControllerAtIndex(0) as? EmptyRow
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
				pushControllerWithName("DetailInterfaceController", context: movie)
			}
		}
	}
	

	func refreshButtonTapped() {
		do {
			try WatchSessionManager.sharedManager.updateApplicationContext([Constants.watchAppContextGetAllMovies : Constants.watchAppContextValueEveryting])
		} catch let error as NSError {
			NSLog("Error updating AppContext: \(error.description)")
			WatchSessionManager.sharedManager.launchStatus = LaunchStatus.ConnectError
			return
		}
	}

	
	// MARK: - Private helper-functions
	
	
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
		
		// set row-types and fill table
	
		self.movieTable.setRowTypes(rowTypeArray)
	
		for (index, content) in rowContentArray.enumerate() {
			if (content is String) {
				let row: DateRow? = movieTable.rowControllerAtIndex(index) as? DateRow
	
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
