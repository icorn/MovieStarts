//
//  AnimatedTabBar.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 20.09.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation
import UIKit


extension UITabBarController {
	
	func setTabBarVisible(visible:Bool, animated:Bool) {
		
		// bail if the current state matches the desired state
		if (tabBarIsVisible() == visible) { return }
		
		// get a frame calculation ready
		let frame = self.tabBar.frame
		let height = frame.size.height
		let offsetY = (visible ? -height : height)
		
		// animate the tabBar
		UIView.animateWithDuration(animated ? 0.3 : 0.0) {
			self.tabBar.frame = CGRectOffset(frame, 0, offsetY)
			self.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height + offsetY)
			self.view.setNeedsDisplay()
			self.view.layoutIfNeeded()
		}
	}
	
	func tabBarIsVisible() ->Bool {
		return self.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame)
	}
}

