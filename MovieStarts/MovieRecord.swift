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


public class MovieRecord {
	
	public var currentCountry: MovieCountry
	
	/// the unique ID from CKAsset
	public var id:String = ""
	/// the ID from tmdb.org
	public var tmdbId:Int?
	/// the original movie title
	public var origTitle:String?
	/// the movie runtime in minutes (array with localization)
	public var runtime:[Int] = []
	/// the vote average between 0 and 10
	public var voteAverage:Double = 0.0
	/// the movie title (array with localization)
	public var title:[String] = []
	/// the movie title for sorting
	public var sortTitle:[String] = []
	/// the synopsis of the movie (array with localization)
	public var synopsis:[String] = []
	/// the release date of the movie (array with localization)
	public var releaseDate:[NSDate] = []
	/// an array with movie genres as IDs
	public var genreIds:[Int] = []
	/// an array of production countries as strings
	public var productionCountries:[String] = []
	/// the certification of the movie (array with localization)
	public var certification:[String] = []
	/// the url of the poster (array with localization)
	public var posterUrl:[String] = []
	/// the ID from imdb.com
	public var imdbId:String?
	/// an array of directors
	public var directors:[String] = []
	/// an array of actors
	public var actors:[String] = []
	/// an array of characters
	public var characters:[String] = []
	/// an array of trailer IDs (IDs for youtube) (array with localization)
	public var trailerIds:[[String]] = []
	/// the popularity of the movie on tmdb.org
	public var popularity:Int = 0
	/// the number of votes for this movie on tmdb
	public var voteCount:Int = 0
	
	/// is this movie hidden?
	private var hidden: Bool = false

	
	var _thumbnailImage: UIImage?
	var _thumbnailFound: Bool = false
	
	
	init(country: MovieCountry) {
		// initialize all localized arrays with NILs or empty arrays
		
		currentCountry = country
		
		for _ in 0 ..< MovieCountry.numberOfDifferentLanguages {
			runtime.append(0)
			posterUrl.append("")
			synopsis.append("")
			title.append("")
			sortTitle.append("")
			trailerIds.append([])
		}
		
		for _ in 0 ..< MovieCountry.numberOfDifferentCountries {
			certification.append("")
			releaseDate.append(NSDate(timeIntervalSince1970: 0))
		}
	}
	
	
	convenience init(country: MovieCountry, dict: [String: AnyObject]) {
		self.init(country: country)
		
		if (dict[Constants.dbIdTmdbId] != nil) 		{ self.tmdbId 			= dict[Constants.dbIdTmdbId] 		as? Int }
		if (dict[Constants.dbIdOrigTitle] != nil)	{ self.origTitle 		= dict[Constants.dbIdOrigTitle] 	as? String }
		if (dict[Constants.dbIdImdbId] != nil) 		{ self.imdbId 			= dict[Constants.dbIdImdbId] 		as? String }
		
		if (dict[Constants.dbIdTitleDE] != nil) 		{ self.title[MovieCountry.Germany.languageArrayIndex] 		= dict[Constants.dbIdTitleDE] 		as! String }
		if (dict[Constants.dbIdSortTitleDE] != nil) 	{ self.sortTitle[MovieCountry.Germany.languageArrayIndex] 	= dict[Constants.dbIdSortTitleDE]	as! String }
		if (dict[Constants.dbIdPosterUrlDE] != nil) 	{ self.posterUrl[MovieCountry.Germany.languageArrayIndex] 	= dict[Constants.dbIdPosterUrlDE] 	as! String }
		if (dict[Constants.dbIdSynopsisDE] != nil) 		{ self.synopsis[MovieCountry.Germany.languageArrayIndex] 	= dict[Constants.dbIdSynopsisDE] 	as! String }
		
		if (dict[Constants.dbIdTitleEN] != nil) 		{ self.title[MovieCountry.USA.languageArrayIndex] 		= dict[Constants.dbIdTitleEN] 		as! String }
		if (dict[Constants.dbIdSortTitleEN] != nil) 	{ self.sortTitle[MovieCountry.USA.languageArrayIndex] 	= dict[Constants.dbIdSortTitleEN]	as! String }
		if (dict[Constants.dbIdPosterUrlEN] != nil) 	{ self.posterUrl[MovieCountry.USA.languageArrayIndex] 	= dict[Constants.dbIdPosterUrlEN] 	as! String }
		if (dict[Constants.dbIdSynopsisEN] != nil) 		{ self.synopsis[MovieCountry.USA.languageArrayIndex] 	= dict[Constants.dbIdSynopsisEN] 	as! String }
		
		if (dict[Constants.dbIdReleaseUS] != nil) 		{ self.releaseDate[MovieCountry.USA.countryArrayIndex] 			= dict[Constants.dbIdReleaseUS] 		as! NSDate }
		if (dict[Constants.dbIdCertificationUS] != nil) { self.certification[MovieCountry.USA.countryArrayIndex] 		= dict[Constants.dbIdCertificationUS] 	as! String }
		if (dict[Constants.dbIdReleaseDE] != nil) 		{ self.releaseDate[MovieCountry.Germany.countryArrayIndex] 		= dict[Constants.dbIdReleaseDE] 		as! NSDate }
		if (dict[Constants.dbIdCertificationDE] != nil) { self.certification[MovieCountry.Germany.countryArrayIndex] 	= dict[Constants.dbIdCertificationDE] 	as! String }
		if (dict[Constants.dbIdReleaseGB] != nil) 		{ self.releaseDate[MovieCountry.England.countryArrayIndex] 		= dict[Constants.dbIdReleaseGB] 		as! NSDate }
		if (dict[Constants.dbIdCertificationGB] != nil) { self.certification[MovieCountry.England.countryArrayIndex] 	= dict[Constants.dbIdCertificationGB] 	as! String }
		
		if let value = dict[Constants.dbIdRuntimeDE] as? Int { self.runtime[MovieCountry.Germany.languageArrayIndex]	= value	}
		if let value = dict[Constants.dbIdRuntimeEN] as? Int { self.runtime[MovieCountry.USA.languageArrayIndex]		= value	}
		
		if let value = dict[Constants.dbIdTrailerIdsDE] as? [String] 	{ self.trailerIds[MovieCountry.Germany.languageArrayIndex] 		= value	}
		if let value = dict[Constants.dbIdTrailerIdsEN] as? [String] 	{ self.trailerIds[MovieCountry.USA.languageArrayIndex] 			= value	}
		
		if let value = dict[Constants.dbIdVoteAverage] as? Double 			{ self.voteAverage			= value	}
		if let value = dict[Constants.dbIdGenreIds] as? [Int] 				{ self.genreIds 			= value }
		if let value = dict[Constants.dbIdDirectors] as? [String] 			{ self.directors 			= value	}
		if let value = dict[Constants.dbIdActors] as? [String] 				{ self.actors 				= value	}
		if let value = dict[Constants.dbIdCharacters] as? [String] 			{ self.characters 			= value	}
		if let value = dict[Constants.dbIdPopularity] as? Int				{ self.popularity 			= value	}
		if let value = dict[Constants.dbIdVoteCount] as? Int 				{ self.voteCount 			= value	}
		if let value = dict[Constants.dbIdProductionCountries] as? [String]	{ self.productionCountries	= value	}
		if let value = dict[Constants.dbIdHidden] as? Bool					{ self.hidden				= value	}
		
		if let saveId = dict[Constants.dbIdId] as? String {
			id = saveId
		}
		else {
			// this should never happen
			NSLog("Id for movie \(title) is empty! This cannot happen...")
		}
	}
	
	
	/**
		Initializes the class with a CKRecord as input.

		-parameter ckRecord: The record used as input
	*/
	func initWithCKRecord(ckRecord: CKRecord) {
		
		if (ckRecord.objectForKey(Constants.dbIdTmdbId) != nil) 		{ self.tmdbId 			= ckRecord.objectForKey(Constants.dbIdTmdbId) 		as? Int }
		if (ckRecord.objectForKey(Constants.dbIdImdbId) != nil) 		{ self.imdbId 			= ckRecord.objectForKey(Constants.dbIdImdbId) 		as? String }
		if (ckRecord.objectForKey(Constants.dbIdOrigTitle) != nil)		{ self.origTitle 		= ckRecord.objectForKey(Constants.dbIdOrigTitle) 	as? String }

		if (ckRecord.objectForKey(Constants.dbIdTitleEN) != nil) 		{ self.title[MovieCountry.USA.languageArrayIndex] 		= ckRecord.objectForKey(Constants.dbIdTitleEN) as! String }
		if (ckRecord.objectForKey(Constants.dbIdSortTitleEN) != nil) 	{ self.sortTitle[MovieCountry.USA.languageArrayIndex]	= ckRecord.objectForKey(Constants.dbIdSortTitleEN) 	as! String }
		if (ckRecord.objectForKey(Constants.dbIdSynopsisEN) != nil) 	{ self.synopsis[MovieCountry.USA.languageArrayIndex] 	= ckRecord.objectForKey(Constants.dbIdSynopsisEN) 	as! String }
		if (ckRecord.objectForKey(Constants.dbIdPosterUrlEN) != nil) 	{ self.posterUrl[MovieCountry.USA.languageArrayIndex] 	= ckRecord.objectForKey(Constants.dbIdPosterUrlEN) 	as! String }

		if (ckRecord.objectForKey(Constants.dbIdTitleDE) != nil) 		{ self.title[MovieCountry.Germany.languageArrayIndex] 		= ckRecord.objectForKey(Constants.dbIdTitleDE) 		as! String }
		if (ckRecord.objectForKey(Constants.dbIdSortTitleDE) != nil) 	{ self.sortTitle[MovieCountry.Germany.languageArrayIndex] 	= ckRecord.objectForKey(Constants.dbIdSortTitleDE) 	as! String }
		if (ckRecord.objectForKey(Constants.dbIdSynopsisDE) != nil) 	{ self.synopsis[MovieCountry.Germany.languageArrayIndex] 	= ckRecord.objectForKey(Constants.dbIdSynopsisDE) 	as! String }
		if (ckRecord.objectForKey(Constants.dbIdPosterUrlDE) != nil) 	{ self.posterUrl[MovieCountry.Germany.languageArrayIndex]	= ckRecord.objectForKey(Constants.dbIdPosterUrlDE) 	as! String }
		
		if (ckRecord.objectForKey(Constants.dbIdReleaseUS) != nil) 		{ self.releaseDate[MovieCountry.USA.countryArrayIndex] 		 = ckRecord.objectForKey(Constants.dbIdReleaseUS) 		as! NSDate }
		if (ckRecord.objectForKey(Constants.dbIdCertificationUS) != nil){ self.certification[MovieCountry.USA.countryArrayIndex] 	 = ckRecord.objectForKey(Constants.dbIdCertificationUS) 	as! String }
		if (ckRecord.objectForKey(Constants.dbIdReleaseDE) != nil) 		{ self.releaseDate[MovieCountry.Germany.countryArrayIndex] 	 = ckRecord.objectForKey(Constants.dbIdReleaseDE) 		as! NSDate }
		if (ckRecord.objectForKey(Constants.dbIdCertificationDE) != nil){ self.certification[MovieCountry.Germany.countryArrayIndex] = ckRecord.objectForKey(Constants.dbIdCertificationDE) 	as! String }
		if (ckRecord.objectForKey(Constants.dbIdReleaseGB) != nil) 		{ self.releaseDate[MovieCountry.England.countryArrayIndex] 	 = ckRecord.objectForKey(Constants.dbIdReleaseGB) 		as! NSDate }
		if (ckRecord.objectForKey(Constants.dbIdCertificationGB) != nil){ self.certification[MovieCountry.England.countryArrayIndex] = ckRecord.objectForKey(Constants.dbIdCertificationGB) 	as! String }

		if let value = ckRecord.objectForKey(Constants.dbIdRuntimeEN) as? Int				{ self.runtime[MovieCountry.USA.languageArrayIndex] 		= value }
		if let value = ckRecord.objectForKey(Constants.dbIdTrailerIdsEN) as? [String] 		{ self.trailerIds[MovieCountry.USA.languageArrayIndex] 		= value }
		if let value = ckRecord.objectForKey(Constants.dbIdRuntimeDE) as? Int				{ self.runtime[MovieCountry.Germany.languageArrayIndex] 		= value }
		if let value = ckRecord.objectForKey(Constants.dbIdTrailerIdsDE) as? [String] 		{ self.trailerIds[MovieCountry.Germany.languageArrayIndex] 		= value }

		if let value = ckRecord.objectForKey(Constants.dbIdVoteAverage) as? Double				{ self.voteAverage 			= value }
		if let value = ckRecord.objectForKey(Constants.dbIdGenreIds) as? [Int]	 				{ self.genreIds 			= value }
		if let value = ckRecord.objectForKey(Constants.dbIdDirectors) as? [String] 				{ self.directors 			= value }
		if let value = ckRecord.objectForKey(Constants.dbIdActors) as? [String] 				{ self.actors 				= value }
		if let value = ckRecord.objectForKey(Constants.dbIdCharacters) as? [String] 			{ self.characters 			= value }
		if let value = ckRecord.objectForKey(Constants.dbIdProductionCountries) as? [String] 	{ self.productionCountries 	= value }
		if let value = ckRecord.objectForKey(Constants.dbIdPopularity) as? Int					{ self.popularity 			= value }
		if let value = ckRecord.objectForKey(Constants.dbIdVoteCount) as? Int					{ self.voteCount 			= value }
		if let value = ckRecord.objectForKey(Constants.dbIdHidden) as? Bool						{ self.isHidden				= value }

		id = ckRecord.recordID.recordName
	}
	
	
	/**
		Converts this object to a dictionary for serialization.
	
		- returns: A dictionary with all non-null members of this object.
	*/
	
	public func toDictionary() -> [String: AnyObject] {
		
		var retval: [String:AnyObject] = [:]
		
		if let tmdbId 		 = tmdbId 		 { retval[Constants.dbIdTmdbId] 	= tmdbId }
		if let origTitle 	 = origTitle 	 { retval[Constants.dbIdOrigTitle] 	= origTitle }
		if let imdbId 		 = imdbId 		 { retval[Constants.dbIdImdbId] 	= imdbId }
		
		retval[Constants.dbIdReleaseUS] 		= releaseDate[MovieCountry.USA.countryArrayIndex]
		retval[Constants.dbIdCertificationUS] 	= certification[MovieCountry.USA.countryArrayIndex]
		retval[Constants.dbIdReleaseDE] 		= releaseDate[MovieCountry.Germany.countryArrayIndex]
		retval[Constants.dbIdCertificationDE] 	= certification[MovieCountry.Germany.countryArrayIndex]
		retval[Constants.dbIdReleaseGB] 		= releaseDate[MovieCountry.England.countryArrayIndex]
		retval[Constants.dbIdCertificationGB] 	= certification[MovieCountry.England.countryArrayIndex]
		
		retval[Constants.dbIdSortTitleDE]		= sortTitle[MovieCountry.Germany.languageArrayIndex]
		retval[Constants.dbIdRuntimeDE] 		= runtime[MovieCountry.Germany.languageArrayIndex]
		retval[Constants.dbIdTrailerIdsDE] 		= trailerIds[MovieCountry.Germany.languageArrayIndex]
		retval[Constants.dbIdTitleDE] 			= title[MovieCountry.Germany.languageArrayIndex]
		retval[Constants.dbIdSynopsisDE] 	 	= synopsis[MovieCountry.Germany.languageArrayIndex]
		retval[Constants.dbIdPosterUrlDE] 	 	= posterUrl[MovieCountry.Germany.languageArrayIndex]
		
		retval[Constants.dbIdSortTitleEN]		= sortTitle[MovieCountry.USA.languageArrayIndex]
		retval[Constants.dbIdRuntimeEN] 		= runtime[MovieCountry.USA.languageArrayIndex]
		retval[Constants.dbIdTrailerIdsEN] 		= trailerIds[MovieCountry.USA.languageArrayIndex]
		retval[Constants.dbIdTitleEN] 			= title[MovieCountry.USA.languageArrayIndex]
		retval[Constants.dbIdSynopsisEN] 	 	= synopsis[MovieCountry.USA.languageArrayIndex]
		retval[Constants.dbIdPosterUrlEN] 	 	= posterUrl[MovieCountry.USA.languageArrayIndex]
		
		retval[Constants.dbIdVoteAverage] 			= voteAverage
		retval[Constants.dbIdDirectors] 			= directors
		retval[Constants.dbIdActors] 				= actors
		retval[Constants.dbIdCharacters]			= characters
		retval[Constants.dbIdProductionCountries] 	= productionCountries
		retval[Constants.dbIdPopularity] 			= popularity
		retval[Constants.dbIdVoteCount] 			= voteCount
		retval[Constants.dbIdHidden] 				= hidden
		retval[Constants.dbIdGenreIds]				= genreIds
		retval[Constants.dbIdId] 					= id
		
		return retval
	}
	
	/// Is the movie hidden?
	
	var isHidden: Bool {
		get {
			return hidden
		}
		set {
			hidden = newValue
		}
	}
	

	/// The thumbnail image as NSURL
	
	var thumbnailURL: (NSURL?) {
		let pathUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(Constants.movieStartsGroup)
		var url: NSURL?
		
		if posterUrl[currentCountry.languageArrayIndex].characters.count > 0 {
			url = pathUrl?.URLByAppendingPathComponent(Constants.thumbnailFolder + posterUrl[currentCountry.languageArrayIndex])
		}
		
		return url
	}
	

	/// The thumbnail image object as a tuple: the image object and the "found" flag indicating if a poster image was returned or if it only is the default image.
	/*override*/ var thumbnailImage: (UIImage?, Bool) {
		if ((_thumbnailFound == true) && (_thumbnailImage != nil)) {
			return (_thumbnailImage, _thumbnailFound)
		}
		
		let pathUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(Constants.movieStartsGroup)
		
		if let pathUrl = pathUrl, basePath = pathUrl.path {
			// try to load the poster for the current language
			if posterUrl[currentCountry.languageArrayIndex].characters.count > 0 {
				_thumbnailImage = UIImage(contentsOfFile: basePath + Constants.thumbnailFolder + posterUrl[currentCountry.languageArrayIndex])
				
				if (_thumbnailImage != nil) {
					_thumbnailFound = true
					return (_thumbnailImage, _thumbnailFound)
				}
			}

			// poster not found or not loaded: try the english one
			if ((currentCountry.languageArrayIndex != MovieCountry.USA.languageArrayIndex) && (posterUrl[MovieCountry.USA.languageArrayIndex].characters.count > 0)) {
				_thumbnailImage = UIImage(contentsOfFile: basePath + Constants.thumbnailFolder + posterUrl[MovieCountry.USA.languageArrayIndex])
					
				if (_thumbnailImage != nil) {
					_thumbnailFound = true
					return (_thumbnailImage, _thumbnailFound)
				}
			}
		}
		
		_thumbnailImage = UIImage(named: "noposter.png")
		_thumbnailFound = false
		return (_thumbnailImage, _thumbnailFound)
	}

	/// The synopsis for the current languate, or (if there is none) the one in English. Can be empty, but not null.
	/// Return value: A tuple with the synopsis and the language index.
	var synopsisForLanguage: (String, Int) {
		if (synopsis[currentCountry.languageArrayIndex].characters.count > 0) {
			return (synopsis[currentCountry.languageArrayIndex], currentCountry.languageArrayIndex)
		}
		else {
			return (synopsis[MovieCountry.USA.languageArrayIndex], MovieCountry.USA.languageArrayIndex)
		}
	}
	
	/// The runtime for the movie in the current languate, or (if there is none) for the English version. Can be 0, but not null.
	/// Return value: A tuple with the runtime and the language index.
	var runtimeForLanguage: (Int, Int) {
		if (runtime[currentCountry.languageArrayIndex] > 0) {
			return (runtime[currentCountry.languageArrayIndex], currentCountry.languageArrayIndex)
		}
		else {
			return (runtime[MovieCountry.USA.languageArrayIndex], MovieCountry.USA.languageArrayIndex)
		}
	}
	
	/// The big poster image object as optional image object
	
	var bigPoster: UIImage? {
		let pathUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(Constants.movieStartsGroup)
		var retval: UIImage?
		
		if let pathUrl = pathUrl, basePath = pathUrl.path {
			if posterUrl[currentCountry.languageArrayIndex].characters.count > 0 {
				retval = UIImage(contentsOfFile: basePath + Constants.bigPosterFolder + posterUrl[currentCountry.languageArrayIndex])
			}
		}
		
		return retval
	}
	
	/// The string of genres of the movie.
	
	private func makeGenreString(genreDict: [Int : String]) -> String? {
		var genreText: String = ""
		
		if (genreIds.count > 0) {
			for genreId in genreIds {
				guard let genreName = genreDict[genreId] else { continue }
				genreText += genreName + ", "
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
	
	private var detailSubtitle: String? {
		var detailText = ""
		
		// add runtime
		
		if (runtime[currentCountry.languageArrayIndex] > 0) {
			let minutesShort = NSLocalizedString("MinutesShort", comment: "")
			detailText += "\(runtime[currentCountry.languageArrayIndex]) \(minutesShort) | "
		}
		else if (runtime[MovieCountry.USA.languageArrayIndex] > 0) {
			let minutesShort = NSLocalizedString("MinutesShort", comment: "")
			detailText += "\(runtime[MovieCountry.USA.languageArrayIndex]) \(minutesShort) | "
		}
		
		// add rating
		
		if certification[currentCountry.countryArrayIndex].characters.count > 0 {
			if (currentCountry == MovieCountry.Germany) {
				detailText += "FSK "
			}
			
			detailText += "\(certification[currentCountry.countryArrayIndex]) | "
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
		
		if let origTitle = origTitle where origTitle != title[currentCountry.languageArrayIndex] {
			let akaString = NSLocalizedString("aka", comment: "")
			retval = "\(akaString) \"\(origTitle)\""
		}
		
		return retval
	}
	
	/// An array with up to three items for the subtitle.
	
	func getSubtitleArray(genreDict: [Int : String]) -> [String] {
		var subtitles: [String] = []
		
		if let origText = originalTitleForDisplay {
			subtitles.append(origText)
		}
		
		if let details = detailSubtitle {
			subtitles.append(details)
		}
		
		if let genres = makeGenreString(genreDict) {
			subtitles.append(genres)
		}
		
		return subtitles
	}
	
	/// The release data as string in medium sized format.
	
	var releaseDateString: String {
		var retval = NSLocalizedString("NoReleaseDate", comment: "")
		
		if releaseDate[currentCountry.countryArrayIndex].compare(NSDate(timeIntervalSince1970: 0)) == NSComparisonResult.OrderedDescending {
			let dateFormatter = NSDateFormatter()
			dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
			dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
			retval = dateFormatter.stringFromDate(releaseDate[currentCountry.countryArrayIndex])
		}
		
		return retval
	}
	
	/// The release data as string in long format.
	
	var releaseDateStringLong: String {
		var retval = NSLocalizedString("NoReleaseDate", comment: "")
		
		if releaseDate[currentCountry.countryArrayIndex].compare(NSDate(timeIntervalSince1970: 0)) == NSComparisonResult.OrderedDescending {
			let dateFormatter = NSDateFormatter()
			dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
			dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
			retval = dateFormatter.stringFromDate(releaseDate[currentCountry.countryArrayIndex])
		}
		
		return retval
	}
	
	
	/**
		Checks if the movie is now playing in theaters.
	
		- returns: TRUE if it is now playing, FALSE otherwise
	*/
	func isNowPlaying() -> Bool {
		var retval = false
		
		if releaseDate[currentCountry.countryArrayIndex].compare(NSDate(timeIntervalSince1970: 0)) == NSComparisonResult.OrderedDescending {
			let today = NSDate()
			retval = (releaseDate[currentCountry.countryArrayIndex].compare(today) != NSComparisonResult.OrderedDescending)
		}
		
		return retval
	}
	
	
	/**
		Checks if the updated version of the movie record has changes
		which are visible in the table cell.
	*/
	func hasVisibleChanges(updatedMovie: MovieRecord) -> Bool {
		
		// TODO nochmal durchdenken
		
		if ((title[currentCountry.languageArrayIndex] != updatedMovie.title[currentCountry.languageArrayIndex]) ||
			(origTitle != updatedMovie.origTitle) ||
			(runtime[currentCountry.languageArrayIndex] != updatedMovie.runtime[currentCountry.languageArrayIndex]) ||
			(productionCountries != updatedMovie.productionCountries) || (genreIds != updatedMovie.genreIds))
		{
			if ((posterUrl[currentCountry.languageArrayIndex].characters.count == 0) && (updatedMovie.posterUrl[currentCountry.languageArrayIndex].characters.count > 0)) {
				return true
			}
		}
		
		return false
	}
	
	// MARK: - Printable
	
	public var description: String {
		
		var retval = ""
		
		retval += "id: \(id) | "
		retval += "runtime: \(runtime[currentCountry.languageArrayIndex]) | "
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
		
		if title[currentCountry.languageArrayIndex].characters.count > 0 {
			retval += "title: \(title[currentCountry.languageArrayIndex]) | "
		} else {
			retval += "title: nil | "
		}
		
		if sortTitle[currentCountry.languageArrayIndex].characters.count > 0 {
			retval += "sortTitle: \(sortTitle[currentCountry.languageArrayIndex]) | "
		} else {
			retval += "sortTitle: nil | "
		}
		
		if let origTitle = origTitle {
			retval += "origTitle: \(origTitle) | "
		} else {
			retval += "origTitle: nil | "
		}
		
		if releaseDate[currentCountry.countryArrayIndex].compare(NSDate(timeIntervalSince1970: 0)) == NSComparisonResult.OrderedDescending {
			retval += "releaseDate: \(releaseDate[currentCountry.countryArrayIndex]) | "
		} else {
			retval += "releaseDate: nil | "
		}
		
		if posterUrl[currentCountry.languageArrayIndex].characters.count > 0 {
			retval += "posterUrl: \(posterUrl[currentCountry.languageArrayIndex]) | "
		} else {
			retval += "posterUrl: nil | "
		}
		
		return retval
		
		/* ignored:
		public var certification:String?
		public var synopsis:String?
		public var productionCountries:[String] = []
		public var genreIds:[Int] = []
		public var directors:[String] = []
		public var actors:[String] = []
		public var trailerIds:[String] = []
		*/
	}

}

