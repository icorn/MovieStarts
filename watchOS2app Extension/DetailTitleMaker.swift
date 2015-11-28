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

		let genreId = movie.genreIds.first
// TODO:	let genre = movie.genres.first
		
		if let genreId = genreId {
			detailText += String(genreId) + " | "
// TODO:		detailText += NSLocalizedString(genre, comment: "") + " | "
		}
		
		if (detailText.characters.count > 0) {
			detailText = detailText.substringToIndex(detailText.endIndex.predecessor().predecessor().predecessor())
		}
		
		return detailText
	}

	
	class func makeMovieDetailTitleComplete(movie: WatchMovieRecord) -> String {

		var detailText = DetailTitleMaker.makeMinuteAndCertificationString(movie)

		// add genres
		
		if (movie.genreIds.count > 0) {
			for genreId in movie.genreIds {
				detailText += String(genreId) + ", "
// TODO:				detailText += NSLocalizedString(genre, comment: "") + ", "
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
		
		if (movie.runtime[movie.currentCountry.languageArrayIndex] > 0) {
			detailText += "\(movie.runtime[movie.currentCountry.languageArrayIndex]) m | "
		}
		
		if movie.certification[movie.currentCountry.countryArrayIndex].characters.count > 0 {
			var cert = movie.certification[movie.currentCountry.countryArrayIndex]
			
			if (cert == "PG-13") {
				// fighting for every pixel ;-)
				cert = "PG13"
			}
			
			if (movie.currentCountry == MovieCountry.Germany) {
				cert = "FSK" + cert
			}
			
			detailText += "\(cert) | "
		}
		
		return detailText
	}
	
}

