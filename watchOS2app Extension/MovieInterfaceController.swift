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


class MovieInterfaceController: WKInterfaceController {

	@IBOutlet var movieTable: WKInterfaceTable!
	
	let ROW_TYPE_MOVIE	= "MovieRow"
	let ROW_TYPE_DATE	= "DateRow"
	let ROW_TYPE_EMPTY	= "EmptyRow"

	
	// MARK: - Functions of WKInterfaceController
	
	override func didAppear() {
		super.didAppear()
		loadMovieDataFromFile()
		
		// for future use, if we want to use notifications with custom actions

/*
		// check if app was called by notification
		
		if let watchDelegate = WKExtension.sharedExtension().delegate as? ExtensionDelegate {
			guard 	let movieTitles = watchDelegate.notificationMovieTitles,
					let movieDate = watchDelegate.notificationMovieDate,
					let alarmDay = watchDelegate.notificationAlarmDay else {
				return
			}
			
			if (movieTitles.count == 1) {
				// forward user to the one movie which he was notified for.
				// but first search the movie.
				
				for index in 0 ..< movieTable.numberOfRows {
					if let movieRow = movieTable.rowControllerAtIndex(index) as? MovieRow, movie = movieRow.movie {
						if (movieTitles[0] == movie.title) {
							pushControllerWithName("DetailInterfaceController", context: movie)
							break
						}
					}
				}
			}
			else  if (movieTitles.count > 1) {
				// show message with all movies the user was notified for
				
				var messageBody = "\(movieTitles.count) "
				
				switch(alarmDay) {
					case 0 : messageBody.appendContentsOf(NSLocalizedString("MoviesReleasedToday", comment: ""))
					case -1: messageBody.appendContentsOf(NSLocalizedString("MoviesReleasedTomorrow", comment: ""))
					case -2: messageBody.appendContentsOf(NSLocalizedString("MoviesReleasedAfterTomorrow", comment: ""))
					default: messageBody.appendContentsOf(NSLocalizedString("MoviesReleasedSoon1", comment: "") + movieDate + NSLocalizedString("MoviesReleasedSoon2", comment: ""))
				}

				messageBody.appendContentsOf(":\n")
				
				for title in movieTitles {
					messageBody += "\n\u{25CF} " + title
				}
				
				let closeAction = WKAlertAction(title: NSLocalizedString("Close", comment: ""), style: WKAlertActionStyle.Default) {}
				presentAlertControllerWithTitle(NSLocalizedString("NotificationMsgWindowTitle", comment: ""), message: messageBody, preferredStyle: WKAlertControllerStyle.ActionSheet, actions: [closeAction])
			}
		}
*/
	}
	
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
		
		WatchSessionManager.sharedManager.rootInterfaceController = self

		// add localized menu item to context menu
		
		let menuIcon = UIImage(named: "refreshMenuItem@2x.png")

		if let menuIcon = menuIcon {
			addMenuItemWithImage(menuIcon, title: NSLocalizedString("menuItemRefresh", comment: ""), action: #selector(MovieInterfaceController.refreshButtonTapped))
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
				let date0 = $0.releaseDate ?? NSDate(timeIntervalSince1970: 0)
				let date1 = $1.releaseDate ?? NSDate(timeIntervalSince1970: 0)
				let title0 = $0.sortTitle ?? ""
				let title1 = $1.sortTitle ?? ""

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
			try WatchSessionManager.sharedManager.updateApplicationContext([Constants.watchAppContextGetDataFromPhone : Constants.watchAppContextValueEveryting])
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
			let releaseDate = movie.releaseDate
			
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
	
	private func movieDictsToMovieRecords(dictArray: NSArray) -> [WatchMovieRecord] {
		var movieRecordArray: [WatchMovieRecord] = []
		
		for dict in dictArray {
			if let dict = dict as? [String : AnyObject] {
				movieRecordArray.append(
					WatchMovieRecord(
						origTitle: dict[Constants.dbIdOrigTitle] as? String,
						runtime: dict[Constants.dbIdRuntime] as? Int,
						title: dict[Constants.dbIdTitle] as? String,
						sortTitle: dict[Constants.dbIdSortTitle] as? String,
						synopsis: dict[Constants.dbIdSynopsis] as? String,
						releaseDate: dict[Constants.dbIdRelease] as? NSDate,
						genreNames: (dict[Constants.dbIdGenreNames] as? [String]) ?? [],
						countries: dict[Constants.dbIdProductionCountries] as? String,
						certification: dict[Constants.dbIdCertification] as? String,
						posterUrl: dict[Constants.dbIdPosterUrl] as? String,
						directors: (dict[Constants.dbIdDirectors] as? [String]) ?? [],
						actors: (dict[Constants.dbIdActors] as? [String]) ?? []
					)
				)
			}
		}
		
		return movieRecordArray
	}

}
