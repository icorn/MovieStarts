//
//  MovieRecord.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 15.02.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation
import CloudKit


class MovieRecord {
	
	var tmdbId:Int?
	var origTitle:String?
	
	var popularity:Int = 0
	var runtime:Int = 0
	var voteAverage:Double = 0.0
	var voteCount:Int = 0
	
	var title:String?
	var synopsis:String?
	var releaseDate:NSDate?
	var genres:[String] = []
	var genreIds:[Int] = []
	var productionCountries:[String] = []
	var certification:String?
	var posterUrl:String?
	var imdbId:String?
	var directors:[String] = []
	var actors:[String] = []
	
	var trailerNames:[String] = []
	var trailerIds:[String] = []

	
	init(dict: [String: AnyObject]) {
		
		if (dict[Constants.DB_ID_TMDB_ID] != nil) 		{ self.tmdbId 			= dict[Constants.DB_ID_TMDB_ID] 		as? Int }
		if (dict[Constants.DB_ID_ORIG_TITLE] != nil)	{ self.origTitle 		= dict[Constants.DB_ID_ORIG_TITLE] 		as? String }
		if (dict[Constants.DB_ID_TITLE] != nil) 		{ self.title 			= dict[Constants.DB_ID_TITLE] 			as? String }
		if (dict[Constants.DB_ID_SYNOPSIS] != nil) 		{ self.synopsis 		= dict[Constants.DB_ID_SYNOPSIS] 		as? String }
		if (dict[Constants.DB_ID_RELEASE] != nil) 		{ self.releaseDate 		= dict[Constants.DB_ID_RELEASE] 		as? NSDate }
		if (dict[Constants.DB_ID_CERTIFICATION] != nil) { self.certification 	= dict[Constants.DB_ID_CERTIFICATION] 	as? String }
		if (dict[Constants.DB_ID_POSTER_URL] != nil) 	{ self.posterUrl 		= dict[Constants.DB_ID_POSTER_URL] 		as? String }
		if (dict[Constants.DB_ID_IMDB_ID] != nil) 		{ self.imdbId 			= dict[Constants.DB_ID_IMDB_ID] 		as? String }
		
		if (dict[Constants.DB_ID_POPULARITY] != nil) 	{ self.popularity 		= dict[Constants.DB_ID_POPULARITY] 		as Int }
		if (dict[Constants.DB_ID_RUNTIME] != nil) 		{ self.runtime 			= dict[Constants.DB_ID_RUNTIME] 		as Int }
		if (dict[Constants.DB_ID_VOTE_AVERAGE] != nil) 	{ self.voteAverage 		= dict[Constants.DB_ID_VOTE_AVERAGE] 	as Double }
		if (dict[Constants.DB_ID_VOTE_COUNT] != nil) 	{ self.voteCount 		= dict[Constants.DB_ID_VOTE_COUNT] 		as Int }
		if (dict[Constants.DB_ID_GENRES] != nil) 		{ self.genres 			= dict[Constants.DB_ID_GENRES] 			as [String] }
		if (dict[Constants.DB_ID_DIRECTORS] != nil) 	{ self.directors 		= dict[Constants.DB_ID_DIRECTORS] 		as [String] }
		if (dict[Constants.DB_ID_ACTORS] != nil) 		{ self.actors 			= dict[Constants.DB_ID_ACTORS] 			as [String] }
		if (dict[Constants.DB_ID_TRAILER_NAMES] != nil) { self.trailerNames 	= dict[Constants.DB_ID_TRAILER_NAMES] 	as [String] }
		if (dict[Constants.DB_ID_TRAILER_IDS] != nil) 	{ self.trailerIds 		= dict[Constants.DB_ID_TRAILER_IDS] 	as [String] }

		if (dict[Constants.DB_ID_PRODUCTION_COUNTRIES] != nil) { self.productionCountries = dict[Constants.DB_ID_PRODUCTION_COUNTRIES] as [String] }
	}
}
