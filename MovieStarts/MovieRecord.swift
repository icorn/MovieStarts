//
//  MovieRecord.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 15.02.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation
import CloudKit
import UIKit


class MovieRecord {
	
	var tmdbId:Int?
	var origTitle:String?
	var runtime:Int = 0
	var voteAverage:Double = 0.0
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

	//	var popularity:Int = 0
	//	var voteCount:Int = 0

	
	init(dict: [String: AnyObject]) {
		
		if (dict[Constants.DB_ID_TMDB_ID] != nil) 		{ self.tmdbId 			= dict[Constants.DB_ID_TMDB_ID] 		as? Int }
		if (dict[Constants.DB_ID_ORIG_TITLE] != nil)	{ self.origTitle 		= dict[Constants.DB_ID_ORIG_TITLE] 		as? String }
		if (dict[Constants.DB_ID_TITLE] != nil) 		{ self.title 			= dict[Constants.DB_ID_TITLE] 			as? String }
		if (dict[Constants.DB_ID_SYNOPSIS] != nil) 		{ self.synopsis 		= dict[Constants.DB_ID_SYNOPSIS] 		as? String }
		if (dict[Constants.DB_ID_RELEASE] != nil) 		{ self.releaseDate 		= dict[Constants.DB_ID_RELEASE] 		as? NSDate }
		if (dict[Constants.DB_ID_CERTIFICATION] != nil) { self.certification 	= dict[Constants.DB_ID_CERTIFICATION] 	as? String }
		if (dict[Constants.DB_ID_POSTER_URL] != nil) 	{ self.posterUrl 		= dict[Constants.DB_ID_POSTER_URL] 		as? String }
		if (dict[Constants.DB_ID_IMDB_ID] != nil) 		{ self.imdbId 			= dict[Constants.DB_ID_IMDB_ID] 		as? String }
		
		if (dict[Constants.DB_ID_RUNTIME] != nil) 		{ self.runtime 			= dict[Constants.DB_ID_RUNTIME] 		as! Int }
		if (dict[Constants.DB_ID_VOTE_AVERAGE] != nil) 	{ self.voteAverage 		= dict[Constants.DB_ID_VOTE_AVERAGE] 	as! Double }
		if (dict[Constants.DB_ID_GENRES] != nil) 		{ self.genres 			= dict[Constants.DB_ID_GENRES] 			as! [String] }
		if (dict[Constants.DB_ID_DIRECTORS] != nil) 	{ self.directors 		= dict[Constants.DB_ID_DIRECTORS] 		as! [String] }
		if (dict[Constants.DB_ID_ACTORS] != nil) 		{ self.actors 			= dict[Constants.DB_ID_ACTORS] 			as! [String] }
		if (dict[Constants.DB_ID_TRAILER_NAMES] != nil) { self.trailerNames 	= dict[Constants.DB_ID_TRAILER_NAMES] 	as! [String] }
		if (dict[Constants.DB_ID_TRAILER_IDS] != nil) 	{ self.trailerIds 		= dict[Constants.DB_ID_TRAILER_IDS] 	as! [String] }

		if (dict[Constants.DB_ID_PRODUCTION_COUNTRIES] != nil) { self.productionCountries = dict[Constants.DB_ID_PRODUCTION_COUNTRIES] as! [String] }
		
//		if (dict[Constants.DB_ID_POPULARITY] != nil) 	{ self.popularity 		= dict[Constants.DB_ID_POPULARITY] 		as! Int }
//		if (dict[Constants.DB_ID_VOTE_COUNT] != nil) 	{ self.voteCount 		= dict[Constants.DB_ID_VOTE_COUNT] 		as! Int }
	}
	
	
	init(ckRecord: CKRecord) {
		
		if (ckRecord.objectForKey(Constants.DB_ID_TMDB_ID) != nil) 		{ self.tmdbId 			= ckRecord.objectForKey(Constants.DB_ID_TMDB_ID) 		as? Int }
		if (ckRecord.objectForKey(Constants.DB_ID_ORIG_TITLE) != nil)	{ self.origTitle 		= ckRecord.objectForKey(Constants.DB_ID_ORIG_TITLE) 	as? String }
		if (ckRecord.objectForKey(Constants.DB_ID_TITLE) != nil) 		{ self.title 			= ckRecord.objectForKey(Constants.DB_ID_TITLE) 			as? String }
		if (ckRecord.objectForKey(Constants.DB_ID_SYNOPSIS) != nil) 	{ self.synopsis 		= ckRecord.objectForKey(Constants.DB_ID_SYNOPSIS) 		as? String }
		if (ckRecord.objectForKey(Constants.DB_ID_RELEASE) != nil) 		{ self.releaseDate 		= ckRecord.objectForKey(Constants.DB_ID_RELEASE) 		as? NSDate }
		if (ckRecord.objectForKey(Constants.DB_ID_CERTIFICATION) != nil){ self.certification 	= ckRecord.objectForKey(Constants.DB_ID_CERTIFICATION) 	as? String }
		if (ckRecord.objectForKey(Constants.DB_ID_POSTER_URL) != nil) 	{ self.posterUrl 		= ckRecord.objectForKey(Constants.DB_ID_POSTER_URL) 	as? String }
		if (ckRecord.objectForKey(Constants.DB_ID_IMDB_ID) != nil) 		{ self.imdbId 			= ckRecord.objectForKey(Constants.DB_ID_IMDB_ID) 		as? String }
		
		if (ckRecord.objectForKey(Constants.DB_ID_RUNTIME) != nil) 		{ self.runtime 			= ckRecord.objectForKey(Constants.DB_ID_RUNTIME) 		as! Int }
		if (ckRecord.objectForKey(Constants.DB_ID_VOTE_AVERAGE) != nil) { self.voteAverage 		= ckRecord.objectForKey(Constants.DB_ID_VOTE_AVERAGE) 	as! Double }
		if (ckRecord.objectForKey(Constants.DB_ID_GENRES) != nil) 		{ self.genres 			= ckRecord.objectForKey(Constants.DB_ID_GENRES) 		as! [String] }
		if (ckRecord.objectForKey(Constants.DB_ID_DIRECTORS) != nil) 	{ self.directors 		= ckRecord.objectForKey(Constants.DB_ID_DIRECTORS) 		as! [String] }
		if (ckRecord.objectForKey(Constants.DB_ID_ACTORS) != nil) 		{ self.actors 			= ckRecord.objectForKey(Constants.DB_ID_ACTORS) 		as! [String] }
		if (ckRecord.objectForKey(Constants.DB_ID_TRAILER_NAMES) != nil){ self.trailerNames 	= ckRecord.objectForKey(Constants.DB_ID_TRAILER_NAMES) 	as! [String] }
		if (ckRecord.objectForKey(Constants.DB_ID_TRAILER_IDS) != nil) 	{ self.trailerIds 		= ckRecord.objectForKey(Constants.DB_ID_TRAILER_IDS) 	as! [String] }
		
		if (ckRecord.objectForKey(Constants.DB_ID_PRODUCTION_COUNTRIES) != nil) { self.productionCountries = ckRecord.objectForKey(Constants.DB_ID_PRODUCTION_COUNTRIES) as! [String] }
		
//		if (ckRecord.objectForKey(Constants.DB_ID_POPULARITY) != nil) 	{ self.popularity 		= ckRecord.objectForKey(Constants.DB_ID_POPULARITY) 	as! Int }
//		if (ckRecord.objectForKey(Constants.DB_ID_VOTE_COUNT) != nil) 	{ self.voteCount 		= ckRecord.objectForKey(Constants.DB_ID_VOTE_COUNT) 	as! Int }
	}

	
	func toDictionary() -> [String: AnyObject] {
		
		var retval: [String:AnyObject] = [:]
		
		if let tmdbId 		 = tmdbId 		 { retval[Constants.DB_ID_TMDB_ID] 		 = tmdbId }
		if let origTitle 	 = origTitle 	 { retval[Constants.DB_ID_ORIG_TITLE] 	 = origTitle }
		if let title 		 = title 		 { retval[Constants.DB_ID_TITLE] 		 = title }
		if let synopsis 	 = synopsis 	 { retval[Constants.DB_ID_SYNOPSIS] 	 = synopsis }
		if let releaseDate 	 = releaseDate 	 { retval[Constants.DB_ID_RELEASE] 		 = releaseDate }
		if let certification = certification { retval[Constants.DB_ID_CERTIFICATION] = certification }
		if let posterUrl 	 = posterUrl 	 { retval[Constants.DB_ID_POSTER_URL] 	 = posterUrl }
		if let imdbId 		 = imdbId 		 { retval[Constants.DB_ID_IMDB_ID] 		 = imdbId }

		retval[Constants.DB_ID_RUNTIME] 				= runtime
		retval[Constants.DB_ID_VOTE_AVERAGE] 			= voteAverage
		retval[Constants.DB_ID_GENRES] 					= genres
		retval[Constants.DB_ID_DIRECTORS] 				= directors
		retval[Constants.DB_ID_ACTORS] 					= actors
		retval[Constants.DB_ID_TRAILER_NAMES] 			= trailerNames
		retval[Constants.DB_ID_TRAILER_IDS] 			= trailerIds
		retval[Constants.DB_ID_PRODUCTION_COUNTRIES] 	= productionCountries
		
//		retval[Constants.DB_ID_POPULARITY] = popularity
//		retval[Constants.DB_ID_VOTE_COUNT] = voteCount
		
		return retval
	}
	
	
	/**
		Gets the thumbnail image object.
	
		:returns: a tuple with the image, and the "found" flag indicating if a poster image was returned or if it only is the default image.
	*/
	var thumbnailImage: (UIImage?, Bool) {
		get {
			
			var pathUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(Constants.MOVIESTARTS_GROUP)
			
			if let pathUrl = pathUrl, basePath = pathUrl.path {
				if let posterUrl = posterUrl {
					return (UIImage(contentsOfFile: basePath + Constants.THUMBNAIL_FOLDER + posterUrl), true)
				}
			}
			
			return (UIImage(named: "noposter.png"), false)
		}
	}
	
	/**
		Generates the string of call genres of the movie.
	
		:returns: the generated string consisting of the movies genres
	*/
	var genreString: String? {
		get {
			var genreText = ""
			
			if (genres.count > 0) {
				for genre in genres {
					genreText += genre + ", "
				}
				
				return genreText.substringToIndex(genreText.endIndex.predecessor().predecessor())
			}
			else {
				return nil
			}
		}
	}
	
	
	/**
		Generates the subtitle for the detail view of the movie.
	
		:returns: the generated subtitle, consting of the runtime and the production countries
	*/
	var detailSubtitle: String? {
		var detailText = ""
		
		// add runtime
		
		if (runtime > 0) {
			var minutesShort = NSLocalizedString("MinutesShort", comment: "")
			detailText += "\(runtime) \(minutesShort) | "
		}
		
		// add countries
		
		if (productionCountries.count > 0) {
			for country in productionCountries {
				detailText += MovieStartsUtil.shortenCountryname(country) + ", "
			}
		}
		
		if (count(detailText) > 0) {
			// remove last two characters
			detailText = detailText.substringToIndex(detailText.endIndex.predecessor().predecessor())
		}
		
		if (count(detailText) == 0) {
			return nil
		}
		else {
			return detailText
		}
	}
	
	
	var originalTitleForDisplay: String? {
		var retval: String? = nil
		
		if let origTitle = origTitle, title = title where origTitle != title {
			var akaString = NSLocalizedString("aka", comment: "")
			retval = "\(akaString) \"\(origTitle)\""
		}
		
		return retval
	}
	
	
	var subtitleArray: [String] {
		
		var subtitles: [String] = []
		
		if let origText = originalTitleForDisplay {
			subtitles.append(origText)
		}
		
		if let details = detailSubtitle {
			subtitles.append(details)
		}
		
		if let genres = genreString {
			subtitles.append(genres)
		}
		
		return subtitles
	}
	
	
	/**
		Moves a downloaded thumbnail poster from the temporar folder to the final one.
	*/
	func storeThumbnailPoster(thumbnailAsset: CKAsset?) {
		if let thumbnailAsset = thumbnailAsset, posterUrl = posterUrl {
			var targetPathUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(Constants.MOVIESTARTS_GROUP)
			
			if let targetPathUrl = targetPathUrl, targetBasePath = targetPathUrl.path, sourcePathString = thumbnailAsset.fileURL.path {
				var targetPathString = targetBasePath + Constants.THUMBNAIL_FOLDER + posterUrl

				// now we have both paths: copy the file
				
				var error: NSErrorPointer = nil
				
				if (NSFileManager.defaultManager().moveItemAtPath(sourcePathString, toPath: targetPathString, error: error) == false) {
					println("Error moving thumbnail image from \(sourcePathString) to \(targetPathString)")
					
					if (error != nil) {
						println(error.debugDescription)
					}
				}
			}
		}
	}
	
}

