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
	static let trailerFolder				= "/Trailers"
	static let actorThumbnailFolder			= "/ActorsThumbnails"
	static let actorBigFolder				= "/ActorsBig"
	static let directorThumbnailFolder		= "/DirectorsThumbnails"
	static let directorBigFolder			= "/DirectorsBig"
	static let notificationUserInfoId		= "MovieStartsNotificationId"
	static let notificationUserInfoName		= "MovieStartsNotificationName"
	static let notificationUserInfoDate		= "MovieStartsNotificationDate"
	static let notificationUserInfoDay		= "MovieStartsNotificationDay"
	
	static let prefsLatestDbModification 		= "modificationDate"
	static let prefsLatestDbSuccessfullUpdate 	= "lastestCheck"
	static let prefsFavorites					= "favorites"
	static let prefsUseImdbApp					= "useImdbApp"
	static let prefsUseYoutubeApp				= "userYoutubeApp"
	static let prefsPosterHintAlreadyShown		= "posterHintAlreadyShown"
	static let prefsCountry						= "country"
	static let prefsNotifications				= "notifications"
	static let prefsNotificationDay				= "notificationDay"
	static let prefsNotificationTime			= "notificationTime"
	static let prefsVersion						= "version"
	static let prefsMigrateFromVersion			= "migrateFromVersion"
	
	static let dbRecordTypeMovie			= "Movie"
	static let dbRecordTypeGenre			= "Genre"
	
	static let tabIndexNowPlaying			= 0
	static let tabIndexUpcoming				= 1
	static let tabIndexFavorites			= 2
	static let tabIndexSettings				= 3
	
	static let notificationTimeMin			= 8
	static let notificationTimeMax			= 23
	static let notificationDays				= 6 // number of different possible days for notification
	
	static let hoursBetweenDbUpdates		= 24
	static let maxDaysInThePast				= 30.0

	static let tagFavoriteView				= 10000
	static let tagTableCell					= 10001
	static let tagTrailerEnglish            = 20000
    static let tagTrailerGerman             = 20100

	static let version1_0					= 10
	static let version1_1					= 11
	static let version1_2					= 12
	static let version1_3					= 13
	static let versionCurrent				= version1_3
	
	// MARK: - Watch communication
	
	static let watchMovieFileName			= "movies.plist"

	static let watchMetadataThumbnail		= "thumbnail"
	static let watchMetadataMovieList		= "movieList"

	static let watchAppContextGetDataFromPhone		= "getDataFromPhone"
	static let watchAppContextGetThumbnail			= "getThumbnail"
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
	static let dbIdBudget				= "budget"
	static let dbIdBackdrop				= "backdrop"
	static let dbIdProfilePictures		= "profilePictures"
	static let dbIdDirectorPictures		= "directorPictures"

	// country-specific database fields (table "Movie")
	static let dbIdReleaseUS			= "releaseUS"
	static let dbIdCertificationUS		= "certificationUS"
	static let dbIdReleaseDE			= "releaseDE"
	static let dbIdCertificationDE		= "certificationDE"
	static let dbIdReleaseGB			= "releaseGB"
	static let dbIdCertificationGB		= "certificationGB"

	static let dbIdRelease				= "release"
	static let dbIdCertification		= "certification"
	
	// language-specific database fields (table "Movie")
	static let dbIdTrailerIdsEN			= "trailerIdsEN"
	static let dbIdTitleEN				= "titleEN"
	static let dbIdSortTitleEN			= "sortTitleEN"
	static let dbIdSynopsisEN			= "synopsisEN"
	static let dbIdRuntimeEN			= "runtimeEN"
	
	static let dbIdTrailerIdsDE			= "trailerIdsDE"
	static let dbIdTitleDE				= "titleDE"
	static let dbIdSortTitleDE			= "sortTitleDE"
	static let dbIdSynopsisDE			= "synopsisDE"
	static let dbIdRuntimeDE			= "runtimeDE"

	static let dbIdTitle				= "title"
	static let dbIdSortTitle			= "sortTitle"
	static let dbIdSynopsis				= "synopsis"
	static let dbIdRuntime				= "runtime"

 	// database fields for third-party rating
	static let dbIdRatingImdb			= "ratingImdb"
	static let dbIdRatingMetacritic		= "ratingMetacritic"
	static let dbIdRatingTomato			= "ratingTomato"
	static let dbIdTomatoImage			= "tomatoImage"
	static let dbIdTomatoURL			= "tomatoURL"

	// language-specific database fields for poster URLs
	static let dbIdPosterUrlEN			= "posterUrlEN"
	static let dbIdPosterUrlDE			= "posterUrlDE"
	static let allDbIdPosterUrls = [dbIdPosterUrlEN, dbIdPosterUrlDE]

	static let dbIdPosterUrl			= "posterUrl"
}

