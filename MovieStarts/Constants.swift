//
//  Constants.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 13.02.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation


public struct Constants {
	
	// MARK: - Constants
	
	static let CLOUDKIT_CONTAINER_ID		= "iCloud.com.icorn.MovieStarts"
	static let MOVIESTARTS_GROUP			= "group.com.icorn.MovieStarts"
	static let THUMBNAIL_FOLDER				= "/Thumbnails"
	static let BIG_POSTER_FOLDER			= "/BigPoster"
	
	static let PREFS_LATEST_DB_MODIFICATION 		= "modificationDate"
	static let PREFS_LATEST_DB_SUCCESSFULL_UPDATE 	= "lastestCheck"
	static let PREFS_FAVORITES						= "favorites"

	static let SUBSCRIPTION_ID_USA			= "MovieStartsSubscriptionUSA"
	static let SUBSCRIPTION_ID_GERMANY		= "MovieStartsSubscriptionGermany"
	
	static let RECORD_TYPE_USA				= "MoviesUSA"
	static let RECORD_TYPE_GERMANY			= "MoviesGermany"

	static let RECORD_TYPE_RESULT_USA		= "ResultMoviesUSA"
	static let RECORD_ID_RESULT_USA			= "ResultUSA"
	
	static let HOURS_BETWEEN_DB_UPDATES		= 24
	static let MAX_DAYS_IN_THE_PAST			= 30.0
	
	static let tagFavoriteView: Int			= 10000
	static let tagTableCell: Int			= 10001

	// MARK: - Keys for records fromt the cloud
	
	public static let DB_ID_TMDB_ID					= "tmdbId"
	public static let DB_ID_ORIG_TITLE				= "origTitle"
	public static let DB_ID_RUNTIME					= "runtime"
	public static let DB_ID_VOTE_AVERAGE			= "voteAverage"
	public static let DB_ID_TITLE					= "title"
	public static let DB_ID_SORT_TITLE				= "sortTitle"
	public static let DB_ID_SYNOPSIS				= "synopsis"
	public static let DB_ID_RELEASE					= "release"
	public static let DB_ID_GENRES					= "genres"
	public static let DB_ID_CERTIFICATION			= "certification"
	public static let DB_ID_POSTER_URL				= "posterUrl"
	public static let DB_ID_PRODUCTION_COUNTRIES	= "productionCountries"
	public static let DB_ID_IMDB_ID					= "imdbId"
	public static let DB_ID_DIRECTORS				= "directors"
	public static let DB_ID_ACTORS					= "actors"
	public static let DB_ID_TRAILER_NAMES			= "trailerNames"
	public static let DB_ID_TRAILER_IDS				= "trailerIds"
	public static let DB_ID_ASSET					= "asset"
	public static let DB_ID_HIDDEN					= "hidden"
	
	public static let DB_ID_POSTER_ASSET			= "posterAsset"
	public static let DB_ID_BIG_POSTER_ASSET		= "bigPosterAsset"
	
	public static let DB_ID_ID						= "id"

//	public static let DB_ID_POPULARITY				= "popularity"
//	public static let DB_ID_VOTE_COUNT				= "voteCount"

}