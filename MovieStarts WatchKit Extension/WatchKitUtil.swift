//
//  WatchKitUtil.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 13.03.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation


class WatchKitUtil {

	class func makeMovieDetailTitle(movie: MovieRecord) -> String {
		
		var detailText = WatchKitUtil.makeMinuteAndCertificationString(movie)
		
		if (movie.genres.count > 0) {
			detailText += "\(movie.genres.first!) | "
		}
		
		if (count(detailText) > 0) {
			detailText = detailText.substringToIndex(detailText.endIndex.predecessor().predecessor().predecessor())
		}
		
		return detailText
	}

	
	class func makeMovieDetailTitleComplete(movie: MovieRecord) -> String {

		var detailText = WatchKitUtil.makeMinuteAndCertificationString(movie)

		// add genres
		
		if (movie.genres.count > 0) {
			for genre in movie.genres {
				detailText += genre + ", "
			}
			
			detailText = detailText.substringToIndex(detailText.endIndex.predecessor().predecessor()) + " | "
		}

		// add countries
		
		if let countries = movie.countryString {
			detailText += countries + " | "
		}
		
		if (count(detailText) > 0) {
			detailText = detailText.substringToIndex(detailText.endIndex.predecessor().predecessor().predecessor())
		}
		
		return detailText
	}

	
	class func makeMinuteAndCertificationString(movie: MovieRecord) -> String {
		var detailText = ""
		
		if (movie.runtime > 0) {
			detailText += "\(movie.runtime) m | "
		}
		
		if ((movie.certification != nil) && (count(movie.certification!) > 0)) {
			
			var cert = movie.certification!
			
			if (cert == "PG-13") {
				// fighting for every pixel ;-)
				cert = "PG13"
			}
			
			detailText += "\(cert) | "
		}
		
		return detailText
	}
	
}

