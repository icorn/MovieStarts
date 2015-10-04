//
//  MovieRecord.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 15.02.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation
import UIKit


public class WatchMovieRecord : CustomStringConvertible {
	
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
	/// the popularity of the movie on tmdb.org
	public var popularity:Int = 0
	/// the number of votes for this movie on tmdb
	public var voteCount:Int = 0
	
	private var _thumbnailImage: UIImage?
	private var _thumbnailFound: Bool = false
	
	
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
		
		if (dict[Constants.DB_ID_POPULARITY] != nil) 	{ self.popularity 		= dict[Constants.DB_ID_POPULARITY] 		as! Int }
		if (dict[Constants.DB_ID_VOTE_COUNT] != nil) 	{ self.voteCount 		= dict[Constants.DB_ID_VOTE_COUNT] 		as! Int }
		
		if let saveId = dict[Constants.DB_ID_ID] as? String {
			id = saveId
		}
		else {
			// this should never happen
			NSLog("Id for movie \(title) is empty!")
			id = ""
		}
	}
	
	
	/**
	Converts this object to a dictionary for serialization.
	
	- returns: A dictionary with all non-null members of this object.
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
		retval[Constants.DB_ID_POPULARITY] 				= popularity
		retval[Constants.DB_ID_VOTE_COUNT] 				= voteCount
		
		retval[Constants.DB_ID_ID] = id
		
		return retval
	}
	
	/// The thumbnail image object as a tuple: the image object and the "found" flag indicating if a poster image was returned or if it only is the default image.
	
	var thumbnailImage: (UIImage?, Bool) {
		if _thumbnailImage != nil {
			return (_thumbnailImage, _thumbnailFound)
		}
		
		let pathUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(Constants.MOVIESTARTS_GROUP)
		
		if let pathUrl = pathUrl, basePath = pathUrl.path {
			if let posterUrl = posterUrl {
				_thumbnailImage = UIImage(contentsOfFile: basePath + Constants.THUMBNAIL_FOLDER + posterUrl)
				_thumbnailFound = true
				return (_thumbnailImage, _thumbnailFound)
			}
		}
		
		_thumbnailImage = UIImage(named: "noposter.png")
		_thumbnailFound = false
		return (_thumbnailImage, _thumbnailFound)
	}
	
	/// The big poster image object as optional image object
	
	var bigPoster: UIImage? {
		let pathUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(Constants.MOVIESTARTS_GROUP)
		var retval: UIImage?
		
		if let pathUrl = pathUrl, basePath = pathUrl.path {
			if let posterUrl = posterUrl {
				retval = UIImage(contentsOfFile: basePath + Constants.BIG_POSTER_FOLDER + posterUrl)
			}
		}
		
		return retval
	}
	
	/// The string of genres of the movie.
	
	public var genreString: String? {
		var genreText: String = ""
		
		if (genres.count > 0) {
			for genre in genres {
				genreText += NSLocalizedString(genre, comment: "") + ", "
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
				countryText += NSLocalizedString(country, comment: "") + ", "
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
			let minutesShort = NSLocalizedString("MinutesShort", comment: "")
			detailText += "\(runtime) \(minutesShort) | "
		}
		
		// add mpaa rating
		
		if let certification = certification where certification.characters.count > 0 {
			detailText += "\(certification) | "
		}
		
		// add countries
		
		if let countries = countryString {
			detailText += countries
		}
		else {
			if (detailText.characters.count > 2) {
				detailText = detailText.substringToIndex(detailText.endIndex.predecessor().predecessor())
			}
		}
		
		if (detailText.characters.count == 0) {
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
			let akaString = NSLocalizedString("aka", comment: "")
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
			let dateFormatter = NSDateFormatter()
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
			let dateFormatter = NSDateFormatter()
			dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
			dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
			retval = dateFormatter.stringFromDate(releaseDate)
		}
		
		return retval
	}
	
	
	/**
	Checks if the movie is now playing in theaters.
	
	- returns: TRUE if it is now playing, FALSE otherwise
	*/
	func isNowPlaying() -> Bool {
		var retval = false
		
		if let saveDate = releaseDate {
			let today = NSDate()
			retval = (saveDate.compare(today) != NSComparisonResult.OrderedDescending)
		}
		
		return retval
	}
	
	
	/**
	Checks if the updated version of the movie record has changes
	which are visible in the table cell.
	*/
	func hasVisibleChanges(updatedMovie: WatchMovieRecord) -> Bool {
		
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
		retval += "voteCount: \(voteCount) | "
		retval += "popularity: \(popularity) | "
		
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

