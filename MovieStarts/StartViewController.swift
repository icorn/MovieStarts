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

		database = Database(recordType: Constants.RECORD_TYPE_USA)
		
		if (database?.isDatabaseOnDevice() == true) {
			// the database is on the device: load movies
			loadDatabase()
		}
		else {
			// first start, no database on the device: this is the first start, say hello to the user
			
			welcomeWindow = MessageWindow(parent: view, darkenBackground: false, titleStringId: "WelcomeTitle", textStringId: "WelcomeText", buttonStringId: "WelcomeButton", handler: {

				if IJReachability.isConnectedToNetwork() == false {
					
					NSLog("Initial start: no network")
					
					var errorWindow: MessageWindow?

					dispatch_async(dispatch_get_main_queue()) {
						errorWindow = MessageWindow(parent: self.view, darkenBackground: true, titleStringId: "NoNetworkTitle", textStringId: "NoNetworkText", buttonStringId: "Close", handler: {
							errorWindow?.close()
						})
					}
					
					return
				}
				
				self.database?.checkCloudKit({ (status: CKAccountStatus, error: NSError!) -> () in
					
					var errorWindow: MessageWindow?
					
					switch status {
					case .Available:
						self.loadDatabase()
						
					case .NoAccount:
						NSLog("CloudKit error: no account")
						dispatch_async(dispatch_get_main_queue()) {
							errorWindow = MessageWindow(parent: self.view, darkenBackground: true, titleStringId: "iCloudError", textStringId: "iCloudNoAccount", buttonStringId: "Close", handler: {
								errorWindow?.close()
							})
						}

					case .Restricted:
						NSLog("CloudKit error: Restricted")
						dispatch_async(dispatch_get_main_queue()) {
							errorWindow = MessageWindow(parent: self.view, darkenBackground: true, titleStringId: "iCloudError", textStringId: "iCloudRestricted", buttonStringId: "Close", handler: {
								errorWindow?.close()
							})
						}
						
					case .CouldNotDetermine:
						NSLog("CloudKit error: CouldNotDetermine")
						dispatch_async(dispatch_get_main_queue()) {
							errorWindow = MessageWindow(parent: self.view, darkenBackground: true, titleStringId: "iCloudError", textStringId: "iCloudCouldNotDetermine", buttonStringId: "Close", handler: {
								errorWindow?.close()
							})
						}
					}
				})
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
				UIApplication.sharedApplication().networkActivityIndicatorVisible = false
				NSLog(errorMessage)
			},
			
			showIndicator: {
				welcomeWindow?.showProgressIndicator("0 " + NSLocalizedString("WelcomeProgress", comment: ""))
			},
			
			stopIndicator: { () in
				self.welcomeWindow?.close()
				self.welcomeWindow = nil
			},
			
			updateIndicator: { (counter: Int) in
				welcomeWindow?.updateProgressIndicator("\(counter) " + NSLocalizedString("WelcomeProgress", comment: ""))
			}
		)
	}
	
}
