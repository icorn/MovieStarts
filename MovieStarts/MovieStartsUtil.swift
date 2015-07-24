//
//  Util.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 25.02.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation
import UIKit


class MovieStartsUtil {
	
	/**
		Shortens the given country name.
	
		:param:	name	The country name to be shortened
	
		:returns: The shortened country name (often the same as the input name).
	*/
	class func shortenCountryname(name: String) -> String {
		
		switch(name) {
		case "United States of America":
			return "USA"
		case "United Kingdom":
			return "UK"
		default:
			return name
		}
	}

}
