//
//  StringExtension.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 15.10.15.
//  Copyright © 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation


extension String {
	func beginsWith (str: String) -> Bool {
		if let range = self.rangeOfString(str) {
			return range.startIndex == self.startIndex
		}
		return false
	}
	
	func endsWith (str: String) -> Bool {
		if let range = self.rangeOfString(str, options:NSStringCompareOptions.BackwardsSearch) {
			return range.endIndex == self.endIndex
		}
		return false
	}
}
