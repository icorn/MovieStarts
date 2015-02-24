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
		
		database.getAllMovies(self.view,
			{ (movies: [MovieRecord]?) in
				
				// we have the movies: show the next view controller
				
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
			}
		)
	}
	
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
