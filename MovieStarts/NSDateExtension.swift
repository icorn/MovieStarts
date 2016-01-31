//
//  NSDateExtension.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 28.01.16.
//  Copyright © 2016 Oliver Eichhorn. All rights reserved.
//

import Foundation


extension NSDate {
	
	func setHour(hour: Int) -> NSDate {
		let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
		let components = calendar.components(([.Day, .Month, .Year]), fromDate: self)
		components.hour = hour
		return calendar.dateFromComponents(components)!
	}
	
}
