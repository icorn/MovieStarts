//
//  NSDateExtension.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 28.01.16.
//  Copyright © 2016 Oliver Eichhorn. All rights reserved.
//

import Foundation


extension Date {
	
	func setHour(_ hour: Int) -> Date {
		let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
		var components = (calendar as NSCalendar).components(([.day, .month, .year]), from: self)
		components.hour = hour
		return calendar.date(from: components)!
	}
	
}
