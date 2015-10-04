//
//  DetailTitleMaker.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 13.03.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation


class DetailTitleMaker {

	class func makeMovieDetailTitle(movie: WatchMovieRecord) -> String {
		
		var detailText = DetailTitleMaker.makeMinuteAndCertificationString(movie)
		let genre = movie.genres.first
		
		if let genre = genre {
			detailText += NSLocalizedString(genre, comment: "") + " | "
		}
		
		if (detailText.characters.count > 0) {
			detailText = detailText.substringToIndex(detailText.endIndex.predecessor().predecessor().predecessor())
		}
		
		return detailText
	}

	
	class func makeMovieDetailTitleComplete(movie: WatchMovieRecord) -> String {

		var detailText = DetailTitleMaker.makeMinuteAndCertificationString(movie)

		// add genres
		
		if (movie.genres.count > 0) {
			for genre in movie.genres {
				detailText += NSLocalizedString(genre, comment: "") + ", "
			}
			
			detailText = detailText.substringToIndex(detailText.endIndex.predecessor().predecessor()) + " | "
		}

		// add countries
		
		if let countries = movie.countryString {
			detailText += countries + " | "
		}
		
		if (detailText.characters.count > 0) {
			detailText = detailText.substringToIndex(detailText.endIndex.predecessor().predecessor().predecessor())
		}
		
		return detailText
	}

	
	class func makeMinuteAndCertificationString(movie: WatchMovieRecord) -> String {
		var detailText = ""
		
		if (movie.runtime > 0) {
			detailText += "\(movie.runtime) m | "
		}
		
		if let movieCertification = movie.certification where movie.certification?.characters.count > 0 {
			var cert = movieCertification
			
			if (cert == "PG-13") {
				// fighting for every pixel ;-)
				cert = "PG13"
			}
			
			detailText += "\(cert) | "
		}
		
		return detailText
	}
	
}

