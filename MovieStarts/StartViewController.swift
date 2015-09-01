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
	var activityView: UIView?
	var progressView: UILabel?
	
	
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

		var database = Database(recordType: Constants.RECORD_TYPE_USA)
		
		database.getAllMovies(
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
			
			showIndicator: startActivityIndicator,
			
			stopIndicator: { () in
				self.activityView?.removeFromSuperview()
				self.activityView = nil
			},
			
			updateIndicator: { (title: String) in
				if let progressView = self.progressView {
					dispatch_async(dispatch_get_main_queue()) {
						progressView.text = title
					}
				}
			}
		)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	
	// MARK: - 
	
	
	/**
		Opens a progress indicator view.
	*/
	func startActivityIndicator() {
		
		var title = NSLocalizedString("LoadingMovies", comment: "")
		var viewHeight = 40 // 60 with progress view
		
		var labelWidth = (title as NSString).sizeWithAttributes([NSFontAttributeName : UIFont.systemFontOfSize(16)]).width
		var viewWidth = labelWidth + 60
		
		activityView = UIView(frame: CGRect(x: self.view.frame.width / 2 - viewWidth / 2, y: self.view.frame.height / 2 + 75, width: viewWidth, height: CGFloat(viewHeight)))
		activityView?.layer.cornerRadius = 15
		activityView?.backgroundColor = UIColor.blackColor()
		
		var spinner = UIActivityIndicatorView(frame: CGRect(x: 15, y: 10, width: 20, height: 20))
		spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
		spinner.startAnimating()
		
		var msg = UILabel(frame: CGRect(x: 45, y: 10, width: labelWidth, height: 20))
		msg.text = title
		msg.font = UIFont.systemFontOfSize(16)
		msg.textAlignment = NSTextAlignment.Center
		msg.textColor = UIColor.whiteColor()
		msg.backgroundColor = UIColor.clearColor()
		
		activityView?.opaque = false
		activityView?.backgroundColor = UIColor.blackColor()
		activityView?.addSubview(spinner)
		activityView?.addSubview(msg)
		view.addSubview(self.activityView!)
		
		// progress views (currently unused)
		
/*
		progressView = UILabel(frame: CGRect(x: 15, y: 40, width: labelWidth + 30, height: 10))
		
		if let progressView = progressView {
			progressView.text = "..."
			progressView.textAlignment = NSTextAlignment.Center
			progressView.textColor = UIColor.whiteColor()
			progressView.font = UIFont.systemFontOfSize(14)
			activityView?.addSubview(progressView)
		}
*/
		
/*
		self.progressView = UIProgressView(frame: CGRect(x: 15, y: 40, width: labelWidth + 30, height: 10))
		self.progressView!.progressViewStyle = UIProgressViewStyle.Bar
		self.progressView!.progressTintColor = UIColor.whiteColor()
		self.progressView!.trackTintColor = UIColor.grayColor()
		self.activityView!.addSubview(self.progressView!)
*/
	}


}

