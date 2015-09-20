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
	
		:param: recognizer	The gesture recognizer - unused.
	*/
	func thumbnailTapped(recognizer: UITapGestureRecognizer) {

		if let movie = movie, navigationController = navigationController {
			var bigPoster = movie.bigPoster
			var bigPosterBackRect = navigationController.view.frame
			
			// create poster background, scrollview, and imageview
			
			bigPosterBackView = UIView(frame: bigPosterBackRect)
			bigPosterScrollView = UIScrollView(frame: CGRect(x: posterImageView.frame.minX, y: posterImageView.frame.minY + totalBarHeight,
				width: posterImageView.frame.width, height: posterImageView.frame.height))
			bigPosterImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: posterImageView.frame.width, height: posterImageView.frame.height))
			
			if let bigPosterImageView = bigPosterImageView, bigPosterScrollView = bigPosterScrollView, bigPosterBackView = bigPosterBackView {
				
				// set up UI elements
				
				bigPosterBackView.backgroundColor = UIColor.clearColor()
				
				bigPosterScrollView.minimumZoomScale = 1.0
				bigPosterScrollView.maximumZoomScale = 6.0
				bigPosterScrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height)
				bigPosterScrollView.delegate = self
				
				bigPosterImageView.contentMode = UIViewContentMode.ScaleAspectFit
				
				if let bitPoster = bigPoster {
					bigPosterImageView.image = bigPoster
				}
				else {
					bigPosterImageView.image = movie.thumbnailImage.0
				}
				
				bigPosterImageView.userInteractionEnabled = true
				bigPosterImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("bigPosterTapped:")))
				bigPosterScrollView.addSubview(bigPosterImageView)
				bigPosterBackView.addSubview(bigPosterScrollView)
				
				self.view.addSubview(bigPosterBackView)
				
				// animate it to a bigger poster
				
				navigationController.setNavigationBarHidden(true, animated: false)
				self.tabBarController?.tabBar.hidden = true
				posterImageTopSpaceConstraint.constant += navigationController.navigationBar.frame.height
				
				UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut,
					animations: {
						bigPosterBackView.backgroundColor = UIColor.blackColor()
						bigPosterScrollView.frame = bigPosterBackRect
						bigPosterImageView.frame = bigPosterBackRect
					},
					completion: { finished in
						
						if bigPoster != nil {
							// big poster already loaded, that's it
							return
						}

						// no big poster: load it!
						
						if (NetworkChecker.checkReachability(self.view) == false) {
							// no network available
							return
						}
						
						var database = BigPosterDatabase(recordType: Constants.RECORD_TYPE_USA)
						UIApplication.sharedApplication().networkActivityIndicatorVisible = true

						NetworkChecker.checkCloudKit(self.view, database: database, okCallback: { () -> () in
							
							// cloudkit is available, try to load the poster
							
							var spinnerBackground = UIView(frame: CGRect(x: bigPosterImageView.frame.width / 2 - 40, y: bigPosterImageView.frame.height / 2 - 40, width: 80, height: 80))
							spinnerBackground.backgroundColor = UIColor.blackColor()
							spinnerBackground.alpha = 0.6
							spinnerBackground.layer.cornerRadius = 6
							var spinner = UIActivityIndicatorView(frame: CGRect(x: 20, y: 20, width: 40, height: 40))
							spinnerBackground.addSubview(spinner)
							
							dispatch_async(dispatch_get_main_queue()) {
								spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
								spinner.hidesWhenStopped = true
								bigPosterImageView.addSubview(spinnerBackground)
								spinner.startAnimating()
							}
							
							database.downloadBigPoster(movie, finishCallback: { (error) -> () in
								
								// download is finished!
								
								UIApplication.sharedApplication().networkActivityIndicatorVisible = false
								
								dispatch_async(dispatch_get_main_queue()) {
									spinner.stopAnimating()
									spinnerBackground.removeFromSuperview()
								}
								
								// check if poster has been loaded
								bigPoster = movie.bigPoster
								
								if let bigPoster = bigPoster {
									dispatch_async(dispatch_get_main_queue()) {
										bigPosterImageView.image = bigPoster
									}
									return
								}

								// poster not loaded or error
								
								if let error = error {
									NSLog("Error getting big poster: \(error.code) (\(error.description))")
								}
								
								var errorWindow: MessageWindow?
								
								dispatch_async(dispatch_get_main_queue()) {
									errorWindow = MessageWindow(parent: bigPosterImageView, darkenBackground: true, titleStringId: "BigPosterErrorTitle", textStringId: "BigPosterErrorText", buttonStringId: "Close", handler: {
										errorWindow?.close()
									})
								}
							})
						})
						
					}
				)
			}
		}
	}
	
	
	/**
		Closes the enlarged poster.
	
		:param: recognizer	The gesture recognizer - unused.
	*/
	func bigPosterTapped(recognizer: UITapGestureRecognizer) {
		
		if let bigPosterImageView = bigPosterImageView, bigPosterScrollView = bigPosterScrollView, bigPosterBackView = bigPosterBackView, navigationController = navigationController {
			
			UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut,
				animations: {
					bigPosterBackView.backgroundColor = UIColor.clearColor()
					bigPosterImageView.frame = CGRect(x: self.posterImageView.frame.minX, y: self.posterImageView.frame.minY + self.totalBarHeight - navigationController.navigationBar.frame.height,
						width: self.posterImageView.frame.width, height: self.posterImageView.frame.height)
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