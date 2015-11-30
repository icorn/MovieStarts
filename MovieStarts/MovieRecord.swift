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
	

	/// The thumbnail image object as a tuple: the image object and the "found" flag indicating if a poster image was returned or if it only is the default image.
	override var thumbnailImage: (UIImage?, Bool) {
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
	
}

