//
//  DetailTitleMaker.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 13.03.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation


class DetailTitleMaker {

	class func makeMovieDetailTitle(movie: MovieRecord) -> String {
		
		var detailText = DetailTitleMaker.makeMinuteAndCertificationString(movie)
		var genre = movie.genres.first
		
		if let genre = genre {
			detailText += NSLocalizedString(genre, comment: "") + " | "
		}
		
		if (count(detailText) > 0) {
			detailText = detailText.substringToIndex(detailText.endIndex.predecessor().predecessor().predecessor())
		}
		
		return detailText
	}

	
	class func makeMovieDetailTitleComplete(movie: MovieRecord) -> String {

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

