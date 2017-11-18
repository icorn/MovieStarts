//
//  MovieViewControllerPosters.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 20.09.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation
import UIKit
import CFNetwork


extension MovieViewController {
	
	/**
		Enlarges the tapped thumbnail poster.
	
		- parameter recognizer:	The gesture recognizer - unused.
	*/
	@objc func thumbnailTapped(_ recognizer: UITapGestureRecognizer) {

		if let movie = movie, let navigationController = navigationController {
			let bigPoster = movie.bigPoster
			
			// create poster background, scrollview, and imageview
			
			bigPosterBackView = UIView()
			bigPosterScrollView = UIScrollView()
			bigPosterImageView = UIImageView()
			
			spinnerBackground = UIView()
			spinner = UIActivityIndicatorView()

			if let bigPosterImageView = bigPosterImageView, let bigPosterScrollView = bigPosterScrollView, let bigPosterBackView = bigPosterBackView, let spinnerBackground = self.spinnerBackground, let spinner = self.spinner {

				// set up UI elements
				
				bigPosterBackView.backgroundColor = UIColor.clear
				bigPosterBackView.translatesAutoresizingMaskIntoConstraints = false

				bigPosterScrollView.minimumZoomScale = 1.0
				bigPosterScrollView.maximumZoomScale = 6.0
				bigPosterScrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height)
				bigPosterScrollView.delegate = self
				bigPosterScrollView.translatesAutoresizingMaskIntoConstraints = false
				
				bigPosterImageView.contentMode = UIViewContentMode.scaleAspectFit
				bigPosterImageView.translatesAutoresizingMaskIntoConstraints = false
				bigPosterImageView.isUserInteractionEnabled = true
				bigPosterImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MovieViewController.bigPosterTapped(_:))))
				
				if let bigPoster = bigPoster {
					bigPosterImageView.image = bigPoster
				}
				else {
					bigPosterImageView.image = movie.thumbnailImage.0
				}
				
				spinnerBackground.translatesAutoresizingMaskIntoConstraints = false
				spinnerBackground.backgroundColor = UIColor.black
				spinnerBackground.alpha = 0.6
				spinnerBackground.layer.cornerRadius = 6
				spinnerBackground.isHidden = true
				
				spinner.translatesAutoresizingMaskIntoConstraints = false
				spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
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

				self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[bigPosterBackView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary))
				self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[bigPosterBackView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary))
				bigPosterBackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[bigPosterScrollView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary))
				bigPosterBackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[bigPosterScrollView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary))
				
				posterImageViewTopConstraint = NSLayoutConstraint(item: bigPosterImageView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal,
					toItem: bigPosterScrollView, attribute: NSLayoutAttribute.top, multiplier: 1.0,
					constant: posterImageView.frame.minY + navigationController.navigationBar.frame.height + navigationController.navigationBar.frame.origin.y)
				posterImageViewLeadingConstraint = NSLayoutConstraint(item: bigPosterImageView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal,
					toItem: bigPosterScrollView, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: posterImageView.frame.minX)
				posterImageViewWidthConstraint = NSLayoutConstraint(item: bigPosterImageView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal,
					toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: posterImageView.frame.width)
				posterImageViewHeightConstraint = NSLayoutConstraint(item: bigPosterImageView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal,
					toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: posterImageView.frame.height)
				
				bigPosterImageView.addConstraints([
					NSLayoutConstraint(item: spinnerBackground, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal,
						toItem: bigPosterImageView, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0),
					NSLayoutConstraint(item: spinnerBackground, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal,
						toItem: bigPosterImageView,	attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0),
					NSLayoutConstraint(item: spinnerBackground, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal,
						toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 80),
					NSLayoutConstraint(item: spinnerBackground, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal,
						toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 80)
				])
				spinnerBackground.addConstraints([
					NSLayoutConstraint(item: spinner, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal,
						toItem: spinnerBackground, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0),
					NSLayoutConstraint(item: spinner, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal,
						toItem: spinnerBackground, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0)
				])
				
				if let imageViewTopConstraint = posterImageViewTopConstraint, let imageViewLeadingConstraint = posterImageViewLeadingConstraint,
					let imageViewWidthConstraint = posterImageViewWidthConstraint, let imageViewHeightConstraint = posterImageViewHeightConstraint
				{
					bigPosterScrollView.addConstraints([imageViewTopConstraint, imageViewLeadingConstraint, imageViewWidthConstraint, imageViewHeightConstraint])
				
					// animate it to a bigger poster
					
					navigationController.setNavigationBarHidden(true, animated: false)
					self.tabBarController?.tabBar.isHidden = true
					posterImageTopSpaceConstraint.constant += navigationController.navigationBar.frame.height
					view.layoutIfNeeded()

					UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut,
						animations: {
							bigPosterBackView.backgroundColor = UIColor.black
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
							UIApplication.shared.isNetworkActivityIndicatorVisible = true
							DispatchQueue.main.async {
								self.spinnerBackground?.isHidden = false
								self.spinner?.startAnimating()
							}
							
							// no big poster here: load it!
/*
							if (NetworkChecker.checkReachability(self.view) == false) {
								// no network available
								self.stopSpinners()
								return
							}
*/
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
		
		guard let bigPosterImageView = bigPosterImageView, let movie = movie else {
			stopSpinners()
			return
		}
		
		var errorWindow: MessageWindow?

		// build paths
		guard let targetPath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.movieStartsGroup)?.path else {
			stopSpinners()
			return
		}
		
		let sourcePath = Constants.imageBaseUrl + PosterSizePath.Big.rawValue
		var posterUrl = movie.posterUrl[movie.currentCountry.languageArrayIndex]
		
		if (posterUrl.count == 0) {
			// if there is no poster in wanted language, try the english one
			posterUrl = movie.posterUrl[MovieCountry.USA.languageArrayIndex]
		}
		
		if (posterUrl.count <= 0) {
			stopSpinners()
			return
		}
		
		// poster file is missing
		
		guard let sourceUrl = URL(string: sourcePath + posterUrl) else {
			stopSpinners()
			return
		}
		
		// configure download task
		
		let config = URLSessionConfiguration.default
		config.allowsCellularAccess = true
		config.timeoutIntervalForRequest = 10
		config.timeoutIntervalForResource = 10
		
		let session = URLSession(configuration: config)
		
		// start the download
		let task = session.downloadTask(with: sourceUrl,
		                                completionHandler: { (location: URL?, response: URLResponse?, error: Error?) -> Void in
			self.stopSpinners()
			
			if let error = error as NSError? {
				NSLog("Error getting missing thumbnail: \(error.localizedDescription)")
				
				if (Int32(error.code) == CFNetworkErrors.cfurlErrorTimedOut.rawValue) {
					DispatchQueue.main.async {
						errorWindow = MessageWindow(parent: bigPosterImageView, darkenBackground: true, titleStringId: "BigPosterErrorTitle", textStringId: "BigPosterTimeOut", buttonStringIds: ["Close"], handler: { (buttonIndex) -> () in
							errorWindow?.close()
						})
					}
				}
				else {
					DispatchQueue.main.async {
						errorWindow = MessageWindow(parent: bigPosterImageView, darkenBackground: true, titleStringId: "BigPosterErrorTitle", textStringId: "BigPosterErrorText", buttonStringIds: ["Close"], handler: { (buttonIndex) -> () in
							errorWindow?.close()
						})
					}
				}
			}
			else if let receivedPath = location?.path {
				// move received poster to target path where it belongs
				do {
					try FileManager.default.moveItem(atPath: receivedPath, toPath: targetPath + Constants.bigPosterFolder + posterUrl)
				}
				catch let error as NSError {
					if ((error.domain == NSCocoaErrorDomain) && (error.code == NSFileWriteFileExistsError)) {
						// ignoring, because it's okay it it's already there
					}
					else {
						NSLog("Error moving missing poster: \(error.localizedDescription)")

						DispatchQueue.main.async {
							errorWindow = MessageWindow(parent: bigPosterImageView, darkenBackground: true, titleStringId: "BigPosterErrorTitle", textStringId: "BigPosterErrorText", buttonStringIds: ["Close"], handler: { (buttonIndex) -> () in
								errorWindow?.close()
							})
						}
						return
					}
				}

				// load and show poster
				if let bigPoster = movie.bigPoster {
					DispatchQueue.main.async {
						bigPosterImageView.image = bigPoster
					}
					return
				}

				// poster not loaded or error
				if let error = error as NSError? {
					NSLog("Error getting big poster: \(error.code) (\(error.localizedDescription))")
				}

				DispatchQueue.main.async {
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
	fileprivate func stopSpinners() {
		DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
			self.spinner?.stopAnimating()
			self.spinnerBackground?.removeFromSuperview()
		}
	}
	
	/**
		Closes the enlarged poster.
	
		- parameter recognizer:	The gesture recognizer - unused.
	*/
	@objc func bigPosterTapped(_ recognizer: UITapGestureRecognizer) {
		
		if let bigPosterImageView = bigPosterImageView, let bigPosterScrollView = bigPosterScrollView, let bigPosterBackView = bigPosterBackView, let navigationController = navigationController {
			
			self.spinner?.stopAnimating()
			self.spinnerBackground?.removeFromSuperview()

			UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut,
				animations: {
					bigPosterBackView.backgroundColor = UIColor.clear
					self.posterImageViewTopConstraint?.constant = self.posterImageView.frame.minY + navigationController.navigationBar.frame.height + navigationController.navigationBar.frame.origin.y + self.posterImageView.frame.height/2
					self.posterImageViewLeadingConstraint?.constant = self.posterImageView.frame.minX + self.posterImageView.frame.width/2
					self.posterImageViewHeightConstraint?.constant = 1
					self.posterImageViewWidthConstraint?.constant = 1
					self.view.layoutIfNeeded()
				},
				completion: { finished in
					navigationController.setNavigationBarHidden(false, animated: false)
					self.tabBarController?.tabBar.isHidden = false
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
	
	@objc(viewForZoomingInScrollView:) func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return bigPosterImageView
	}
	
}
