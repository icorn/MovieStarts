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
	
/*
	class func startActivityIndicator(parentView: UIView, title: String? = nil) -> UIView {
		
		var activityView: UIView?
		
		if (title != nil) {
			var labelWidth = (title! as NSString).sizeWithAttributes([NSFontAttributeName : UIFont.systemFontOfSize(16)]).width
			var viewWidth = labelWidth + 20
			
			activityView = UIView(frame:
				CGRect(x: parentView.frame.width / 2 - viewWidth / 2, y: parentView.frame.height / 2 - 50, width: viewWidth, height: 100))
			activityView?.layer.cornerRadius = 15
			activityView?.backgroundColor = UIColor.blackColor()
			var spinner = UIActivityIndicatorView(frame: CGRect(x: viewWidth/2 - 20, y: 20, width: 40, height: 40))
			spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
			spinner.startAnimating()
			var msg = UILabel(frame: CGRect(x: 10, y: 75, width: labelWidth, height: 20))
			msg.text = title
			msg.font = UIFont.systemFontOfSize(14)
			msg.textAlignment = NSTextAlignment.Center
			msg.textColor = UIColor.whiteColor()
			msg.backgroundColor = UIColor.clearColor()
			activityView?.opaque = false
			activityView?.backgroundColor = UIColor.blackColor()
			activityView?.addSubview(spinner)
			activityView?.addSubview(msg)
			parentView.addSubview(activityView!)
		}
		else {
			var viewWidth: CGFloat = 80.0
			activityView = UIView(frame: CGRect(x: parentView.frame.width/2 - viewWidth/2, y: parentView.frame.height/2 - 20, width: viewWidth, height: viewWidth))
			activityView?.layer.cornerRadius = 15
			activityView?.backgroundColor = UIColor.blackColor()

			var spinner = UIActivityIndicatorView(frame: CGRect(x: viewWidth/2 - 20, y: 20, width: 40, height: 40))
			spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
			spinner.startAnimating()
			activityView?.opaque = false
			activityView?.backgroundColor = UIColor.blackColor()
			activityView?.addSubview(spinner)
			parentView.addSubview(activityView!)
		}
		
		return activityView!
	}
	
	class func stopActivityIndicator(inout activityView: UIView?) {
		activityView?.removeFromSuperview()
		activityView = nil
	}
*/
	
}