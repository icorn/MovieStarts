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


open class MovieRecord : CustomStringConvertible {
	
	// MARK: - Properties
	
	open var currentCountry: MovieCountry
	
	/// the unique ID from CKAsset
	open var id:String = ""
	/// the ID from tmdb.org
	open var tmdbId:Int?
	/// the original movie title
	open var origTitle:String?
	/// the movie runtime in minutes (array with localization)
	open var runtime:[Int] = []
	/// the vote average between 0 and 10
	open var voteAverage:Double = 0.0
	/// the movie title (array with localization)
	open var title:[String] = []
	/// the movie title for sorting
	open var sortTitle:[String] = []
	/// the synopsis of the movie (array with localization)
	open var synopsis:[String] = []
	/// the release date of the movie (array with localization)
	open var releaseDate:[Date] = []
	/// an array with movie genres as IDs
	open var genreIds:[Int] = []
	/// an array of production countries as strings
	open var productionCountries:[String] = []
	/// the certification of the movie (array with localization)
	open var certification:[String] = []
	/// the url of the poster (array with localization)
	open var posterUrl:[String] = []
	/// the ID from imdb.com
	open var imdbId:String?
	/// an array of directors
	open var directors:[String] = []
	/// an array of actors
	open var actors:[String] = []
	/// an array of characters
	open var characters:[String] = []
	/// an array of trailer IDs (IDs for youtube) (array with localization)
	open var trailerIds:[[String]] = []
	/// the popularity of the movie on tmdb.org
	open var popularity:Int = 0
	/// the number of votes for this movie on tmdb
	open var voteCount:Int = 0
	///  the IMDb rating (between 0.0 and 10.0)
	open var ratingImdb: Double?
	///  the Metacritic rating (between 0 and 100)
	open var ratingMetacritic: Int?
	///  the Rotten Tomatoes rating (between 0 and 100)
	open var ratingTomato: Int?
	///  the Rotten Tomatoes image (1:cert, 2:fresh, 3:rotten)
	open var tomatoImage: Int?
	///  the Rotten Tomatoes url for this movie
	open var tomatoURL: String?
	
	/// four new values for version 1.3
	var budget: Int?
	var backdrop: String?
	var profilePictures: [String] = []
	var directorPictures: [String] = []
    var homepage:[String] = []
    var tagline:[String] = []
    var crewWriting: [String] = []

	/// is this movie hidden?
	fileprivate var hidden: Bool = false

	var _thumbnailImage: UIImage?
	var _thumbnailFound: Bool = false
	
	
	// MARK: - Computed Properties

	
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
	var thumbnailURL: (URL?) {
		let pathUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.movieStartsGroup)
		var url: URL?
		
		if posterUrl[currentCountry.languageArrayIndex].count > 0 {
			url = pathUrl?.appendingPathComponent(Constants.thumbnailFolder + posterUrl[currentCountry.languageArrayIndex])
		}
		
		return url
	}
	
	/// The thumbnail image object as a tuple: the image object and the "found" flag indicating if a poster image was returned or if it only is the default image.
	var thumbnailImage: (UIImage?, Bool) {
		if ((_thumbnailFound == true) && (_thumbnailImage != nil)) {
			return (_thumbnailImage, _thumbnailFound)
		}
		
		let pathUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.movieStartsGroup)
		
		if let pathUrl = pathUrl  {
			// try to load the poster for the current language
			if posterUrl[currentCountry.languageArrayIndex].count > 0 {
				_thumbnailImage = UIImage(contentsOfFile: pathUrl.path + Constants.thumbnailFolder +
					posterUrl[currentCountry.languageArrayIndex])
				
				if (_thumbnailImage != nil) {
					_thumbnailFound = true
					return (_thumbnailImage, _thumbnailFound)
				}
			}
			
			// poster not found or not loaded: try the english one
			if ((currentCountry.languageArrayIndex != MovieCountry.USA.languageArrayIndex) && (posterUrl[MovieCountry.USA.languageArrayIndex].count > 0)) {
				_thumbnailImage = UIImage(contentsOfFile: pathUrl.path + Constants.thumbnailFolder +
					posterUrl[MovieCountry.USA.languageArrayIndex])
				
				if (_thumbnailImage != nil) {
					_thumbnailFound = true
					return (_thumbnailImage, _thumbnailFound)
				}
			}
		}
		
		_thumbnailImage = UIImage(named: "no-poster")
		_thumbnailFound = false
		return (_thumbnailImage, _thumbnailFound)
	}
	
	/// The synopsis for the current languate, or (if there is none) the one in English. Can be empty, but not null.
	/// Return value: A tuple with the synopsis and the language index.
	var synopsisForLanguage: (String, Int) {
		if (synopsis[currentCountry.languageArrayIndex].count > 0) {
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
		let pathUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.movieStartsGroup)
		var retval: UIImage?
		
		if let pathUrl = pathUrl {
			if posterUrl[currentCountry.languageArrayIndex].count > 0 {
				retval = UIImage(contentsOfFile: pathUrl.path + Constants.bigPosterFolder + posterUrl[currentCountry.languageArrayIndex])
			}
		}
		
		return retval
	}

	/// The string of production countries.
	var countryString: String? {
		var countryText: String = ""
		
		if (productionCountries.count > 0) {
			for country in productionCountries {
				countryText += NSLocalizedString(country, comment: "") + ", "
			}
			
            countryText.removeLast(2)
            return countryText
		}
		else {
			return nil
		}
	}
	
	/// The budget as string
	var budgetString: String? {
		if let budget = budget {
			let numberFormatter = NumberFormatter()
			numberFormatter.numberStyle = NumberFormatter.Style.decimal
			
			if (budget > 1000000) {
				// millions
				numberFormatter.minimumFractionDigits = 1

				let doubleMillions = Double(budget) / 1000000.0
				
				if let millions = numberFormatter.string(from: NSNumber(value: doubleMillions))
                {
					if (millions.hasSuffix("0"))
                    {
                        var millionsString = millions
                        millionsString.removeLast(2)
						return "$" + millionsString + " " + NSLocalizedString("Mio.", comment: "")
					}
					else
                    {
						return "$" + millions + " " + NSLocalizedString("Mio.", comment: "")
					}
				}
			}
			else {
				// under a million
				numberFormatter.minimumFractionDigits = 0
				
				if let thousands = numberFormatter.string(from: NSNumber(value: budget)) {
					return "$" + thousands
				}
			}
		}
		
		return nil
	}
    
    /// The homepage string for display
    func optimizedHomepageStringForLangIndex(_ langIndex: Int) -> String?
    {
        if ((langIndex <= homepage.count) && (homepage[langIndex].count > 0))
        {
            var displayHomepage = homepage[langIndex]
            
            if (displayHomepage.hasSuffix("/"))
            {
                displayHomepage.removeLast()
            }

            if (displayHomepage.hasPrefix("http://"))
            {
                displayHomepage.removeFirst(7)
            }
            else if (displayHomepage.hasPrefix("https://"))
            {
                displayHomepage.removeFirst(8)
            }

            return displayHomepage
        }
        
        return nil
    }
	
	/// The subtitle for the detail view of the movie.
	fileprivate var detailSubtitle: String? {
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
		
		if certification[currentCountry.countryArrayIndex].count > 0 {
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
			if (detailText.count > 2) {
                detailText.removeLast(2)
			}
		}
		
		if (detailText.count == 0) {
			return nil
		}
		else {
			return detailText
		}
	}
	
	/// The original movie title including language-specific prefix (like "aka").
	var originalTitleForDisplay: String? {
		var retval: String? = nil
		
		if let origTitle = origTitle , origTitle != title[currentCountry.languageArrayIndex] {
			let akaString = NSLocalizedString("aka", comment: "")
			retval = "\(akaString) \"\(origTitle)\""
		}
		
		return retval
	}
	
	/// The release data as string in medium sized format.
	var releaseDateString: String {
		var retval = NSLocalizedString("NoReleaseDate", comment: "")
		
		if releaseDate[currentCountry.countryArrayIndex].compare(Date(timeIntervalSince1970: 0)) == ComparisonResult.orderedDescending {
			let dateFormatter = DateFormatter()
			dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
			dateFormatter.timeStyle = DateFormatter.Style.none
			dateFormatter.dateStyle = DateFormatter.Style.medium
			retval = dateFormatter.string(from: releaseDate[currentCountry.countryArrayIndex])
		}
		
		return retval
	}
	
	/// The release data as string in long format.
	var releaseDateStringLong: String {
		var retval = NSLocalizedString("NoReleaseDate", comment: "")
		
		if releaseDate[currentCountry.countryArrayIndex].compare(Date(timeIntervalSince1970: 0)) == ComparisonResult.orderedDescending {
			let dateFormatter = DateFormatter()
			dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
			dateFormatter.timeStyle = DateFormatter.Style.none
			dateFormatter.dateStyle = DateFormatter.Style.full
			retval = dateFormatter.string(from: releaseDate[currentCountry.countryArrayIndex])
		}
		
		return retval
	}
	
	// Calculates the release date of the movie for the local (current) timezone. Instead of midnight GMT this will be midnight in the local (current) timezone.
	var releaseDateInLocalTimezone: Date? {
		
		var localDate: Date?
		var calendarGMT = Calendar(identifier: Calendar.Identifier.gregorian)
		var calendarLocal = Calendar(identifier: Calendar.Identifier.gregorian)
		let timezoneGMT = TimeZone(abbreviation: "GMT")
		
		if let timezoneGMT = timezoneGMT {
			calendarGMT.timeZone = timezoneGMT
			calendarLocal.timeZone = TimeZone.autoupdatingCurrent
			
			let gmtComponents = (calendarGMT as NSCalendar).components([NSCalendar.Unit.day, NSCalendar.Unit.month, NSCalendar.Unit.year], from: releaseDate[currentCountry.countryArrayIndex])
			
			var localComponents = DateComponents()
			localComponents.day = gmtComponents.day
			localComponents.month = gmtComponents.month
			localComponents.year = gmtComponents.year
			localComponents.calendar = calendarLocal
			localDate = localComponents.date
		}
		
		return localDate
	}
	
	
	// MARK: - Initializers
	
	
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
            homepage.append("")
            tagline.append("")
		}
		
		for _ in 0 ..< MovieCountry.numberOfDifferentCountries {
			certification.append("")
			releaseDate.append(Date(timeIntervalSince1970: 0))
		}
	}
	
	convenience init(country: MovieCountry, dict: [String: AnyObject]) {
		self.init(country: country)
		
		if (dict[Constants.dbIdTmdbId] != nil) 		{ self.tmdbId 			= dict[Constants.dbIdTmdbId] 		as? Int }
		if (dict[Constants.dbIdOrigTitle] != nil)	{ self.origTitle 		= dict[Constants.dbIdOrigTitle] 	as? String }
		if (dict[Constants.dbIdImdbId] != nil) 		{ self.imdbId 			= dict[Constants.dbIdImdbId] 		as? String }
		
		if (dict[Constants.dbIdTitleDE] != nil) 	{ self.title[MovieCountry.Germany.languageArrayIndex] 		= dict[Constants.dbIdTitleDE] 		as! String }
		if (dict[Constants.dbIdSortTitleDE] != nil) { self.sortTitle[MovieCountry.Germany.languageArrayIndex] 	= dict[Constants.dbIdSortTitleDE]	as! String }
		if (dict[Constants.dbIdPosterUrlDE] != nil) { self.posterUrl[MovieCountry.Germany.languageArrayIndex] 	= dict[Constants.dbIdPosterUrlDE] 	as! String }
		if (dict[Constants.dbIdSynopsisDE] != nil) 	{ self.synopsis[MovieCountry.Germany.languageArrayIndex] 	= dict[Constants.dbIdSynopsisDE] 	as! String }
        if (dict[Constants.dbIdHomepageDE] != nil)  { self.homepage[MovieCountry.Germany.languageArrayIndex]    = dict[Constants.dbIdHomepageDE]     as! String }
        if (dict[Constants.dbIdTaglineDE] != nil)   { self.tagline[MovieCountry.Germany.languageArrayIndex]     = dict[Constants.dbIdTaglineDE]     as! String }

		if (dict[Constants.dbIdTitleEN] != nil) 	{ self.title[MovieCountry.USA.languageArrayIndex] 		= dict[Constants.dbIdTitleEN] 		as! String }
		if (dict[Constants.dbIdSortTitleEN] != nil) { self.sortTitle[MovieCountry.USA.languageArrayIndex] 	= dict[Constants.dbIdSortTitleEN]	as! String }
		if (dict[Constants.dbIdPosterUrlEN] != nil) { self.posterUrl[MovieCountry.USA.languageArrayIndex] 	= dict[Constants.dbIdPosterUrlEN] 	as! String }
		if (dict[Constants.dbIdSynopsisEN] != nil) 	{ self.synopsis[MovieCountry.USA.languageArrayIndex] 	= dict[Constants.dbIdSynopsisEN] 	as! String }
        if (dict[Constants.dbIdHomepageEN] != nil)  { self.homepage[MovieCountry.USA.languageArrayIndex]    = dict[Constants.dbIdHomepageEN]    as! String }
        if (dict[Constants.dbIdTaglineEN] != nil)   { self.tagline[MovieCountry.USA.languageArrayIndex]     = dict[Constants.dbIdTaglineEN]     as! String }

		if (dict[Constants.dbIdReleaseUS] != nil) 		{ self.releaseDate[MovieCountry.USA.countryArrayIndex] 			= dict[Constants.dbIdReleaseUS] 		as! Date }
		if (dict[Constants.dbIdCertificationUS] != nil) { self.certification[MovieCountry.USA.countryArrayIndex] 		= dict[Constants.dbIdCertificationUS] 	as! String }
		if (dict[Constants.dbIdReleaseDE] != nil) 		{ self.releaseDate[MovieCountry.Germany.countryArrayIndex] 		= dict[Constants.dbIdReleaseDE] 		as! Date }
		if (dict[Constants.dbIdCertificationDE] != nil) { self.certification[MovieCountry.Germany.countryArrayIndex] 	= dict[Constants.dbIdCertificationDE] 	as! String }
		if (dict[Constants.dbIdReleaseGB] != nil) 		{ self.releaseDate[MovieCountry.England.countryArrayIndex] 		= dict[Constants.dbIdReleaseGB] 		as! Date }
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

		if let value = dict[Constants.dbIdProfilePictures] as? [String] 	{ self.profilePictures 		= value	}
		if let value = dict[Constants.dbIdDirectorPictures] as? [String] 	{ self.directorPictures 	= value	}
        if let value = dict[Constants.dbIdCrewWriting] as? [String]         { self.crewWriting          = value    }

		if (dict[Constants.dbIdRatingImdb] != nil) 			{ self.ratingImdb 		= dict[Constants.dbIdRatingImdb] 		as? Double }
		if (dict[Constants.dbIdRatingMetacritic] != nil) 	{ self.ratingMetacritic = dict[Constants.dbIdRatingMetacritic] 	as? Int }
		if (dict[Constants.dbIdRatingTomato] != nil) 		{ self.ratingTomato 	= dict[Constants.dbIdRatingTomato] 		as? Int }
		if (dict[Constants.dbIdTomatoImage] != nil) 		{ self.tomatoImage 		= dict[Constants.dbIdTomatoImage] 		as? Int }
		if (dict[Constants.dbIdTomatoURL] != nil) 			{ self.tomatoURL 		= dict[Constants.dbIdTomatoURL] 		as? String }

		if (dict[Constants.dbIdBudget] != nil)		{ self.budget = dict[Constants.dbIdBudget]		as? Int }
		if (dict[Constants.dbIdBackdrop] != nil) 	{ self.backdrop	= dict[Constants.dbIdBackdrop] 	as? String }

		if let saveId = dict[Constants.dbIdId] as? String {
			id = saveId
		}
		else {
			// this should never happen
			NSLog("Id for movie \(title) is empty! This cannot happen...")
		}
	}
	
	
	// MARK: - Functions
	
	
	/**
		Initializes the class with a CKRecord as input.

		-parameter ckRecord: The record used as input
	*/
	func initWithCKRecord(ckRecord: CKRecord) {
		
		if (ckRecord.object(forKey: Constants.dbIdTmdbId) != nil) 		{ self.tmdbId 			= ckRecord.object(forKey: Constants.dbIdTmdbId) 		as? Int }
		if (ckRecord.object(forKey: Constants.dbIdImdbId) != nil) 		{ self.imdbId 			= ckRecord.object(forKey: Constants.dbIdImdbId) 		as? String }
		if (ckRecord.object(forKey: Constants.dbIdOrigTitle) != nil)		{ self.origTitle 		= ckRecord.object(forKey: Constants.dbIdOrigTitle) 	as? String }

		if (ckRecord.object(forKey: Constants.dbIdTitleEN) != nil) 		{ self.title[MovieCountry.USA.languageArrayIndex] 		= ckRecord.object(forKey: Constants.dbIdTitleEN) as! String }
		if (ckRecord.object(forKey: Constants.dbIdSortTitleEN) != nil) 	{ self.sortTitle[MovieCountry.USA.languageArrayIndex]	= ckRecord.object(forKey: Constants.dbIdSortTitleEN) 	as! String }
		if (ckRecord.object(forKey: Constants.dbIdSynopsisEN) != nil) 	{ self.synopsis[MovieCountry.USA.languageArrayIndex] 	= ckRecord.object(forKey: Constants.dbIdSynopsisEN) 	as! String }
		if (ckRecord.object(forKey: Constants.dbIdPosterUrlEN) != nil) 	{ self.posterUrl[MovieCountry.USA.languageArrayIndex] 	= ckRecord.object(forKey: Constants.dbIdPosterUrlEN) 	as! String }
        if (ckRecord.object(forKey: Constants.dbIdHomepageEN) != nil)   { self.homepage[MovieCountry.USA.languageArrayIndex]    = ckRecord.object(forKey: Constants.dbIdHomepageEN)     as! String }
        if (ckRecord.object(forKey: Constants.dbIdTaglineEN) != nil)    { self.tagline[MovieCountry.USA.languageArrayIndex]     = ckRecord.object(forKey: Constants.dbIdTaglineEN)      as! String }

		if (ckRecord.object(forKey: Constants.dbIdTitleDE) != nil) 		{ self.title[MovieCountry.Germany.languageArrayIndex] 		= ckRecord.object(forKey: Constants.dbIdTitleDE) 		as! String }
		if (ckRecord.object(forKey: Constants.dbIdSortTitleDE) != nil) 	{ self.sortTitle[MovieCountry.Germany.languageArrayIndex] 	= ckRecord.object(forKey: Constants.dbIdSortTitleDE) 	as! String }
		if (ckRecord.object(forKey: Constants.dbIdSynopsisDE) != nil) 	{ self.synopsis[MovieCountry.Germany.languageArrayIndex] 	= ckRecord.object(forKey: Constants.dbIdSynopsisDE) 	as! String }
		if (ckRecord.object(forKey: Constants.dbIdPosterUrlDE) != nil) 	{ self.posterUrl[MovieCountry.Germany.languageArrayIndex]	= ckRecord.object(forKey: Constants.dbIdPosterUrlDE) 	as! String }
        if (ckRecord.object(forKey: Constants.dbIdHomepageDE) != nil)   { self.homepage[MovieCountry.Germany.languageArrayIndex]    = ckRecord.object(forKey: Constants.dbIdHomepageDE)     as! String }
        if (ckRecord.object(forKey: Constants.dbIdTaglineDE) != nil)    { self.tagline[MovieCountry.Germany.languageArrayIndex]     = ckRecord.object(forKey: Constants.dbIdTaglineDE)      as! String }

		if (ckRecord.object(forKey: Constants.dbIdReleaseUS) != nil) 		{ self.releaseDate[MovieCountry.USA.countryArrayIndex] 		 = ckRecord.object(forKey: Constants.dbIdReleaseUS) 		as! Date }
		if (ckRecord.object(forKey: Constants.dbIdCertificationUS) != nil){ self.certification[MovieCountry.USA.countryArrayIndex] 	     = ckRecord.object(forKey: Constants.dbIdCertificationUS) 	as! String }
		if (ckRecord.object(forKey: Constants.dbIdReleaseDE) != nil) 		{ self.releaseDate[MovieCountry.Germany.countryArrayIndex] 	 = ckRecord.object(forKey: Constants.dbIdReleaseDE) 		as! Date }
		if (ckRecord.object(forKey: Constants.dbIdCertificationDE) != nil){ self.certification[MovieCountry.Germany.countryArrayIndex]   = ckRecord.object(forKey: Constants.dbIdCertificationDE) 	as! String }
		if (ckRecord.object(forKey: Constants.dbIdReleaseGB) != nil) 		{ self.releaseDate[MovieCountry.England.countryArrayIndex] 	 = ckRecord.object(forKey: Constants.dbIdReleaseGB) 		as! Date }
		if (ckRecord.object(forKey: Constants.dbIdCertificationGB) != nil){ self.certification[MovieCountry.England.countryArrayIndex]   = ckRecord.object(forKey: Constants.dbIdCertificationGB) 	as! String }

		if let value = ckRecord.object(forKey: Constants.dbIdRuntimeEN) as? Int				{ self.runtime[MovieCountry.USA.languageArrayIndex] 		= value }
		if let value = ckRecord.object(forKey: Constants.dbIdTrailerIdsEN) as? [String] 	{ self.trailerIds[MovieCountry.USA.languageArrayIndex] 		= value }
		if let value = ckRecord.object(forKey: Constants.dbIdRuntimeDE) as? Int				{ self.runtime[MovieCountry.Germany.languageArrayIndex] 	= value }
		if let value = ckRecord.object(forKey: Constants.dbIdTrailerIdsDE) as? [String] 	{ self.trailerIds[MovieCountry.Germany.languageArrayIndex] 	= value }

		if let value = ckRecord.object(forKey: Constants.dbIdVoteAverage) as? Double			{ self.voteAverage 			= value }
		if let value = ckRecord.object(forKey: Constants.dbIdGenreIds) as? [Int]	 			{ self.genreIds 			= value }
		if let value = ckRecord.object(forKey: Constants.dbIdDirectors) as? [String] 			{ self.directors 			= value }
		if let value = ckRecord.object(forKey: Constants.dbIdActors) as? [String] 				{ self.actors 				= value }
		if let value = ckRecord.object(forKey: Constants.dbIdCharacters) as? [String] 			{ self.characters 			= value }
		if let value = ckRecord.object(forKey: Constants.dbIdProductionCountries) as? [String] 	{ self.productionCountries 	= value }
		if let value = ckRecord.object(forKey: Constants.dbIdPopularity) as? Int				{ self.popularity 			= value }
		if let value = ckRecord.object(forKey: Constants.dbIdVoteCount) as? Int					{ self.voteCount 			= value }
		if let value = ckRecord.object(forKey: Constants.dbIdHidden) as? Bool					{ self.isHidden				= value }

		if let value = ckRecord.object(forKey: Constants.dbIdProfilePictures) as? [String] 		{ self.profilePictures 		= value }
		if let value = ckRecord.object(forKey: Constants.dbIdDirectorPictures) as? [String] 	{ self.directorPictures 	= value }
        if let value = ckRecord.object(forKey: Constants.dbIdCrewWriting) as? [String]          { self.crewWriting          = value }

		if (ckRecord.object(forKey: Constants.dbIdRatingImdb) != nil) 		{ self.ratingImdb 		= ckRecord.object(forKey: Constants.dbIdRatingImdb) 		as? Double }
		if (ckRecord.object(forKey: Constants.dbIdRatingMetacritic) != nil) { self.ratingMetacritic = ckRecord.object(forKey: Constants.dbIdRatingMetacritic)   as? Int }
		if (ckRecord.object(forKey: Constants.dbIdRatingTomato) != nil) 	{ self.ratingTomato 	= ckRecord.object(forKey: Constants.dbIdRatingTomato) 	    as? Int }
		if (ckRecord.object(forKey: Constants.dbIdTomatoImage) != nil) 		{ self.tomatoImage 		= ckRecord.object(forKey: Constants.dbIdTomatoImage) 		as? Int }
		if (ckRecord.object(forKey: Constants.dbIdTomatoURL) != nil) 		{ self.tomatoURL 		= ckRecord.object(forKey: Constants.dbIdTomatoURL) 		    as? String }

		if (ckRecord.object(forKey: Constants.dbIdBudget) != nil)		{ self.budget	= ckRecord.object(forKey: Constants.dbIdBudget) as? Int }
		if (ckRecord.object(forKey: Constants.dbIdBackdrop) != nil) 	{ self.backdrop	= ckRecord.object(forKey: Constants.dbIdBackdrop)	as? String }

		id = ckRecord.recordID.recordName
	}
	
	/**
		Converts this object to a dictionary for serialization.
	
		- returns: A dictionary with all non-null members of this object.
	*/
	open func toDictionary() -> [String: AnyObject] {
		
		var retval: [String:AnyObject] = [:]
		
		if let tmdbId 		 = tmdbId 		 { retval[Constants.dbIdTmdbId] 	= tmdbId as AnyObject? }
		if let origTitle 	 = origTitle 	 { retval[Constants.dbIdOrigTitle] 	= origTitle as AnyObject? }
		if let imdbId 		 = imdbId 		 { retval[Constants.dbIdImdbId] 	= imdbId as AnyObject? }
		
		retval[Constants.dbIdReleaseUS] 		= releaseDate[MovieCountry.USA.countryArrayIndex] as AnyObject?
		retval[Constants.dbIdCertificationUS] 	= certification[MovieCountry.USA.countryArrayIndex] as AnyObject?
		retval[Constants.dbIdReleaseDE] 		= releaseDate[MovieCountry.Germany.countryArrayIndex] as AnyObject?
		retval[Constants.dbIdCertificationDE] 	= certification[MovieCountry.Germany.countryArrayIndex] as AnyObject?
		retval[Constants.dbIdReleaseGB] 		= releaseDate[MovieCountry.England.countryArrayIndex] as AnyObject?
		retval[Constants.dbIdCertificationGB] 	= certification[MovieCountry.England.countryArrayIndex] as AnyObject?
		
		retval[Constants.dbIdSortTitleDE]		= sortTitle[MovieCountry.Germany.languageArrayIndex] as AnyObject?
		retval[Constants.dbIdRuntimeDE] 		= runtime[MovieCountry.Germany.languageArrayIndex] as AnyObject?
		retval[Constants.dbIdTrailerIdsDE] 		= trailerIds[MovieCountry.Germany.languageArrayIndex] as AnyObject?
		retval[Constants.dbIdTitleDE] 			= title[MovieCountry.Germany.languageArrayIndex] as AnyObject?
		retval[Constants.dbIdSynopsisDE] 	 	= synopsis[MovieCountry.Germany.languageArrayIndex] as AnyObject?
		retval[Constants.dbIdPosterUrlDE] 	 	= posterUrl[MovieCountry.Germany.languageArrayIndex] as AnyObject?
        retval[Constants.dbIdHomepageDE]        = homepage[MovieCountry.Germany.languageArrayIndex] as AnyObject?
        retval[Constants.dbIdTaglineDE]         = tagline[MovieCountry.Germany.languageArrayIndex] as AnyObject?

		retval[Constants.dbIdSortTitleEN]		= sortTitle[MovieCountry.USA.languageArrayIndex] as AnyObject?
		retval[Constants.dbIdRuntimeEN] 		= runtime[MovieCountry.USA.languageArrayIndex] as AnyObject?
		retval[Constants.dbIdTrailerIdsEN] 		= trailerIds[MovieCountry.USA.languageArrayIndex] as AnyObject?
		retval[Constants.dbIdTitleEN] 			= title[MovieCountry.USA.languageArrayIndex] as AnyObject?
		retval[Constants.dbIdSynopsisEN] 	 	= synopsis[MovieCountry.USA.languageArrayIndex] as AnyObject?
		retval[Constants.dbIdPosterUrlEN] 	 	= posterUrl[MovieCountry.USA.languageArrayIndex] as AnyObject?
        retval[Constants.dbIdHomepageEN]        = homepage[MovieCountry.USA.languageArrayIndex] as AnyObject?
        retval[Constants.dbIdTaglineEN]         = tagline[MovieCountry.USA.languageArrayIndex] as AnyObject?

		retval[Constants.dbIdRatingImdb] 		= ratingImdb as AnyObject?
		retval[Constants.dbIdRatingMetacritic] 	= ratingMetacritic as AnyObject?
		retval[Constants.dbIdRatingTomato] 		= ratingTomato as AnyObject?
		retval[Constants.dbIdTomatoImage] 		= tomatoImage as AnyObject?
		retval[Constants.dbIdTomatoURL] 		= tomatoURL as AnyObject?

		retval[Constants.dbIdBudget]			= budget as AnyObject?
		retval[Constants.dbIdBackdrop]			= backdrop as AnyObject?
		retval[Constants.dbIdProfilePictures] 	= profilePictures as AnyObject?
		retval[Constants.dbIdDirectorPictures] 	= directorPictures as AnyObject?
        retval[Constants.dbIdCrewWriting]       = crewWriting as AnyObject?

		retval[Constants.dbIdVoteAverage] 			= voteAverage as AnyObject?
		retval[Constants.dbIdDirectors] 			= directors as AnyObject?
		retval[Constants.dbIdActors] 				= actors as AnyObject?
		retval[Constants.dbIdCharacters]			= characters as AnyObject?
		retval[Constants.dbIdProductionCountries] 	= productionCountries as AnyObject?
		retval[Constants.dbIdPopularity] 			= popularity as AnyObject?
		retval[Constants.dbIdVoteCount] 			= voteCount as AnyObject?
		retval[Constants.dbIdHidden] 				= hidden as AnyObject?
		retval[Constants.dbIdGenreIds]				= genreIds as AnyObject?
		retval[Constants.dbIdId] 					= id as AnyObject?
		
		return retval
	}
	
	/**
		Converts this object to a dictionary for serialization to the Apple Watch.
	
		- parameter genreDict: The dictionary with genre-id as key and genre-name as value
	
		- returns: A dictionary with all non-null members of this object.
	*/
	open func toWatchDictionary(genreDict: [Int : String]) -> [String: AnyObject] {
		
		var retval: [String:AnyObject] = [:]
		
		if let origTitle 	 = origTitle 	 { retval[Constants.dbIdOrigTitle] 	= origTitle as AnyObject? }
		
		retval[Constants.dbIdTitle] 				= title[currentCountry.languageArrayIndex] as AnyObject?
		retval[Constants.dbIdSortTitle]				= sortTitle[currentCountry.languageArrayIndex] as AnyObject?
		retval[Constants.dbIdRelease] 				= releaseDate[currentCountry.countryArrayIndex] as AnyObject?
		retval[Constants.dbIdPosterUrl] 		 	= posterUrl[currentCountry.languageArrayIndex] as AnyObject?
		retval[Constants.dbIdDirectors] 			= directors as AnyObject?
		retval[Constants.dbIdProductionCountries]	= countryString as AnyObject?
		retval[Constants.dbIdRuntime]				= runtimeForLanguage.0 as AnyObject?
		retval[Constants.dbIdSynopsis]	 	 		= synopsisForLanguage.0 as AnyObject?

		// add up to 5 actors
		var actorNames: [String] = []
		
		for (index, actor) in actors.enumerated() {
			actorNames.append(actor)
			
			if (index == 4) {
				break
			}
		}

		retval[Constants.dbIdActors] = actorNames as AnyObject?
		
		// add genre names
		var genreNames: [String] = []

		for genreId in genreIds {
			guard let genreName = genreDict[genreId] else { continue }
			genreNames.append(genreName)
		}
		
		retval[Constants.dbIdGenreNames] = genreNames as AnyObject?

		// add certification
		
		let cert = certification[currentCountry.countryArrayIndex]
		
		if (cert.count > 0) {
			var certText = ""
			
			if (cert == "PG-13") {
				// fighting for every pixel ;-)
				certText = "PG13"
			}
			else if (currentCountry == MovieCountry.Germany) {
				certText = "FSK" + cert
			}
			else {
				certText = "\(cert)"
			}

			retval[Constants.dbIdCertification] = certText as AnyObject?
		}
		
		return retval
	}
	
	/*
		Generates a string of genres for this movie.
	
		- parameter genreDict: The dictionary with genre-id as key and genre-name as value
	
		- returns: The genre-string as optional
	*/
	fileprivate func makeGenreString(genreDict: [Int : String]) -> String? {
		var genreText: String = ""
		
		if (genreIds.count > 0) {
			for genreId in genreIds {
				guard let genreName = genreDict[genreId] else { continue }
				genreText += genreName + ", "
			}
			
            genreText.removeLast(2)
            return genreText
		}
		else {
			return nil
		}
	}
	
	/*
		Generates an array of strings as subtitle for display.
	
		- parameter genreDict: The dictionary with genre-id as key and genre-name as value
	
		- returns: The array of strings with movie informations
	*/
	func getSubtitleArray(genreDict: [Int : String]) -> [String] {
		var subtitles: [String] = []
		
		if let origText = originalTitleForDisplay {
			subtitles.append(origText)
		}
		
		if let details = detailSubtitle {
			subtitles.append(details)
		}
		
		if let genres = makeGenreString(genreDict: genreDict) {
			subtitles.append(genres)
		}
		
		return subtitles
	}
	
	/**
		Checks if the movie is now playing in theaters.
	
		- returns: TRUE if it is now playing, FALSE otherwise
	*/
	func isNowPlaying() -> Bool {
		var retval = false
		
		if let localReleaseDate = releaseDateInLocalTimezone {
			if (localReleaseDate.compare(Date(timeIntervalSince1970: 0)) == ComparisonResult.orderedDescending) {
				let now = Date()
				retval = (localReleaseDate.compare(now) != ComparisonResult.orderedDescending)
			}
		}
		
		return retval
	}

	/**
		Checks if the updated version of the movie record has changes which are visible in the table cell.
	
		- parameter updatedMovie: the updated version of this movie
	
		- returns: TRUE if there are visible changes in the movie, FALSE otherwise
	*/
	func hasVisibleChanges(updatedMovie: MovieRecord) -> Bool {
		
		// TODO nochmal durchdenken
		
		if ((title[currentCountry.languageArrayIndex] != updatedMovie.title[currentCountry.languageArrayIndex]) ||
			(origTitle != updatedMovie.origTitle) ||
			(runtime[currentCountry.languageArrayIndex] != updatedMovie.runtime[currentCountry.languageArrayIndex]) ||
			(productionCountries != updatedMovie.productionCountries) || (genreIds != updatedMovie.genreIds))
		{
			if ((posterUrl[currentCountry.languageArrayIndex].count == 0) && (updatedMovie.posterUrl[currentCountry.languageArrayIndex].count > 0)) {
				return true
			}
		}
		
		return false
	}
	
	/**
		Migrates this record to a new database version by filling the given database fields
		with the values from the given update-record.
		
		- parameter updateRecord:	The record to copy the values from
		- parameter updateKeys: 	The database keys to update
	*/
	func migrate(updateRecord: MovieRecord, updateKeys: [String]) {
		
		// [Constants.dbIdRatingImdb, Constants.dbIdRatingTomato, Constants.dbIdTomatoImage, Constants.dbIdTomatoURL, Constants.dbIdRatingMetacritic]
		
		// version 1.2
		
		if (updateKeys.contains(Constants.dbIdRatingImdb)) {
			self.ratingImdb = updateRecord.ratingImdb
		}
		if (updateKeys.contains(Constants.dbIdRatingTomato)) {
			self.ratingTomato = updateRecord.ratingTomato
		}
		if (updateKeys.contains(Constants.dbIdTomatoImage)) {
			self.tomatoImage = updateRecord.tomatoImage
		}
		if (updateKeys.contains(Constants.dbIdTomatoURL)) {
			self.tomatoURL = updateRecord.tomatoURL
		}
		if (updateKeys.contains(Constants.dbIdRatingMetacritic)) {
			self.ratingMetacritic = updateRecord.ratingMetacritic
		}
		
		// version 1.3
		
		if (updateKeys.contains(Constants.dbIdBudget)) {
			self.budget = updateRecord.budget
		}
		if (updateKeys.contains(Constants.dbIdBackdrop)) {
			self.backdrop = updateRecord.backdrop
		}
		if (updateKeys.contains(Constants.dbIdProfilePictures)) {
			self.profilePictures = updateRecord.profilePictures
		}
		if (updateKeys.contains(Constants.dbIdDirectorPictures)) {
			self.directorPictures = updateRecord.directorPictures
		}
        if (updateKeys.contains(Constants.dbIdHomepageEN) || updateKeys.contains(Constants.dbIdHomepageDE))
        {
            self.homepage = updateRecord.homepage
        }
        if (updateKeys.contains(Constants.dbIdTaglineEN) || updateKeys.contains(Constants.dbIdTaglineDE))
        {
            self.tagline = updateRecord.tagline
        }
        if (updateKeys.contains(Constants.dbIdCrewWriting))
        {
            self.crewWriting = updateRecord.crewWriting
        }
	}
	
	
	// MARK: - Printable
	
	
	open var description: String {
		
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
		
		if title[currentCountry.languageArrayIndex].count > 0 {
			retval += "title: \(title[currentCountry.languageArrayIndex]) | "
		} else {
			retval += "title: nil | "
		}
		
		if sortTitle[currentCountry.languageArrayIndex].count > 0 {
			retval += "sortTitle: \(sortTitle[currentCountry.languageArrayIndex]) | "
		} else {
			retval += "sortTitle: nil | "
		}
		
		if let origTitle = origTitle {
			retval += "origTitle: \(origTitle) | "
		} else {
			retval += "origTitle: nil | "
		}
		
		if releaseDate[currentCountry.countryArrayIndex].compare(Date(timeIntervalSince1970: 0)) == ComparisonResult.orderedDescending {
			retval += "releaseDate: \(releaseDate[currentCountry.countryArrayIndex]) | "
		} else {
			retval += "releaseDate: nil | "
		}
		
		if posterUrl[currentCountry.languageArrayIndex].count > 0 {
			retval += "posterUrl: \(posterUrl[currentCountry.languageArrayIndex]) | "
		} else {
			retval += "posterUrl: nil | "
		}
		
		return retval
	}

}

