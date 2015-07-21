//
//  Util.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 25.02.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation
import UIKit


class MovieStartsUtil {
	
	/**
		Shortens the given country name.
	
		:param:	name	The country name to be shortened
	
		:returns: The shortened country name (often the same as the input name).
	*/
	class func shortenCountryname(name: String) -> String {
		
		switch(name) {
		case "United States of America":
			return "USA"
		case "United Kingdom":
			return "UK"
		default:
			return name
		}
	}
	
	
	/**
		Generates the subtitle for the detail view of a movie.
	
		:param:	movie	The MovieRecord object to generate the subtitle for
	
		:returns: The generated subtitle, consting of the runtime and the production countries.
	*/
	class func generateDetailSubtitle(movie: MovieRecord) -> String {
		
		var detailText = ""
		
		// add runtime 
		
		if (movie.runtime > 0) {
			detailText += "\(movie.runtime) min | "
		}
		
		// add countries
		
		if (movie.productionCountries.count > 0) {
			for country in movie.productionCountries {
				detailText += MovieStartsUtil.shortenCountryname(country) + ", "
			}
		}
		
		if (count(detailText) > 0) {
			// remove last two characters
			detailText = detailText.substringToIndex(detailText.endIndex.predecessor().predecessor())
		}
		
		return detailText
	}
	
	
	/**
		Generates the string of call genres of a movie.
	
		:param:	movie	The MovieRecord object to generate the subtitle for
	
		:returns: The generated string consisting of the movies genres.
	*/
	class func generateGenreString(movie: MovieRecord) -> String {
		
		var genreText = ""
		
		if (movie.genres.count > 0) {
			
			for genre in movie.genres {
				genreText += genre + ", "
			}
		}
		
		if (count(genreText) > 0) {
			genreText = genreText.substringToIndex(genreText.endIndex.predecessor().predecessor())
		}
		
		return genreText
	}

}