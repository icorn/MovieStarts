//
//  UpcomingInterfaceController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 06.03.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import WatchKit
import Foundation


class UpcomingInterfaceController: WKInterfaceController {

	@IBOutlet weak var upcomingTable: WKInterfaceTable!
	
	let ROW_TYPE_MOVIE	= "MovieListRowUpcoming"
	let ROW_TYPE_DATE	= "MovieDateRow"

	
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
		// set up the table

		var movies = (context as [MovieRecord])
		var oldDate = NSDate(timeIntervalSince1970: 0)
		
		var rowTypeArray: [String] = []
		var rowContentArray: [AnyObject] = []

		// find out the necessary row-types
		
		for (movieIndex, movie) in enumerate(movies) {
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
		
		self.upcomingTable.setRowTypes(rowTypeArray)

		for (index, content) in enumerate(rowContentArray) {
			if (content is NSDate) {
				let row: MovieDateRow? = upcomingTable.rowControllerAtIndex(index) as? MovieDateRow
				row?.dateLabel.setText(movieDateToString(content as NSDate))
			}
			else if (content is MovieRecord) {
				var movie = (content as MovieRecord)
				let row: MovieListRowUpcoming? = upcomingTable.rowControllerAtIndex(index) as? MovieListRowUpcoming
				row?.titleLabel.setText((movie.title != nil) ? movie.title! : movie.origTitle!)
				row?.detailLabel.setText(WatchKitUtil.makeMovieDetailTitle(movie))
			}
		}
    }
	
	private func movieDateToString(releaseDate: NSDate) -> String {
		var gregorian = NSCalendar(calendarIdentifier: NSGregorianCalendar)
		gregorian?.timeZone = NSTimeZone(abbreviation: "GMT")!
		var retval = ""
		
		if let saveGregorian = gregorian {
			var components = saveGregorian.components(NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.YearCalendarUnit, fromDate: releaseDate)
			retval = "\(components.month).\(components.day).\(components.year)"
		}

		return retval
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
		var fakeDataObject = ""
		
		//		if (rowIndex == 0) {
		// Current movies
		//		pushControllerWithName("DetailController", context: fakeDataObject)
		//		}
	}
	
}

