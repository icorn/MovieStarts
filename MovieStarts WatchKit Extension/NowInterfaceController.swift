//
//  NowInterfaceController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 06.03.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import WatchKit
import Foundation


class NowInterfaceController: WKInterfaceController {
	
	@IBOutlet weak var nowTable: WKInterfaceTable!
	
	var movies: [MovieRecord]?
	
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
		
		movies = (context as! [MovieRecord])
		
		// set up the table
		nowTable.setNumberOfRows(movies!.count, withRowType: "MovieListRowNow")
		
		for (index, movie) in enumerate(movies!) {
			let row: MovieListRowNow? = nowTable.rowControllerAtIndex(index) as? MovieListRowNow
			row?.titleLabel.setText((movie.title != nil) ? movie.title! : movie.origTitle!)
			row?.detailLabel.setText(WatchKitUtil.makeMovieDetailTitle(movie))
			
/*
			var date = ""
			
			if (movie.releaseDate != nil) {
				date = movie.releaseDate!.description
			}
			
			row?.detailLabel.setText("\(movie.popularity) - \(date)")
*/
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
		if let saveMovies = self.movies {
			pushControllerWithName("DetailController", context: saveMovies[rowIndex])
		}
	}

}
