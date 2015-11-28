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
	
	static let imageBaseUrl					= "http://image.tmdb.org/t/p/"
	static let cloudkitContainerId			= "iCloud.com.icorn.MovieStarts"
	static let movieStartsGroup				= "group.com.icorn.MovieStarts"
	static let thumbnailFolder				= "/Thumbnails"
	static let bigPosterFolder				= "/BigPoster"
	
	static let prefsLatestDbModification 		= "modificationDate"
	static let prefsLatestDbSuccessfullUpdate 	= "lastestCheck"
	static let prefsFavorites					= "favorites"
	static let prefsUseImdbApp					= "useImdbApp"
	static let prefsUseYoutubeApp				= "userYoutubeApp"
	static let prefsPosterHintAlreadyShown		= "posterHintAlreadyShown"
	static let prefsCountry						= "country"
	
	static let dbRecordTypeMovie			= "Movie"
	static let dbRecordTypeGenre			= "Genre"
	
	static let hoursBetweenDbUpdates		= 24
	static let maxDaysInThePast				= 30.0

	static let tagFavoriteView: Int			= 10000
	static let tagTableCell: Int			= 10001
	
	// MARK: - Watch communication
	
	static let watchMovieFileName			= "movies.plist"

	static let watchMetadataThumbnail		= "thumbnail"
	static let watchMetadataMovieList		= "movieList"

	static let watchAppContextGetAllMovies			= "getAllMovies"
	static let watchAppContextValueEveryting		= "everything"
	static let watchAppContextValueListOnly			= "listOnly"
	static let watchAppContextValueThumbnailsOnly	= "thumbsOnly"
	
	// MARK: - Keys for records from the cloud
	
	// names of database fields (table "Genre")
	static let dbIdGenreId				= "genreId"
	static let dbIdGenreNames			= "genreNames"

	// names of database fields (table "Movie")
	static let dbIdTmdbId				= "tmdbId"
	static let dbIdOrigTitle			= "titleZ"
	static let dbIdPopularity			= "popularity"
	static let dbIdVoteAverage			= "voteAverage"
	static let dbIdVoteCount			= "voteCount"
	static let dbIdProductionCountries	= "productionCountries"
	static let dbIdImdbId				= "imdbId"
	static let dbIdDirectors			= "directors"
	static let dbIdActors				= "actors"
	static let dbIdHidden				= "hidden"
	static let dbIdGenreIds				= "genreIds"
	static let dbIdCharacters			= "characters"
	static let dbIdId					= "id"
	
	// country-specific database fields (table "Movie")
	static let dbIdReleaseUS			= "releaseUS"
	static let dbIdCertificationUS		= "certificationUS"
	static let dbIdReleaseDE			= "releaseDE"
	static let dbIdCertificationDE		= "certificationDE"
	static let dbIdReleaseGB			= "releaseGB"
	static let dbIdCertificationGB		= "certificationGB"
	
	// language-specific database fields (table "Movie")
	static let dbIdTrailerNamesEN		= "trailerNamesEN"
	static let dbIdTrailerIdsEN			= "trailerIdsEN"
	static let dbIdTitleEN				= "titleEN"
	static let dbIdSortTitleEN			= "sortTitleEN"
	static let dbIdSynopsisEN			= "synopsisEN"
	static let dbIdRuntimeEN			= "runtimeEN"
	
	static let dbIdTrailerNamesDE		= "trailerNamesDE"
	static let dbIdTrailerIdsDE			= "trailerIdsDE"
	static let dbIdTitleDE				= "titleDE"
	static let dbIdSortTitleDE			= "sortTitleDE"
	static let dbIdSynopsisDE			= "synopsisDE"
	static let dbIdRuntimeDE			= "runtimeDE"

	// language-specific database fields for poster URLs
	static let dbIdPosterUrlEN			= "posterUrlEN"
	static let dbIdPosterUrlDE			= "posterUrlDE"
	static let allDbIdPosterUrls = [dbIdPosterUrlEN, dbIdPosterUrlDE]

}

