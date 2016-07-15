//
//  StackViewExtension.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 10.07.16.
//  Copyright © 2016 Oliver Eichhorn. All rights reserved.
//

import Foundation
import UIKit


extension UIStackView {

	func removeLastArrangedSubView() {
		guard let subViewToRemove = arrangedSubviews.last else {
			// no subviews there
			return
		}
		
		self.removeArrangedSubview(subViewToRemove)
		subViewToRemove.removeFromSuperview()
	}

}
