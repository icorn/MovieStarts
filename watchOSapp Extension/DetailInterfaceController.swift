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

	
	@IBOutlet var coverImage: WKInterfaceImage!
	@IBOutlet var titleLabel: WKInterfaceLabel!
	@IBOutlet var separator: WKInterfaceSeparator!
	
	@IBOutlet var dataGroup: WKInterfaceGroup!
	@IBOutlet var dataLabel: WKInterfaceLabel!
	
	@IBOutlet var directorGroup: WKInterfaceGroup!
	@IBOutlet var directorHeadlineLabel: WKInterfaceLabel!
	@IBOutlet var directorLabel: WKInterfaceLabel!
	
	@IBOutlet var actorGroup: WKInterfaceGroup!
	@IBOutlet var actorHeadlineLabel: WKInterfaceLabel!
	@IBOutlet var actorLabel: WKInterfaceLabel!
	
	@IBOutlet var synopsisGroup: WKInterfaceGroup!
	@IBOutlet var synopsisHeadlineLabel: WKInterfaceLabel!
	@IBOutlet var synopsisLabel: WKInterfaceLabel!
	
	
	
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
		
		separator.setHeight(10.0)
		
		let movie: WatchMovieRecord? = (context as? WatchMovieRecord)
		
		if let movie = movie {
			if let title = movie.title , title.characters.count > 0 {
				titleLabel.setText(title)
			}
			else if let movieOrigTitle = movie.origTitle {
				titleLabel.setText(movieOrigTitle)
			}
			
			// data-label
			dataLabel.setText(DetailTitleMaker.makeMovieDetailTitleComplete(movie: movie))

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
				
				directorLabel.setText(text.substringByRemovingLastCharacters(numberOfCharacters: 2))
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

				actorHeadlineLabel.setText(NSLocalizedString("Actors", comment: ""))
				actorLabel.setText(text.substringByRemovingLastCharacters(numberOfCharacters: 2))
			}
			else {
				actorGroup.setHidden(true)
			}
			
			// synopsis
			if let synopsis = movie.synopsis , synopsis.characters.count > 0 {
				synopsisHeadlineLabel.setText(NSLocalizedString("Synopsis", comment: ""))
				synopsisLabel.setText(synopsis)
			}
			else {
				synopsisGroup.setHidden(true)
			}
			
			// poster
			if movie.thumbnailImage.1 {
				coverImage.setImage(movie.thumbnailImage.0)
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

}
