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
		
		var detailText = DetailTitleMaker.makeMinuteAndCertificationString(movie: movie)

		let genreName = movie.genreNames.first

		if let genreName = genreName {
			detailText += genreName + " | "
		}
		
		if (detailText.characters.count > 0) {
			detailText = detailText.substringByRemovingLastCharacters(numberOfCharacters: 3)
		}
		
		return detailText
	}

	
	class func makeMovieDetailTitleComplete(movie: WatchMovieRecord) -> String {

		var detailText = DetailTitleMaker.makeMinuteAndCertificationString(movie: movie)

		// add genres
		
		if (movie.genreNames.count > 0) {
			for genreName in movie.genreNames {
				detailText += genreName + ", "
			}
			
			detailText = detailText.substringByRemovingLastCharacters(numberOfCharacters: 2)
            detailText += " | "
		}

		// add countries
		
		if let countries = movie.countries {
			detailText += countries + " | "
		}
		
		if (detailText.characters.count > 0) {
			detailText = detailText.substringByRemovingLastCharacters(numberOfCharacters: 3)
		}
		
		return detailText
	}

	
	class func makeMinuteAndCertificationString(movie: WatchMovieRecord) -> String {
		var detailText = ""
		
		if let runtime = movie.runtime , runtime > 0 {
			detailText += "\(runtime) m | "
		}
		
		if let cert = movie.certification , cert.characters.count > 0 {
			detailText += "\(cert) | "
		}
		
		return detailText
	}
	
}

