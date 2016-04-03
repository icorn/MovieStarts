//
//  TomatoImage.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 13.03.16.
//  Copyright © 2016 Oliver Eichhorn. All rights reserved.
//

import Foundation


enum TomatoImage: Int {
	case certified	= 1
	case fresh		= 2
	case rotten		= 3
	
	var filename: String {
		switch self {
			case .certified:	return "certified"
			case .fresh:		return "fresh"
			case .rotten:		return "rotten"
		}
	}

}
