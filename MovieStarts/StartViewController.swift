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
	var movieDatabase: MovieDatabase?
	var welcomeWindow: MessageWindow?
	var myTabBarController: TabBarController?
	var thisIsTheFirstLaunch = true
	
	// MARK: - UIViewController
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// show launch screen again
		
		let aboutViews = NSBundle.mainBundle().loadNibNamed("LaunchScreen", owner: self, options: nil)
		
		if let aboutViews = aboutViews where (aboutViews.count > 0) && (aboutViews[0] is UIView) {
			aboutView = aboutViews[0] as? UIView
			
			if let aboutView = aboutView {
				aboutView.frame = CGRect(origin: self.view.frame.origin, size: self.view.frame.size)
				self.view.addSubview(aboutView)
			}
		}
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		// read movies from device or from cloud

		movieDatabase = MovieDatabase(recordType: Constants.dbRecordTypeMovie, viewForError: view)
		
		if (movieDatabase?.isDatabaseOnDevice() == true) {
			// the database is on the device: load movies
			thisIsTheFirstLaunch = false
			loadMovieDatabase()
		}
		else {
			// first start, no database on the device: this is the first start, say hello to the user
			
			thisIsTheFirstLaunch = true
			var countries = [MovieCountry.USA, MovieCountry.Germany, MovieCountry.England]
			var countryStringIds: [String] = []
			
			for country in countries {
				countryStringIds.append(country.welcomeStringId)
			}
			
			welcomeWindow = MessageWindow(parent: view, darkenBackground: false, titleStringId: "WelcomeTitle", textStringId: "WelcomeText", buttonStringIds: countryStringIds,
				handler: { (buttonIndex) -> () in
					// store selected country in preferences
					NSUserDefaults(suiteName: Constants.movieStartsGroup)?.setObject(countries[buttonIndex].rawValue, forKey: Constants.prefsCountry)
					NSUserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()

					// check network, load database if all is OK
//					if (NetworkChecker.checkReachability(self.view) == false) { return }

					guard let database = self.movieDatabase else { return }
					
					NetworkChecker.checkCloudKit(self.view, database: database,
						okCallback: { () -> () in
							self.loadMovieDatabase()
						},
						errorCallback: nil
					)
				}
			)
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	
	// MARK: - 


	/**
		Loads the movedatabase to memory from either a file (if it exists), or from the cloud.
	*/
	func loadMovieDatabase() {
		movieDatabase?.getAllMovies(
			{ [unowned self] (movies: [MovieRecord]?) in
				
				// show the next view controller
				
				UIApplication.sharedApplication().networkActivityIndicatorVisible = false
				self.myTabBarController = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarController") as? TabBarController
				
				if let tabBarController = self.myTabBarController, allMovies = movies {
					self.movieDatabase?.updateThumbnailHandler = tabBarController.updateThumbnailHandler
					
					// store movies in tabbarcontroller
					tabBarController.setUpMovies(allMovies)
					tabBarController.loadGenresFromFile()
					tabBarController.thisIsTheFirstLaunch = self.thisIsTheFirstLaunch

					// show tabbarcontroller
					
					self.presentViewController(tabBarController, animated: true, completion: { () in
						if let saveAboutView = self.aboutView {
							saveAboutView.removeFromSuperview()
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
			
			showIndicator: { [unowned self] () in
				self.welcomeWindow?.showProgressIndicator(NSLocalizedString("WelcomeDownloading", comment: ""))
			},
			
			stopIndicator: { [unowned self] () in
				self.welcomeWindow?.hideProgressIndicator()
			},
			
			updateIndicator: { [unowned self] (counter: Int) in
				self.welcomeWindow?.updateProgressIndicator("\(counter) " + NSLocalizedString("WelcomeProgress", comment: ""))
			},
			
			finishHandler: { [unowned self] () in
				dispatch_async(dispatch_get_main_queue()) {
					self.welcomeWindow?.close()
					self.welcomeWindow = nil
				}
			}
		)
	}
	
}
