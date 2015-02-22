//
//  Constants.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 13.02.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation


struct Constants {
	
	static let CLOUDKIT_CONTAINER_ID		= "iCloud.com.icorn.MovieStarts"

	static let DOCUMENTS_FOLDER				= NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
	
	static let PREFS_LATEST_DB_MODIFICATION = "modificationDate"
	static let PREFS_LATEST_DB_UPDATE_CHECK = "lastestCheck"
	
	static let RECORD_TYPE_USA				= "MoviesUSA"
	static let RECORD_TYPE_GERMANY			= "MoviesGermany"

	static let DAYS_TILL_DB_UPDATE			= 7

	// MARK: keys for records fromt the cloud
	
	static let DB_ID_TMDB_ID				= "tmdbId"
	static let DB_ID_ORIG_TITLE				= "origTitle"
	static let DB_ID_POPULARITY				= "popularity"
	static let DB_ID_RUNTIME				= "runtime"
	static let DB_ID_VOTE_AVERAGE			= "voteAverage"
	static let DB_ID_VOTE_COUNT				= "voteCount"
	
	static let DB_ID_TITLE					= "title"
	static let DB_ID_SYNOPSIS				= "synopsis"
	static let DB_ID_RELEASE				= "release"
	static let DB_ID_GENRES					= "genres"
	static let DB_ID_CERTIFICATION			= "certification"
	static let DB_ID_POSTER_URL				= "posterUrl"
	static let DB_ID_PRODUCTION_COUNTRIES	= "productionCountries"
	
	static let DB_ID_IMDB_ID				= "imdbId"
	static let DB_ID_DIRECTORS				= "directors"
	static let DB_ID_ACTORS					= "actors"
	
	static let DB_ID_TRAILER_NAMES			= "trailerNames"
	static let DB_ID_TRAILER_IDS			= "trailerIds"
	static let DB_ID_ASSET					= "asset"
	
	static let DB_ID_HIDDEN					= "hidden"

}