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
	var progressView: UIProgressView?
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// show launch screen again
		
		var aboutViews = NSBundle.mainBundle().loadNibNamed("LaunchScreen", owner: self, options: nil)
		
		if ((aboutViews != nil) && (aboutViews?.count > 0) && (aboutViews?[0] != nil) && (aboutViews?[0] is UIView)) {
			aboutView = aboutViews![0] as? UIView
			aboutView!.frame = CGRect(origin: self.view.frame.origin, size: self.view.frame.size)
			self.view.addSubview(aboutViews![0] as UIView)
		}
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		// read movies from device or from cloud
		
		var database = Database(recordType: Constants.RECORD_TYPE_USA)
		
		database.getAllMovies(
			{ (movies: [MovieRecord]?) in
			
				// show the next view controller
			
				var newVC = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarController") as? TabBarController
			
				if let saveVC = newVC {
					saveVC.movies = movies
					self.presentViewController(saveVC, animated: true, completion: { () in
						if let saveAboutView = self.aboutView {
							saveAboutView.removeFromSuperview()
						}
					})
				}
			},
			
			errorHandler: { (errorMessage: String) in
				println(errorMessage)
			},
			
			showIndicator: startActivityIndicator,
			
			stopIndicator: { () in
				self.activityView?.removeFromSuperview()
				self.activityView = nil
			},
			
			updateIndicator: { (progress: Float) in
				if let saveProgressView = self.progressView {
					saveProgressView.setProgress(progress, animated: true)
				}
			}
		)
	}

	
	func startActivityIndicator(updating: Bool, showProgress: Bool) {
		
		var title = NSLocalizedString("LoadingMovies", comment: "")
		var viewHeight = 40
		
		if (updating) {
			title = NSLocalizedString("UpdatingMovies", comment: "")
		}
		
		if (showProgress) {
			viewHeight = 60
		}
		
		var labelWidth = (title as NSString).sizeWithAttributes([NSFontAttributeName : UIFont.systemFontOfSize(16)]).width
		var viewWidth = labelWidth + 60
		
		self.activityView = UIView(frame:
			CGRect(x: self.view.frame.width / 2 - viewWidth / 2, y: self.view.frame.height / 2 + 75, width: viewWidth, height: CGFloat(viewHeight)))
		self.activityView?.layer.cornerRadius = 15
		self.activityView?.backgroundColor = UIColor.blackColor()
		
		var spinner = UIActivityIndicatorView(frame: CGRect(x: 15, y: 10, width: 20, height: 20))
		spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
		spinner.startAnimating()
		
		var msg = UILabel(frame: CGRect(x: 45, y: 10, width: labelWidth, height: 20))
		msg.text = title
		msg.font = UIFont.systemFontOfSize(16)
		msg.textAlignment = NSTextAlignment.Center
		msg.textColor = UIColor.whiteColor()
		msg.backgroundColor = UIColor.clearColor()
		
		self.activityView?.opaque = false
		self.activityView?.backgroundColor = UIColor.blackColor()
		self.activityView?.addSubview(spinner)
		self.activityView?.addSubview(msg)
		self.view.addSubview(self.activityView!)
		
		if (showProgress) {
			self.progressView = UIProgressView(frame: CGRect(x: 15, y: 40, width: labelWidth + 30, height: 10))
			self.progressView!.progressViewStyle = UIProgressViewStyle.Bar
			self.progressView!.progressTintColor = UIColor.whiteColor()
			self.progressView!.trackTintColor = UIColor.grayColor()
			self.activityView!.addSubview(self.progressView!)
		}
	}


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

