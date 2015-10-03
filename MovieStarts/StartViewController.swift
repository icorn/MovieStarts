//
//  StartViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 24.02.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit
import CloudKit


class StartViewController: UIViewController {
	
	var aboutView: UIView?
	var database: Database?
	var welcomeWindow: MessageWindow?

	
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

		database = Database(recordType: Constants.RECORD_TYPE_USA, viewForError: view)
		
		if (database?.isDatabaseOnDevice() == true) {
			// the database is on the device: load movies
			loadDatabase()
		}
		else {
			// first start, no database on the device: this is the first start, say hello to the user
			
			welcomeWindow = MessageWindow(parent: view, darkenBackground: false, titleStringId: "WelcomeTitle", textStringId: "WelcomeText", buttonStringId: "WelcomeButton", handler: {

				if (NetworkChecker.checkReachability(self.view) == false) {
					return
				}

				if let database = self.database {
					NetworkChecker.checkCloudKit(self.view, database: database, okCallback: { () -> () in
						self.loadDatabase()
					}, errorCallback: nil)
				}
			})
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
							tabBarController.updateMovies(allMovies, database: self.database)
						}
					})
					
					// iOS bug: Sometimes the main runloop doesn't wake up!
					// To wake it up, enqueue an empty block into the main runloop.
					
					dispatch_async(dispatch_get_main_queue()) {}
				}
			},
			
			errorHandler: { (errorMessage: String) in
				dispatch_async(dispatch_get_main_queue()) {
					UIApplication.sharedApplication().networkActivityIndicatorVisible = false
					NSLog(errorMessage)
				}
			},
			
			showIndicator: {
				dispatch_async(dispatch_get_main_queue()) {
					self.welcomeWindow?.showProgressIndicator(NSLocalizedString("WelcomeDownloading", comment: ""))
				}
			},
			
			stopIndicator: {
				dispatch_async(dispatch_get_main_queue()) {
					self.welcomeWindow?.hideProgressIndicator()
				}
			},
			
			updateIndicator: { (counter: Int) in
				dispatch_async(dispatch_get_main_queue()) {
					self.welcomeWindow?.updateProgressIndicator("\(counter) " + NSLocalizedString("WelcomeProgress", comment: ""))
				}
			},
			
			finishHandler: {
				dispatch_async(dispatch_get_main_queue()) {
					self.welcomeWindow?.close()
					self.welcomeWindow = nil
				}
			}
		)
	}
	
}
