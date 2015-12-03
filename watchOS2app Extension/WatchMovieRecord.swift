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

	/// the original movie title
	public var origTitle: String?
	/// the movie runtime in minutes
	public var runtime: Int?
	/// the movie title
	public var title: String?
	/// the movie title for sorting
	public var sortTitle: String?
	/// the synopsis of the movie
	public var synopsis: String?
	/// the release date of the movie
	public var releaseDate: NSDate?
	/// an array with movie genres as IDs
	public var genreNames: [String] = []
	/// an array of production countries as strings
	public var countries: String?
	/// the certification of the movie
	public var certification: String?
	/// the url of the poster
	public var posterUrl: String?
	/// an array of directors
	public var directors:[String] = []
	/// an array of actors
	public var actors:[String] = []
	
	var _thumbnailImage: UIImage?
	var _thumbnailFound: Bool = false
	
	
	init(origTitle: String?, runtime: Int?, title: String?, sortTitle: String?, synopsis: String?, releaseDate: NSDate?, genreNames: [String],
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
	
	var thumbnailURL: (NSURL?) {
		let pathUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(Constants.movieStartsGroup)
		var url: NSURL?
		
		if let posterUrl = posterUrl where posterUrl.characters.count > 0 {
			url = pathUrl?.URLByAppendingPathComponent(Constants.thumbnailFolder + posterUrl)
		}
		
		return url
	}
	
	/// The thumbnail image object as a tuple: the image object and the "found" flag indicating if a poster image was returned or if it only is the default image.
	
	var thumbnailImage: (UIImage?, Bool) {
		if ((_thumbnailFound == true) && (_thumbnailImage != nil)) {
			return (_thumbnailImage, _thumbnailFound)
		}
		
		let fileManager = NSFileManager.defaultManager()
		let documentDir = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
		
		if let documentDir = documentDir {
			// try to load the poster for the current language
			if let posterUrl = posterUrl where posterUrl.characters.count > 0 {
				let movieFileNamePath = documentDir.URLByAppendingPathComponent(posterUrl).path

				if let movieFileNamePath = movieFileNamePath {
					_thumbnailImage = UIImage(contentsOfFile: movieFileNamePath)
					_thumbnailFound = true
					return (_thumbnailImage, _thumbnailFound)
				}
			}
		}
		
		_thumbnailImage = UIImage(named: "noposter.png")
		_thumbnailFound = false
		return (_thumbnailImage, _thumbnailFound)
	}
	
	
	// MARK: - Printable
	
	public var description: String {
		
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
	
	
	/**
		Checks if the movie is now playing in theaters.
	
		- returns: TRUE if it is now playing, FALSE otherwise
	*/
	func isNowPlaying() -> Bool {
		var retval = false
		
		if let releaseDate = releaseDate where releaseDate.compare(NSDate(timeIntervalSince1970: 0)) == NSComparisonResult.OrderedDescending {
			let today = NSDate()
			retval = (releaseDate.compare(today) != NSComparisonResult.OrderedDescending)
		}
		
		return retval
	}

	
	/// The release data as string in medium sized format.
	
	var releaseDateString: String {
		var retval = NSLocalizedString("NoReleaseDate", comment: "")
		
		if let releaseDate = releaseDate where releaseDate.compare(NSDate(timeIntervalSince1970: 0)) == NSComparisonResult.OrderedDescending {
			let dateFormatter = NSDateFormatter()
			dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
			dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
			retval = dateFormatter.stringFromDate(releaseDate)
		}
		
		return retval
	}

}

