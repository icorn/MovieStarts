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
	
		:param:	name	the country name to be shortened
	
		:returns: the shortened country name (often the same as the input name)
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
	
	
	/**
		Generates the subtitle for the detail view of a movie.
	
		:param:	movie	the MovieRecord object to generate the subtitle for
	
		:returns: the generated subtitle, consting of the runtime and the production countries
	*/
	class func generateDetailSubtitle(movie: MovieRecord) -> String {
		
		var detailText = ""
		
		// add runtime 
		
		if (movie.runtime > 0) {
			detailText += "\(movie.runtime) min | "
		}
		
		// add countries
		
		if (movie.productionCountries.count > 0) {
			for country in movie.productionCountries {
				detailText += MovieStartsUtil.shortenCountryname(country) + ", "
			}
		}
		
		if (count(detailText) > 0) {
			// remove last two characters
			detailText = detailText.substringToIndex(detailText.endIndex.predecessor().predecessor())
		}
		
		return detailText
	}
	
	
	/**
		Generates the string of call genres of a movie.
	
		:param:	movie	the MovieRecord object to generate the subtitle for
	
		:returns: the generated string consisting of the movies genres
	*/
	class func generateGenreString(movie: MovieRecord) -> String {
		
		var genreText = ""
		
		if (movie.genres.count > 0) {
			
			for genre in movie.genres {
				genreText += genre + ", "
			}
		}
		
		if (count(genreText) > 0) {
			genreText = genreText.substringToIndex(genreText.endIndex.predecessor().predecessor())
		}
		
		return genreText
	}

	
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