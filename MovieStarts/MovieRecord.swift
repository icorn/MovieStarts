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


public class MovieRecord : Printable {
	
	/// the unique ID from CKAsset
	public var id:String
	/// the ID from tmdb.org
	public var tmdbId:Int?
	/// the original movie title
	public var origTitle:String?
	/// the movie runtime in minutes
	public var runtime:Int = 0
	/// the vote average between 0 and 10
	public var voteAverage:Double = 0.0
	/// the movie title
	public var title:String?
	/// the movie title for sorting
	public var sortTitle:String?
	/// the synopsis of the movie
	public var synopsis:String?
	/// the release date of the movie
	public var releaseDate:NSDate?
	/// an array with movie genres as strings
	public var genres:[String] = []
	/// an array with movie genres as IDs
	public var genreIds:[Int] = []
	/// an array of production countries as strings
	public var productionCountries:[String] = []
	/// the certification of the movie
	public var certification:String?
	/// the url of the poster
	public var posterUrl:String?
	/// the ID from imdb.com
	public var imdbId:String?
	/// an array of directors
	public var directors:[String] = []
	/// an array of actors
	public var actors:[String] = []
	/// an array of trailer names (for display)
	public var trailerNames:[String] = []
	/// an array of trailer IDs (IDs for youtube)
	public var trailerIds:[String] = []

	//	var popularity:Int = 0
	//	var voteCount:Int = 0

	public init(dict: [String: AnyObject]) {
		
		if (dict[Constants.DB_ID_TMDB_ID] != nil) 		{ self.tmdbId 			= dict[Constants.DB_ID_TMDB_ID] 		as? Int }
		if (dict[Constants.DB_ID_ORIG_TITLE] != nil)	{ self.origTitle 		= dict[Constants.DB_ID_ORIG_TITLE] 		as? String }
		if (dict[Constants.DB_ID_TITLE] != nil) 		{ self.title 			= dict[Constants.DB_ID_TITLE] 			as? String }
		if (dict[Constants.DB_ID_SORT_TITLE] != nil) 	{ self.sortTitle 		= dict[Constants.DB_ID_SORT_TITLE]		as? String }
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
		
		if let saveId = dict[Constants.DB_ID_ID] as? String {
			id = saveId
		}
		else {
			// this should never happen
			println("Id for movie \(title) is empty!")
			id = ""
		}
	}

	
	init(ckRecord: CKRecord) {
		
		if (ckRecord.objectForKey(Constants.DB_ID_TMDB_ID) != nil) 		{ self.tmdbId 			= ckRecord.objectForKey(Constants.DB_ID_TMDB_ID) 		as? Int }
		if (ckRecord.objectForKey(Constants.DB_ID_ORIG_TITLE) != nil)	{ self.origTitle 		= ckRecord.objectForKey(Constants.DB_ID_ORIG_TITLE) 	as? String }
		if (ckRecord.objectForKey(Constants.DB_ID_TITLE) != nil) 		{ self.title 			= ckRecord.objectForKey(Constants.DB_ID_TITLE) 			as? String }
		if (ckRecord.objectForKey(Constants.DB_ID_SORT_TITLE) != nil) 	{ self.sortTitle 		= ckRecord.objectForKey(Constants.DB_ID_SORT_TITLE) 	as? String }
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
		
		id = ckRecord.recordID.recordName
	}

	/**
		Converts this object to a dictionary for serialization.

		:returns: A dictionary with all non-null members of this object.
	*/
	
	public func toDictionary() -> [String: AnyObject] {
		
		var retval: [String:AnyObject] = [:]
		
		if let tmdbId 		 = tmdbId 		 { retval[Constants.DB_ID_TMDB_ID] 		 = tmdbId }
		if let origTitle 	 = origTitle 	 { retval[Constants.DB_ID_ORIG_TITLE] 	 = origTitle }
		if let title 		 = title 		 { retval[Constants.DB_ID_TITLE] 		 = title }
		if let sortTitle 	 = sortTitle 	 { retval[Constants.DB_ID_SORT_TITLE] 	 = sortTitle }
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
		
		retval[Constants.DB_ID_ID] = id
		
		return retval
	}
	
	/// The thumbnail image object as a tuple: the image object and the "found" flag indicating if a poster image was returned or if it only is the default image.
	
	var thumbnailImage: (UIImage?, Bool) {
		var pathUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(Constants.MOVIESTARTS_GROUP)
		
		if let pathUrl = pathUrl, basePath = pathUrl.path {
			if let posterUrl = posterUrl {
				return (UIImage(contentsOfFile: basePath + Constants.THUMBNAIL_FOLDER + posterUrl), true)
			}
		}
		
		return (UIImage(named: "noposter.png"), false)
	}
	
	/// The string of genres of the movie.
	
	public var genreString: String? {
		var genreText: String = ""
		
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
	
	/// The string of production countries.
	
	var countryString: String? {
		var countryText: String = ""
		
		if (productionCountries.count > 0) {
			for country in productionCountries {
				countryText += shortenCountryname(country) + ", "
			}
			
			return countryText.substringToIndex(countryText.endIndex.predecessor().predecessor())
		}
		else {
			return nil
		}
	}
	
	/// The subtitle for the detail view of the movie.

	public var detailSubtitle: String? {
		var detailText = ""
		
		// add runtime
		
		if (runtime > 0) {
			var minutesShort = NSLocalizedString("MinutesShort", comment: "")
			detailText += "\(runtime) \(minutesShort) | "
		}
		
		// add countries

		if let countries = countryString {
			detailText += countries
		}
		else {
			if (count(detailText) > 2) {
				detailText = detailText.substringToIndex(detailText.endIndex.predecessor().predecessor())
			}
		}
		
		if (count(detailText) == 0) {
			return nil
		}
		else {
			return detailText
		}
	}
	
	/// The original movie title including language-specific prefix (like "aka").
	
	var originalTitleForDisplay: String? {
		var retval: String? = nil
		
		if let origTitle = origTitle, title = title where origTitle != title {
			var akaString = NSLocalizedString("aka", comment: "")
			retval = "\(akaString) \"\(origTitle)\""
		}
		
		return retval
	}
	
	/// An array with up to three items for the subtitle.
	
	public var subtitleArray: [String] {
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
	
	/// The release data as string in medium sized format.
	
	var releaseDateString: String {
		var retval = NSLocalizedString("NoReleaseDate", comment: "")
		
		if let releaseDate = releaseDate {
			var dateFormatter = NSDateFormatter()
			dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
			dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
			retval = dateFormatter.stringFromDate(releaseDate)
		}
		
		return retval
	}
	
	/// The release data as string in long format.
	
	var releaseDateStringLong: String {
		var retval = NSLocalizedString("NoReleaseDate", comment: "")
		
		if let releaseDate = releaseDate {
			var dateFormatter = NSDateFormatter()
			dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
			dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
			retval = dateFormatter.stringFromDate(releaseDate)
		}
		
		return retval
	}
	
	
	/**
		Moves a downloaded thumbnail poster from the temporar folder to the final one.
	
		:param: thumbnailAsset	The asset of the poster coming from CloudKit
	*/
	func storeThumbnailPoster(thumbnailAsset: CKAsset?) {
		if let thumbnailAsset = thumbnailAsset, posterUrl = posterUrl {
			var targetPathUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(Constants.MOVIESTARTS_GROUP)
			
			if let targetPathUrl = targetPathUrl, targetBasePath = targetPathUrl.path, sourcePathString = thumbnailAsset.fileURL.path {
				var targetPathString = targetBasePath + Constants.THUMBNAIL_FOLDER + posterUrl

				// now we have both paths: copy the file
				
				var error: NSErrorPointer = nil
				
				if (NSFileManager.defaultManager().moveItemAtPath(sourcePathString, toPath: targetPathString, error: error) == false) {
					// this also happens if the file already exists
					
					if (error != nil) {
						println(error.debugDescription)
					}
				}
			}
		}
	}
	
	
	/**
		Shortens the given country name.
	
		:param:	name	The country name to be shortened
	
		:returns: The shortened country name (often the same as the input name).
	*/
	private func shortenCountryname(name: String) -> String {
		
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
		Checks if the movie is now playing in theaters.

		:returns: TRUE if it is now playing, FALSE otherwise
	*/
	func isNowPlaying() -> Bool {
		var retval = false
		
		if let saveDate = releaseDate {
			
			var today = NSDate()
			
			if (saveDate.compare(today) == NSComparisonResult.OrderedDescending) {
				// upcoming movie
				retval = false
			}
			else {
				// now playing
				retval = true
			}
		}
		
		return retval
	}

	
	/**
		Checks if the updated version of the movie record has changes
		which are visible in the table cell.
    */
	func hasVisibleChanges(updatedMovie: MovieRecord) -> Bool {
		
		if ((title != updatedMovie.title) || (origTitle != updatedMovie.origTitle) || (runtime != updatedMovie.runtime) ||
			(productionCountries != updatedMovie.productionCountries) || (genres != updatedMovie.genres))
		{
			if ((posterUrl == nil) && (updatedMovie.posterUrl != nil)) {
				return true
			}
		}
		
		return false
	}
	
	// MARK: - Printable
	
	public var description: String {
		
		var retval = ""
		
		retval += "id: \(id) | "
		retval += "runtime: \(runtime) | "
		retval += "voteAvg: \(voteAverage) | "

		if let tmdbId = tmdbId {
			retval += "tmdbId: \(tmdbId) | "
		} else {
			retval += "tmdbId: nil | "
		}
		
		if let imdbId = imdbId {
			retval += "imdbId: \(imdbId) | "
		} else {
			retval += "imdbId: nil | "
		}

		if let title = title {
			retval += "title: \(title) | "
		} else {
			retval += "title: nil | "
		}

		if let sortTitle = sortTitle {
			retval += "sortTitle: \(sortTitle) | "
		} else {
			retval += "sortTitle: nil | "
		}
		
		if let origTitle = origTitle {
			retval += "origTitle: \(origTitle) | "
		} else {
			retval += "origTitle: nil | "
		}

		if let releaseDate = releaseDate {
			retval += "releaseDate: \(releaseDate) | "
		} else {
			retval += "releaseDate: nil | "
		}

		if let posterUrl = posterUrl {
			retval += "posterUrl: \(posterUrl) | "
		} else {
			retval += "posterUrl: nil | "
		}

		return retval
		
		/* ignored:
		public var certification:String?
		public var synopsis:String?
		public var productionCountries:[String] = []
		public var genres:[String] = []
		public var genreIds:[Int] = []
		public var directors:[String] = []
		public var actors:[String] = []
		public var trailerNames:[String] = []
		public var trailerIds:[String] = []
		*/
	}
}

