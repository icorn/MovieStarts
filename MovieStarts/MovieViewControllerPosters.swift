//
//  MovieViewControllerPosters.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 20.09.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation
import UIKit


extension MovieViewController {
	
	/**
		Enlarges the tapped thumbnail poster.
	
		- parameter recognizer:	The gesture recognizer - unused.
	*/
	func thumbnailTapped(recognizer: UITapGestureRecognizer) {

		if let movie = movie, navigationController = navigationController {
			let bigPoster = movie.bigPoster
			
			// create poster background, scrollview, and imageview
			
			bigPosterBackView = UIView()
			bigPosterScrollView = UIScrollView()
			bigPosterImageView = UIImageView()
			
			spinnerBackground = UIView()
			spinner = UIActivityIndicatorView()

			if let bigPosterImageView = bigPosterImageView, bigPosterScrollView = bigPosterScrollView, bigPosterBackView = bigPosterBackView, spinnerBackground = self.spinnerBackground, spinner = self.spinner {

				// set up UI elements
				
				bigPosterBackView.backgroundColor = UIColor.clearColor()
				bigPosterBackView.translatesAutoresizingMaskIntoConstraints = false

				bigPosterScrollView.minimumZoomScale = 1.0
				bigPosterScrollView.maximumZoomScale = 6.0
				bigPosterScrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height)
				bigPosterScrollView.delegate = self
				bigPosterScrollView.translatesAutoresizingMaskIntoConstraints = false
				
				bigPosterImageView.contentMode = UIViewContentMode.ScaleAspectFit
				bigPosterImageView.translatesAutoresizingMaskIntoConstraints = false
				bigPosterImageView.userInteractionEnabled = true
				bigPosterImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("bigPosterTapped:")))
				
				if let bigPoster = bigPoster {
					bigPosterImageView.image = bigPoster
				}
				else {
					bigPosterImageView.image = movie.thumbnailImage.0
				}
				
				spinnerBackground.translatesAutoresizingMaskIntoConstraints = false
				spinnerBackground.backgroundColor = UIColor.blackColor()
				spinnerBackground.alpha = 0.6
				spinnerBackground.layer.cornerRadius = 6
				spinnerBackground.hidden = true
				
				spinner.translatesAutoresizingMaskIntoConstraints = false
				spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
				spinner.hidesWhenStopped = true

				bigPosterImageView.translatesAutoresizingMaskIntoConstraints = false
				
				// add subviews to views

				spinnerBackground.addSubview(spinner)
				bigPosterImageView.addSubview(spinnerBackground)
				bigPosterScrollView.addSubview(bigPosterImageView)
				bigPosterBackView.addSubview(bigPosterScrollView)
				self.view.addSubview(bigPosterBackView)
				
				// set up constraints
				
				let viewsDictionary = ["bigPosterBackView": bigPosterBackView, "bigPosterScrollView": bigPosterScrollView, "bigPosterImageView": bigPosterImageView]

				self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[bigPosterBackView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary))
				self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[bigPosterBackView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary))
				bigPosterBackView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[bigPosterScrollView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary))
				bigPosterBackView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[bigPosterScrollView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary))
				
				posterImageViewTopConstraint = NSLayoutConstraint(item: bigPosterImageView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal,
					toItem: bigPosterScrollView, attribute: NSLayoutAttribute.Top, multiplier: 1.0,
					constant: posterImageView.frame.minY + navigationController.navigationBar.frame.height + navigationController.navigationBar.frame.origin.y)
				posterImageViewLeadingConstraint = NSLayoutConstraint(item: bigPosterImageView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal,
					toItem: bigPosterScrollView, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: posterImageView.frame.minX)
				posterImageViewWidthConstraint = NSLayoutConstraint(item: bigPosterImageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal,
					toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: posterImageView.frame.width)
				posterImageViewHeightConstraint = NSLayoutConstraint(item: bigPosterImageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal,
					toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: posterImageView.frame.height)
				
				bigPosterImageView.addConstraints([
					NSLayoutConstraint(item: spinnerBackground, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal,
						toItem: bigPosterImageView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0),
					NSLayoutConstraint(item: spinnerBackground, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal,
						toItem: bigPosterImageView,	attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0),
					NSLayoutConstraint(item: spinnerBackground, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal,
						toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 80),
					NSLayoutConstraint(item: spinnerBackground, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal,
						toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 80)
				])
				spinnerBackground.addConstraints([
					NSLayoutConstraint(item: spinner, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal,
						toItem: spinnerBackground, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0),
					NSLayoutConstraint(item: spinner, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal,
						toItem: spinnerBackground, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0)
				])
				
				if let imageViewTopConstraint = posterImageViewTopConstraint, imageViewLeadingConstraint = posterImageViewLeadingConstraint,
					imageViewWidthConstraint = posterImageViewWidthConstraint, imageViewHeightConstraint = posterImageViewHeightConstraint
				{
					bigPosterScrollView.addConstraints([imageViewTopConstraint, imageViewLeadingConstraint, imageViewWidthConstraint, imageViewHeightConstraint])
				
					// animate it to a bigger poster
					
					navigationController.setNavigationBarHidden(true, animated: false)
					self.tabBarController?.tabBar.hidden = true
					posterImageTopSpaceConstraint.constant += navigationController.navigationBar.frame.height
					view.layoutIfNeeded()

					UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut,
						animations: {
							bigPosterBackView.backgroundColor = UIColor.blackColor()
							imageViewTopConstraint.constant = 0
							imageViewLeadingConstraint.constant = 0
							imageViewHeightConstraint.constant = navigationController.view.frame.height
							imageViewWidthConstraint.constant = navigationController.view.frame.width
							self.view.layoutIfNeeded()
						},
						completion: { finished in
							if bigPoster != nil {
								// big poster already loaded, that's it
								return
							}
							
							// turn on network indicator and spinner
							UIApplication.sharedApplication().networkActivityIndicatorVisible = true
							dispatch_async(dispatch_get_main_queue()) {
								self.spinnerBackground?.hidden = false
								self.spinner?.startAnimating()
							}
							
							// no big poster: load it!
							
							if (NetworkChecker.checkReachability(self.view) == false) {
								// no network available
								self.stopSpinners()
								return
							}

							self.loadBigPoster()
						}
					)
				}
			}
		}
	}
	
	
	/**
		Loads the big movie poster and stores it on the device.
	*/
	func loadBigPoster() {
		
		guard let bigPosterImageView = bigPosterImageView, movie = movie else {
			stopSpinners()
			return
		}
		
		var errorWindow: MessageWindow?

		// build paths
		guard let targetPath = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(Constants.movieStartsGroup)?.path else {
			stopSpinners()
			return
		}
		
		let sourcePath = Constants.imageBaseUrl + PosterSizePath.Big.rawValue
		var posterUrl = movie.posterUrl[movie.currentCountry.languageArrayIndex]
		
		if (posterUrl.characters.count == 0) {
			// if there is no poster in wanted language, try the english one
			posterUrl = movie.posterUrl[MovieCountry.USA.languageArrayIndex]
		}
		
		if (posterUrl.characters.count <= 0) {
			stopSpinners()
			return
		}
		
		// poster file is missing
		
		guard let sourceUrl = NSURL(string: sourcePath + posterUrl) else {
			stopSpinners()
			return
		}
		
		let task = NSURLSession.sharedSession().downloadTaskWithURL(sourceUrl, completionHandler: { (location: NSURL?, response: NSURLResponse?, error: NSError?) -> Void in
			self.stopSpinners()
			
			if let error = error {
				NSLog("Error getting missing thumbnail: \(error.description)")
			}
			else if let receivedPath = location?.path {
				// move received poster to target path where it belongs
				do {
					try NSFileManager.defaultManager().moveItemAtPath(receivedPath, toPath: targetPath + Constants.bigPosterFolder + posterUrl)
				}
				catch let error as NSError {
					if ((error.domain == NSCocoaErrorDomain) && (error.code == NSFileWriteFileExistsError)) {
						// ignoring, because it's okay it it's already there
					}
					else {
						NSLog("Error moving missing poster: \(error.description)")
						dispatch_async(dispatch_get_main_queue()) {
							errorWindow = MessageWindow(parent: bigPosterImageView, darkenBackground: true, titleStringId: "BigPosterErrorTitle", textStringId: "BigPosterErrorText", buttonStringIds: ["Close"], handler: { (buttonIndex) -> () in
								errorWindow?.close()
							})
						}
						return
					}
				}
				
				// load and show poster
				if let bigPoster = movie.bigPoster {
					dispatch_async(dispatch_get_main_queue()) {
						bigPosterImageView.image = bigPoster
					}
					return
				}
				
				// poster not loaded or error
				if let error = error {
					NSLog("Error getting big poster: \(error.code) (\(error.description))")
				}
				
				dispatch_async(dispatch_get_main_queue()) {
					errorWindow = MessageWindow(parent: bigPosterImageView, darkenBackground: true, titleStringId: "BigPosterErrorTitle", textStringId: "BigPosterErrorText", buttonStringIds: ["Close"], handler: { (buttonIndex) -> () in
						errorWindow?.close()
					})
				}
			}
		})
		
		task.resume()
	}

	/**
		Stops both the network activity indicator and the loading spinner. 
		Also removes the loading spinner from the superview.
	*/
	private func stopSpinners() {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = false
			dispatch_async(dispatch_get_main_queue()) {
			self.spinner?.stopAnimating()
			self.spinnerBackground?.removeFromSuperview()
		}
	}
	
	/**
		Closes the enlarged poster.
	
		- parameter recognizer:	The gesture recognizer - unused.
	*/
	func bigPosterTapped(recognizer: UITapGestureRecognizer) {
		
		if let bigPosterImageView = bigPosterImageView, bigPosterScrollView = bigPosterScrollView, bigPosterBackView = bigPosterBackView, navigationController = navigationController {
			
			self.spinner?.stopAnimating()
			self.spinnerBackground?.removeFromSuperview()

			UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut,
				animations: {
					bigPosterBackView.backgroundColor = UIColor.clearColor()
					self.posterImageViewTopConstraint?.constant = self.posterImageView.frame.minY + navigationController.navigationBar.frame.height + navigationController.navigationBar.frame.origin.y + self.posterImageView.frame.height/2
					self.posterImageViewLeadingConstraint?.constant = self.posterImageView.frame.minX + self.posterImageView.frame.width/2
					self.posterImageViewHeightConstraint?.constant = 1
					self.posterImageViewWidthConstraint?.constant = 1
					self.view.layoutIfNeeded()
				},
				completion: { finished in
					navigationController.setNavigationBarHidden(false, animated: false)
					self.tabBarController?.tabBar.hidden = false
					self.posterImageTopSpaceConstraint.constant -= navigationController.navigationBar.frame.height
					bigPosterImageView.removeFromSuperview()
					bigPosterScrollView.removeFromSuperview()
					bigPosterBackView.removeFromSuperview()
					self.bigPosterImageView = nil
					self.bigPosterScrollView = nil
					self.bigPosterBackView = nil
				}
			)
		}
	}
	
	
	// MARK: - UIScrollViewDelegate (for big poster view)
	
	func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
		return bigPosterImageView
	}
	
}
