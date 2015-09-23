//
//  MovieRow.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 22.09.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit
import WatchKit
import Foundation


class MovieRow: NSObject {

	@IBOutlet weak var posterImage: WKInterfaceImage!
	@IBOutlet weak var titleLabel: WKInterfaceLabel!
	@IBOutlet weak var detailLabel: WKInterfaceLabel!

	var movie: MovieRecord?
	
//	var image: UIImage?
//	var imageFound: Bool = false
}
