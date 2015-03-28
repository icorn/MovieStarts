//
//  DetailInterfaceController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 15.03.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import WatchKit
import Foundation


class DetailInterfaceController: WKInterfaceController {

	@IBOutlet weak var titleLabel: WKInterfaceLabel!
	
	@IBOutlet weak var separator: WKInterfaceSeparator!
	
	@IBOutlet weak var dataGroup: WKInterfaceGroup!
	@IBOutlet weak var dataLabel: WKInterfaceLabel!
	
	@IBOutlet weak var directorGroup: WKInterfaceGroup!
	@IBOutlet weak var directorHeadlineLabel: WKInterfaceLabel!
	@IBOutlet weak var directorLabel: WKInterfaceLabel!
	
	@IBOutlet weak var actorGroup: WKInterfaceGroup!
	@IBOutlet weak var actorHeadlineLabel: WKInterfaceLabel!
	@IBOutlet weak var actorLabel: WKInterfaceLabel!
	
	@IBOutlet weak var synopsisGroup: WKInterfaceGroup!
	@IBOutlet weak var synopsisHeadlineLabel: WKInterfaceLabel!
	@IBOutlet weak var synopsisLabel: WKInterfaceLabel!
	
	@IBOutlet weak var coverImage: WKInterfaceImage!
	
	
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
		
		separator.setHeight(10.0)
		
		var movie: MovieRecord = (context as MovieRecord)
		
		if (movie.title != nil) {
			titleLabel.setText(movie.title!)
		}
		else if (movie.origTitle != nil) {
			titleLabel.setText(movie.origTitle!)
		}
		
		// data-label
		dataLabel.setText(WatchKitUtil.makeMovieDetailTitleComplete(movie))

		// directors
		if (movie.directors.count > 0) {
			var text = ""
			
			for director in movie.directors {
				text += director + ", "
			}

			if (movie.directors.count == 1) {
				directorHeadlineLabel.setText(NSLocalizedString("Director", comment: "") + ":")
			}
			else {
				directorHeadlineLabel.setText(NSLocalizedString("Directors", comment: "") + ":")
			}
			
			directorLabel.setText(text.substringToIndex(text.endIndex.predecessor().predecessor()))
		}
		else {
			directorGroup.setHidden(true)
		}
		
		// actors
		if (movie.actors.count > 0) {
			var text = ""
			
			for actor in movie.actors {
				text += actor + ", "
			}

			actorHeadlineLabel.setText(NSLocalizedString("Actors", comment: "") + ":")
			actorLabel.setText(text.substringToIndex(text.endIndex.predecessor().predecessor()))
		}
		else {
			actorGroup.setHidden(true)
		}
		
		// synopsis
		if ((movie.synopsis != nil) && (countElements(movie.synopsis!) > 0)) {
			synopsisHeadlineLabel.setText(NSLocalizedString("Synopsis", comment: "") + ":")
			synopsisLabel.setText(movie.synopsis!)
		}
		else {
			synopsisGroup.setHidden(true)
		}
		
		if (movie.posterUrl != nil) {
			
		}
		else {
			coverImage.setHidden(true)
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

}
