//
//  MovieCountry.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 10.11.15.
//  Copyright © 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation


public enum MovieCountry: String {
	
	case USA 		= "US"
	case Germany	= "DE"
	case England	= "GB"
	
	static let numberOfDifferentCountries = 3
	static let numberOfDifferentLanguages = 2
	
	static let languageShortEN: String = "en"
	static let languageShortDE = "de"
	

	/// the short name of the language of the given country (mainly used for TMDB)
	var tmdbLanguageShort: String {
		switch self {
		case .USA, .England: return MovieCountry.languageShortEN
		case .Germany: 		 return MovieCountry.languageShortDE
		}
	}
	
	/// the index in the country-specific MovieRecord fields which are arrays
	var countryArrayIndex: Int {
		switch self {
		case .USA: 		return 0
		case .Germany: 	return 1
		case .England: 	return 2
		}
	}
	
	/// the index in the language-specific MovieRecord fields which are arrays
	var languageArrayIndex: Int {
		switch tmdbLanguageShort {
		case String(MovieCountry.languageShortEN): 	return 0
		case String(MovieCountry.languageShortDE): 	return 1
			
		default: return 0
		}
	}
	
	var countryQueryKeys: [String] {
		switch self {
		case .USA: 		return [Constants.dbIdReleaseUS, Constants.dbIdCertificationUS]
		case .Germany:	return [Constants.dbIdReleaseDE, Constants.dbIdCertificationDE]
		case .England:	return [Constants.dbIdReleaseGB, Constants.dbIdCertificationGB]
		}
	}

	var languageQueryKeys: [String] {
		switch self {
		case .USA, .England: return [Constants.dbIdSortTitleEN, Constants.dbIdTitleEN]
		case .Germany:		 return [Constants.dbIdSortTitleDE, Constants.dbIdTitleDE, Constants.dbIdPosterUrlDE, Constants.dbIdSynopsisDE, Constants.dbIdRuntimeDE,
								Constants.dbIdTrailerNamesDE, Constants.dbIdTrailerIdsDE]
		}
	}
	
	var databaseKeyRelease: String {
		switch self {
		case .USA: 		return "releaseUS"
		case .Germany: 	return "releaseDE"
		case .England: 	return "releaseGB"
		}
	}
	
	var welcomeStringId: String {
		switch self {
		case .USA: 		return "WelcomeUSA"
		case .Germany: 	return "WelcomeGermany"
		case .England: 	return "WelcomeGB"
		}
	}
}
