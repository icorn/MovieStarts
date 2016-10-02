//
//  MovieRecord.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 15.02.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation
import UIKit


open class WatchMovieRecord : CustomStringConvertible {

	/// the original movie title
	open var origTitle: String?
	/// the movie runtime in minutes
	open var runtime: Int?
	/// the movie title
	open var title: String?
	/// the movie title for sorting
	open var sortTitle: String?
	/// the synopsis of the movie
	open var synopsis: String?
	/// the release date of the movie
	open var releaseDate: Date?
	/// an array with movie genres as IDs
	open var genreNames: [String] = []
	/// an array of production countries as strings
	open var countries: String?
	/// the certification of the movie
	open var certification: String?
	/// the url of the poster
	open var posterUrl: String?
	/// an array of directors
	open var directors:[String] = []
	/// an array of actors
	open var actors:[String] = []
	
	var _thumbnailImage: UIImage?
	var _thumbnailFound: Bool = false
	
	
	init(origTitle: String?, runtime: Int?, title: String?, sortTitle: String?, synopsis: String?, releaseDate: Date?, genreNames: [String],
		countries: String?, certification: String?, posterUrl: String?, directors: [String], actors: [String])
	{
		self.origTitle 		= origTitle
		self.runtime		= runtime
		self.title			= title
		self.sortTitle		= sortTitle
		self.synopsis		= synopsis
		self.releaseDate	= releaseDate
		self.genreNames		= genreNames
		self.countries		= countries
		self.certification	= certification
		self.posterUrl		= posterUrl
		self.directors		= directors
		self.actors			= actors
	}

	
	/// The thumbnail image as NSURL
	
	var thumbnailURL: (URL?) {
		let pathUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.movieStartsGroup)
		var url: URL?
		
		if let posterUrl = posterUrl {
			if (posterUrl.characters.count > 0) {
				url = pathUrl?.appendingPathComponent(Constants.thumbnailFolder + posterUrl)
			}
		}

/* TODO
		if let posterUrl = posterUrl where (posterUrl.characters.count > 0) {
			url = pathUrl?.URLByAppendingPathComponent(Constants.thumbnailFolder + posterUrl)
		}
*/
		return url
	}
	
	/// The thumbnail image object as a tuple: the image object and the "found" flag indicating if a poster image was returned or if it only is the default image.
	
	var thumbnailImage: (UIImage?, Bool) {
		if ((_thumbnailFound == true) && (_thumbnailImage != nil)) {
			return (_thumbnailImage, _thumbnailFound)
		}
		
		let fileManager = FileManager.default
		let documentDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
		
		if let documentDir = documentDir, let posterUrl = posterUrl {
			// try to load the poster for the current language
			let movieFileNamePath = documentDir.appendingPathComponent(posterUrl).path
			_thumbnailImage = UIImage(contentsOfFile: movieFileNamePath)
			_thumbnailFound = true
			return (_thumbnailImage, _thumbnailFound)
		}
		
		_thumbnailImage = UIImage(named: "no-poster")
		_thumbnailFound = false
		return (_thumbnailImage, _thumbnailFound)
	}
	
	
	/// The release data as string in medium sized format.
	
	var releaseDateString: String {
		var retval = NSLocalizedString("NoReleaseDate", comment: "")
		
		if let releaseDate = releaseDate {
			if (releaseDate.compare(Date(timeIntervalSince1970: 0)) == ComparisonResult.orderedDescending) {
				let dateFormatter = DateFormatter()
				dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
				dateFormatter.timeStyle = DateFormatter.Style.none
				dateFormatter.dateStyle = DateFormatter.Style.medium
				retval = dateFormatter.string(from: releaseDate)
			}
		}
		
		return retval
	}

	// Calculates the release date of the movie for the local (current) timezone. Instead of midnight GMT this will be midnight in the local (current) timezone.
	var releaseDateInLocalTimezone: Date? {
		var localDate: Date?

		guard let releaseDate = releaseDate else { return localDate }
		
		var calendarGMT = Calendar(identifier: Calendar.Identifier.gregorian)
		var calendarLocal = Calendar(identifier: Calendar.Identifier.gregorian)
		let timezoneGMT = TimeZone(abbreviation: "GMT")
		
		if let timezoneGMT = timezoneGMT {
			calendarGMT.timeZone = timezoneGMT
			calendarLocal.timeZone = TimeZone.autoupdatingCurrent
			
			let gmtComponents = (calendarGMT as NSCalendar).components([NSCalendar.Unit.day, NSCalendar.Unit.month, NSCalendar.Unit.year], from: releaseDate)
			
			var localComponents = DateComponents()
			localComponents.day = gmtComponents.day
			localComponents.month = gmtComponents.month
			localComponents.year = gmtComponents.year
			localComponents.calendar = calendarLocal
			localDate = localComponents.date
		}
		
		return localDate
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

	
	// MARK: - Printable
	
	
	open var description: String {
		
		var retval = ""
		
		if let origTitle 	 = origTitle 	{ retval += "origTitle: \(origTitle) | " } else { retval += "origTitle: nil | " }
		if let runtime 		 = runtime 		{ retval += "runtime: \(runtime) | " } else { retval += "runtime: nil | " }
		if let title 		 = title 		{ retval += "title: \(title) | " } else { retval += "title: nil | " }
		if let sortTitle 	 = sortTitle 	{ retval += "sortTitle: \(sortTitle) | " } else { retval += "sortTitle: nil | " }
		if let synopsis 	 = synopsis 	{ retval += "synopsis: \(synopsis) | " } else { retval += "synopsis: nil | " }
		if let releaseDate 	 = releaseDate 	{ retval += "releaseDate: \(releaseDate) | " } else { retval += "releaseDate: nil | " }
		if let countries 	 = countries 	{ retval += "countries: \(countries) | " } else { retval += "countries: nil | " }
		if let certification = certification{ retval += "certification: \(certification) | " } else { retval += "certification: nil | " }
		if let posterUrl 	 = posterUrl 	{ retval += "posterUrl: \(posterUrl) | " } else { retval += "posterUrl: nil | " }
		
		retval += "genreNames: \(genreNames) | "
		retval += "directors: \(directors) | "
		retval += "actors: \(actors)"
		
		return retval
	}

}

