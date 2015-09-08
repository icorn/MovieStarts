//
//  StartViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 24.02.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
	
	var aboutView: UIView?
	var database: Database?

	var welcomeView: UIView?
	var welcomeLogoImageView: UIImageView?
	var welcomeButton: UIButton?
	var welcomeProgressLabel: UILabel?
	var welcomeSpinner: UIActivityIndicatorView?
	
	
	// MARK: - UIViewController
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// show launch screen again
		
		var aboutViews = NSBundle.mainBundle().loadNibNamed("LaunchScreen", owner: self, options: nil)
		
		if ((aboutViews != nil) && (aboutViews?.count > 0) && (aboutViews?[0] != nil) && (aboutViews?[0] is UIView)) {
			aboutView = aboutViews![0] as? UIView
			aboutView!.frame = CGRect(origin: self.view.frame.origin, size: self.view.frame.size)
			self.view.addSubview(aboutViews![0] as! UIView)
		}
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		// read movies from device or from cloud

		database = Database(recordType: Constants.RECORD_TYPE_USA)
		
		if (database?.isDatabaseOnDevice() == true) {
			// the database is on the device: load movies
			loadDatabase()
		}
		else {
			// no database on the device: this is the first start, say hello to the user
			showWelcomeView()
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	
	// MARK: - 
	

	func loadDatabase() {
		database?.getAllMovies(
			{ (movies: [MovieRecord]?) in
				
				// show the next view controller
				
				UIApplication.sharedApplication().networkActivityIndicatorVisible = false
				var tabBarController = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarController") as? TabBarController
				
				if let tabBarController = tabBarController, allMovies = movies {
					
					// store movies in tabbarcontroller
					tabBarController.setUpMovies(allMovies)
					
					// show tabbarcontroller
					
					self.presentViewController(tabBarController, animated: true, completion: { () in
						if let saveAboutView = self.aboutView {
							saveAboutView.removeFromSuperview()
							tabBarController.updateMovies(allMovies)
						}
					})
					
					// iOS bug: Sometimes the main runloop doesn't wake up!
					// To wake it up, enqueue an empty block into the main runloop.
					
					dispatch_async(dispatch_get_main_queue()) {}
				}
			},
			
			errorHandler: { (errorMessage: String) in
				UIApplication.sharedApplication().networkActivityIndicatorVisible = false
				println(errorMessage)
			},
			
			showIndicator: {
				if let welcomeButton = self.welcomeButton, welcomeView = self.welcomeView {
					welcomeButton.hidden = true
					
					self.welcomeSpinner = UIActivityIndicatorView(frame: CGRect(x: 40, y: welcomeButton.frame.minY + 5, width: 20, height: 20))
					
					if let welcomeSpinner = self.welcomeSpinner {
						welcomeSpinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
						welcomeSpinner.startAnimating()
						welcomeView.addSubview(welcomeSpinner)
						
						self.welcomeProgressLabel = UILabel(frame: CGRect(x: welcomeSpinner.frame.maxX + 10, y: welcomeSpinner.frame.minY, width: 100, height: 30))
						
						if let welcomeProgressLabel = self.welcomeProgressLabel {
							welcomeProgressLabel.text = "0 " + NSLocalizedString("WelcomeProgress", comment: "")
							welcomeProgressLabel.font = UIFont.systemFontOfSize(16)
							welcomeProgressLabel.textAlignment = NSTextAlignment.Left
							welcomeProgressLabel.textColor = UIColor.grayColor()
							welcomeProgressLabel.backgroundColor = UIColor.clearColor()
							welcomeProgressLabel.sizeToFit()
							welcomeView.addSubview(welcomeProgressLabel)

							self.centerProgress()
						}
					}
				}
			},
			
			stopIndicator: { () in
				self.welcomeButton?.removeFromSuperview()
				self.welcomeView?.removeFromSuperview()
				self.welcomeButton = nil
				self.welcomeView = nil
			},
			
			updateIndicator: { (counter: Int) in
				if let welcomeProgressLabel = self.welcomeProgressLabel {
					dispatch_async(dispatch_get_main_queue()) {
						welcomeProgressLabel.text = "\(counter) " + NSLocalizedString("WelcomeProgress", comment: "")
						welcomeProgressLabel.sizeToFit()
						self.centerProgress()
					}
				}
			}
		)
	}
	

	/**
		Shows the welcome screen to the new user.
	*/
	func showWelcomeView() {
		
		var viewWidth: CGFloat  = 280
		var viewHeight: CGFloat = 260
		var bodyInset: CGFloat	= 15
		
		welcomeView = UIView(frame: CGRect(x: self.view.frame.width / 2 - viewWidth / 2, y: self.view.frame.height / 2 - viewHeight / 2, width: viewWidth, height: viewHeight))
		
		if let welcomeView = welcomeView {
			welcomeView.layer.cornerRadius = 6
			welcomeView.backgroundColor = UIColor.whiteColor()
			welcomeView.opaque = false

			// title view
			var title = UILabel(frame: CGRect(x: 0, y: 40, width: viewWidth, height: 20))
			title.text = NSLocalizedString("WelcomeTitle", comment: "")
			title.font = UIFont.systemFontOfSize(24)
			title.textAlignment = NSTextAlignment.Center
			title.textColor = UIColor.blackColor()
			title.backgroundColor = UIColor.clearColor()
			welcomeView.addSubview(title)

			// message text
			var msg = UILabel(frame: CGRect(x: bodyInset, y: title.frame.maxY + 10, width: viewWidth - 2 * bodyInset, height: 150))
			msg.text = NSLocalizedString("WelcomeText", comment: "")
			msg.font = UIFont.systemFontOfSize(16)
			msg.textAlignment = NSTextAlignment.Center
			msg.textColor = UIColor.blackColor()
			msg.backgroundColor = UIColor.clearColor()
			msg.numberOfLines = 0
			msg.sizeToFit()
			welcomeView.addSubview(msg)
			
			// button
			welcomeButton = UIButton(frame: CGRect(x: 0, y: msg.frame.maxY + 20, width: viewWidth, height: 30))
			
			if let welcomeButton = welcomeButton {
				welcomeButton.setTitle(NSLocalizedString("WelcomeButton", comment: ""), forState: UIControlState.Normal)
				welcomeButton.setTitleColor(UIColor(red: 0.0, green: 170.0/255.0, blue: 170.0/255.0, alpha: 1.0), forState: UIControlState.Normal)
				welcomeButton.setTitleColor(UIColor(red: 0.0, green: 120.0/255.0, blue: 120.0/255.0, alpha: 1.0), forState: UIControlState.Highlighted)
				welcomeButton.addTarget(self, action: Selector("loadDatabase"), forControlEvents: UIControlEvents.TouchUpInside)
				welcomeView.addSubview(welcomeButton)
				
				// resize the view depending on the height of the content
				welcomeView.frame = CGRect(x: welcomeView.frame.minX, y: welcomeView.frame.minY, width: viewWidth, height: welcomeButton.frame.maxY + 20)
			}
			
			// the nice logo
			var logoImage = UIImage(named: "welcome")
			if let logoImage = logoImage {
				welcomeLogoImageView = UIImageView(frame: CGRect(x: self.view.frame.width / 2 - logoImage.size.width / 2, y: welcomeView.frame.minY - logoImage.size.height / 2,
					width: logoImage.size.width, height: logoImage.size.height))
				welcomeLogoImageView?.image = logoImage
			}
			view.addSubview(welcomeView)
			
			if let welcomeLogoImageView = welcomeLogoImageView {
				view.addSubview(welcomeLogoImageView)
			}
		}
	}
	
	
	private func centerProgress() {
		// center both the spinner and the label
		if let welcomeProgressLabel = welcomeProgressLabel, welcomeSpinner = welcomeSpinner, welcomeView = welcomeView {
			var progressWidth = 20 + 10 + welcomeProgressLabel.frame.width
			var newProgressX = (welcomeView.frame.width - progressWidth) / 2
			welcomeSpinner.frame = CGRect(x: newProgressX, y: welcomeSpinner.frame.minY, width: welcomeSpinner.frame.width, height: welcomeSpinner.frame.height)
			welcomeProgressLabel.frame = CGRect(x: welcomeSpinner.frame.maxX + 10, y: welcomeProgressLabel.frame.minY, width: welcomeProgressLabel.frame.width, height: welcomeProgressLabel.frame.height)
		}
	}
}

