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


public class MovieRecord : WatchMovieRecord {
	
	/**
		Initializes the class with a CKRecord as input.

		-parameter ckRecord:	The record used as input
	*/
	func initWithCKRecord(ckRecord: CKRecord) {
		
		if (ckRecord.objectForKey(Constants.DB_ID_TMDB_ID) != nil) 		{ self.tmdbId 			= ckRecord.objectForKey(Constants.DB_ID_TMDB_ID) 		as? Int }
		if (ckRecord.objectForKey(Constants.DB_ID_ORIG_TITLE) != nil)	{ self.origTitle 		= ckRecord.objectForKey(Constants.DB_ID_ORIG_TITLE) 	as? String }
		if (ckRecord.objectForKey(Constants.DB_ID_TITLE) != nil) 		{ self.title 			= ckRecord.objectForKey(Constants.DB_ID_TITLE) 			as? String }
		if (ckRecord.objectForKey(Constants.DB_ID_SORT_TITLE) != nil) 	{ self.sortTitle 		= ckRecord.objectForKey(Constants.DB_ID_SORT_TITLE) 	as? String }
		if (ckRecord.objectForKey(Constants.DB_ID_SYNOPSIS) != nil) 	{ self.synopsis 		= ckRecord.objectForKey(Constants.DB_ID_SYNOPSIS) 		as? String }
		if (ckRecord.objectForKey(Constants.DB_ID_RELEASE) != nil) 		{ self.releaseDate 		= ckRecord.objectForKey(Constants.DB_ID_RELEASE) 		as? NSDate }
		if (ckRecord.objectForKey(Constants.DB_ID_CERTIFICATION) != nil){ self.certification 	= ckRecord.objectForKey(Constants.DB_ID_CERTIFICATION) 	as? String }
		if (ckRecord.objectForKey(Constants.DB_ID_POSTER_URL) != nil) 	{ self.posterUrl 		= ckRecord.objectForKey(Constants.DB_ID_POSTER_URL) 	as? String }
		if (ckRecord.objectForKey(Constants.DB_ID_IMDB_ID) != nil) 		{ self.imdbId 			= ckRecord.objectForKey(Constants.DB_ID_IMDB_ID) 		as? String }
		
		if let value = ckRecord.objectForKey(Constants.DB_ID_RUNTIME) as? Int					{ self.runtime 				= value }
		if let value = ckRecord.objectForKey(Constants.DB_ID_VOTE_AVERAGE) as? Double			{ self.voteAverage 			= value }
		if let value = ckRecord.objectForKey(Constants.DB_ID_GENRES) as? [String] 				{ self.genres 				= value }
		if let value = ckRecord.objectForKey(Constants.DB_ID_DIRECTORS) as? [String] 			{ self.directors 			= value }
		if let value = ckRecord.objectForKey(Constants.DB_ID_ACTORS) as? [String] 				{ self.actors 				= value }
		if let value = ckRecord.objectForKey(Constants.DB_ID_TRAILER_NAMES) as? [String]		{ self.trailerNames 		= value }
		if let value = ckRecord.objectForKey(Constants.DB_ID_TRAILER_IDS) as? [String] 			{ self.trailerIds 			= value }
		if let value = ckRecord.objectForKey(Constants.DB_ID_PRODUCTION_COUNTRIES) as? [String] { self.productionCountries 	= value }
		if let value = ckRecord.objectForKey(Constants.DB_ID_POPULARITY) as? Int				{ self.popularity 			= value }
		if let value = ckRecord.objectForKey(Constants.DB_ID_VOTE_COUNT) as? Int				{ self.voteCount 			= value }
		
		id = ckRecord.recordID.recordName
	}
	
	
	/**
		Moves a downloaded poster from the temporary folder to the final one.
	
		- parameter asset:		The asset of the poster coming from CloudKit
		- parameter thumbnail:	The kind of poster (thumbnail or big)
	*/
	func storePoster(asset: CKAsset?, thumbnail: Bool) {
		
		let folder: String = (thumbnail ? Constants.THUMBNAIL_FOLDER : Constants.BIG_POSTER_FOLDER)
		
		if let asset = asset, posterUrl = posterUrl {
			let targetPathUrl = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(Constants.MOVIESTARTS_GROUP)
			
			if let targetPathUrl = targetPathUrl, targetBasePath = targetPathUrl.path, sourcePathString = asset.fileURL.path {
				let targetPathString = targetBasePath + folder + posterUrl
				
				// now we have both paths: copy the file
				
				do {
					try NSFileManager.defaultManager().moveItemAtPath(sourcePathString, toPath: targetPathString)
				}
				catch let error as NSError {
					if ((error.domain == NSCocoaErrorDomain) && (error.code == NSFileWriteFileExistsError)) {
						// ignoring, because it's okay it it's already there
					}
					else {
						NSLog("Error moving poster: \(error.description)")
					}
				}
			}
		}
	}

	
	/// The thumbnail image object as a tuple: the image object and the "found" flag indicating if a poster image was returned or if it only is the default image.
	
	override var thumbnailImage: (UIImage?, Bool) {
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

}
