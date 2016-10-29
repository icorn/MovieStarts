//
//  MovieRow.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 10.10.15.
//  Copyright © 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit
import WatchKit
import Foundation


class MovieRow: NSObject {

	@IBOutlet var posterImage: WKInterfaceImage!
	@IBOutlet var titleLabel: WKInterfaceLabel!
	@IBOutlet var detailLabel: WKInterfaceLabel!

	var movie: WatchMovieRecord?
}
