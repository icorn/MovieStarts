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
	var movieDatabaseLoader: MovieDatabaseLoader?
	var welcomeWindow: MessageWindow?
	var myTabBarController: TabBarController?
	var thisIsTheFirstLaunch = true
	
	// MARK: - UIViewController
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// show launch screen again
		
		let aboutViews = Bundle.main.loadNibNamed("LaunchScreen", owner: self, options: nil)
		
		if let aboutViews = aboutViews , (aboutViews.count > 0) && (aboutViews[0] is UIView) {
			aboutView = aboutViews[0] as? UIView
			
			if let aboutView = aboutView {
				aboutView.frame = CGRect(origin: self.view.frame.origin, size: self.view.frame.size)
				self.view.addSubview(aboutView)
			}
		}
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// read movies from device or from cloud

		self.movieDatabaseLoader = MovieDatabaseLoader(recordType: Constants.dbRecordTypeMovie, viewForError: view)
		
		if (movieDatabaseLoader?.isDatabaseOnDevice() == true) {
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
					UserDefaults(suiteName: Constants.movieStartsGroup)?.set(countries[buttonIndex].rawValue, forKey: Constants.prefsCountry)
					UserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()

					// check network, load database if all is OK
//					if (NetworkChecker.checkReachability(self.view) == false) { return }

					guard let database = self.movieDatabaseLoader else { return }
					
					NetworkChecker.checkCloudKit(viewForError: self.view, database: database,
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
		movieDatabaseLoader?.getAllMovies(
			completionHandler: { [unowned self] (movies: [MovieRecord]?) in
				
				// show the next view controller
				
                DispatchQueue.main.async
                {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                
				self.myTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as? TabBarController
				
				if let tabBarController = self.myTabBarController, let allMovies = movies {
					self.movieDatabaseLoader?.updateThumbnailHandler = tabBarController.updateThumbnailHandler
					
					// store movies in tabbarcontroller
					tabBarController.setUpMovies(allMovies)
					tabBarController.loadGenresFromFile()
					tabBarController.thisIsTheFirstLaunch = self.thisIsTheFirstLaunch

					// show tabbarcontroller
					
					self.present(tabBarController, animated: true, completion: { () in
						if let saveAboutView = self.aboutView {
							saveAboutView.removeFromSuperview()
						}
					})
					
					// iOS bug: Sometimes the main runloop doesn't wake up!
					// To wake it up, enqueue an empty block into the main runloop.
					
					DispatchQueue.main.async {}
				}
			},
			
			errorHandler: { (errorMessage: String) in
				DispatchQueue.main.async
                {
					UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
				DispatchQueue.main.async {
					self.welcomeWindow?.close()
					self.welcomeWindow = nil
				}
			}
		)
	}
	
}
