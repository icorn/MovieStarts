//
//  StringExtension.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 15.10.15.
//  Copyright © 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation


extension String {
	func beginsWith (_ str: String) -> Bool {
		if let range = self.range(of: str) {
			return range.lowerBound == self.startIndex
		}
		return false
	}
	
	func endsWith (_ str: String) -> Bool {
		if let range = self.range(of: str, options:NSString.CompareOptions.backwards) {
			return range.upperBound == self.endIndex
		}
		return false
	}
	
	/// Removes the last characters of the string and returns it.
	///
	/// - parameter numberOfCharacters: the number of characters to remove
	///
	/// - returns: the new shorter string
	func substringByRemovingLastCharacters(numberOfCharacters: Int) -> String {
		if (numberOfCharacters > self.count) {
			return ""
		}
		else if (numberOfCharacters < 0) {
			return self
		}
		else {
            return String(prefix(self.count - numberOfCharacters))
		}
	}
}
