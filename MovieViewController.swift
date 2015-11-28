//
//  MovieViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 14.05.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit
import SafariServices


class MovieViewController: UIViewController, UIScrollViewDelegate, SFSafariViewControllerDelegate {

	// outlets
	
	@IBOutlet weak var contentView: UIView!
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var posterImageView: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var subtitleText1: UILabel!
	@IBOutlet weak var subtitleText2: UILabel!
	@IBOutlet weak var subtitleText3: UILabel!
	@IBOutlet weak var releaseDateHeadlineLabel: UILabel!
	@IBOutlet weak var releaseDateLabel: UILabel!
	@IBOutlet weak var ratingHeadlineLabel: UILabel!
	@IBOutlet weak var ratingLabel: UILabel!
	@IBOutlet weak var directorHeadlineLabel: UILabel!
	@IBOutlet weak var directorLabel: UILabel!
	@IBOutlet weak var directorLabel2: UILabel!
	@IBOutlet weak var actorHeadlineLabel: UILabel!
	@IBOutlet weak var actorLabel1: UILabel!
	@IBOutlet weak var actorLabel2: UILabel!
	@IBOutlet weak var actorLabel3: UILabel!
	@IBOutlet weak var actorLabel4: UILabel!
	@IBOutlet weak var actorLabel5: UILabel!
	@IBOutlet weak var storyHeadlineLabel: UILabel!
	@IBOutlet weak var storyLabel: UILabel!
	@IBOutlet weak var textButton1: UIButton!
	@IBOutlet weak var textButton2: UIButton!
	@IBOutlet weak var textButton3: UIButton!
	@IBOutlet weak var textButton4: UIButton!
	@IBOutlet weak var textButton5: UIButton!
	
	@IBOutlet weak var line6: UIView!
	@IBOutlet weak var line7: UIView!
	@IBOutlet weak var line8: UIView!
	@IBOutlet weak var line9: UIView!
	@IBOutlet weak var line10: UIView!
	
	@IBOutlet weak var starsgrey: UIImageView!
	@IBOutlet weak var starsgold: UIImageView!
	
	// constraints
	
	@IBOutlet weak var posterImageTopSpaceConstraint: NSLayoutConstraint!
	@IBOutlet weak var directorHeadlineLabelHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var line1bHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var line1bVerticalSpaceConstraint: NSLayoutConstraint!
	@IBOutlet weak var line2HeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var line2VerticalSpaceConstraint: NSLayoutConstraint!
	@IBOutlet weak var line3HeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var line3VerticalSpaceConstraint: NSLayoutConstraint!
	@IBOutlet weak var line4HeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var line4VerticalSpaceConstraint: NSLayoutConstraint!

	@IBOutlet weak var directorHeadlineLabelVerticalSpaceConstraint: NSLayoutConstraint!
	@IBOutlet weak var directorLabelHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var directorLabel2HeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var directorLabelVerticalSpaceConstraint: NSLayoutConstraint!
	@IBOutlet weak var directorLabel2VerticalSpaceConstraint: NSLayoutConstraint!

	@IBOutlet weak var actorHeadlineLabelVerticalSpaceConstraint: NSLayoutConstraint!
	@IBOutlet weak var actorHeadlineLabelHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var actorLabel1VerticalSpaceConstraint: NSLayoutConstraint!
	@IBOutlet weak var actorLabel2VerticalSpaceConstraint: NSLayoutConstraint!
	@IBOutlet weak var actorLabel3VerticalSpaceConstraint: NSLayoutConstraint!
	@IBOutlet weak var actorLabel4VerticalSpaceConstraint: NSLayoutConstraint!
	@IBOutlet weak var actorLabel5VerticalSpaceConstraint: NSLayoutConstraint!
	@IBOutlet weak var actorLabel1HeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var actorLabel2HeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var actorLabel3HeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var actorLabel4HeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var actorLabel5HeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var titleLabelTopSpaceConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var starsgoldWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var starsgreyWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var starsgoldHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var starsgoldTrailingConstraint: NSLayoutConstraint!
	@IBOutlet weak var starsgreyHeightConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var ratingLabelHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var ratingHeadlineLabelHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var ratingHeadlineLabelTopConstraint: NSLayoutConstraint!
	@IBOutlet weak var ratingLabelTopConstraint: NSLayoutConstraint!
	
	var posterImageViewTopConstraint: NSLayoutConstraint?
	var posterImageViewLeadingConstraint: NSLayoutConstraint?
	var posterImageViewWidthConstraint: NSLayoutConstraint?
	var posterImageViewHeightConstraint: NSLayoutConstraint?
	
	var movieTabBarController: TabBarController? {
		get {
			return navigationController?.parentViewController as? TabBarController
		}
	}

	var bigPosterBackView: UIView?
	var bigPosterImageView: UIImageView?
	var bigPosterScrollView: UIScrollView?

	var spinnerBackground: UIView?
	var spinner: UIActivityIndicatorView?

	var movie: MovieRecord?
	var textButtons = [UIButton]()
	

	// MARK: - UIViewController
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// start to show all movie details

		var actorLabels = [actorLabel1, actorLabel2, actorLabel3, actorLabel4, actorLabel5]
		var directorLabels = [directorLabel, directorLabel2]
		
		if let movie = movie {
			
			// show poster
			
			posterImageView.image = movie.thumbnailImage.0

			if (movie.thumbnailImage.1) {
				let rec = UITapGestureRecognizer(target: self, action: Selector("thumbnailTapped:"))
				rec.numberOfTapsRequired = 1
				posterImageView.addGestureRecognizer(rec)
			}

			// fill labels
			
			titleLabel?.text = movie.title[movie.currentCountry.languageArrayIndex]

			// show labels with subtitles
			
			var subtitleLabels = [subtitleText1, subtitleText2, subtitleText3]
			
			for (index, subtitle) in movie.subtitleArray.enumerate() {
				subtitleLabels[index]?.text = subtitle
			}
			
			// hide unused labels
			
			for (var index = movie.subtitleArray.count; index < subtitleLabels.count; index++) {
				subtitleLabels[index]?.hidden = true
			}

			// vertically "center" the labels
			let moveY = (subtitleLabels.count - movie.subtitleArray.count) * 19
			titleLabelTopSpaceConstraint.constant = CGFloat(moveY / 2) * -1 + 4

			// show release date
			
			releaseDateHeadlineLabel.text = NSLocalizedString("ReleaseDate", comment: "") + ":"
			
			if (movie.releaseDate[movie.currentCountry.countryArrayIndex].compare(NSDate(timeIntervalSince1970: 0)) == NSComparisonResult.OrderedDescending) {
				releaseDateLabel?.text = movie.releaseDateString
			}
			else {
				// no release date (cannot happen)
				releaseDateLabel?.text = "-"
			}
			
			// show rating
			
			ratingHeadlineLabel.text = NSLocalizedString("UserRating", comment: "") + ":"
			if (movie.voteCount > 2) {
				let numberFormatter = NSNumberFormatter()
				numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
				numberFormatter.minimumFractionDigits = 1

				let voteAverage = numberFormatter.stringFromNumber(movie.voteAverage)

				if let saveVoteAverage = voteAverage {
					ratingLabel?.text =  "\(saveVoteAverage)"
				}
				else {
					// vote was no number, shouldn't happen
					ratingLabel?.text = "?"
				}
				
				starsgoldWidthConstraint.constant = 0
				starsgoldTrailingConstraint.constant = 150
			}
			else {
				// no or not enough votes, hide it
				
				ratingHeadlineLabelHeightConstraint.constant = 0
				ratingLabelHeightConstraint.constant = 0
				starsgoldHeightConstraint.constant = 0
				starsgreyHeightConstraint.constant = 0
				line2VerticalSpaceConstraint.constant = 0
				line2HeightConstraint.constant = 0
				ratingLabelTopConstraint.constant = 0
				ratingHeadlineLabelTopConstraint.constant = 0
			}
			
			// show director(s)

			directorHeadlineLabel.text = NSLocalizedString("Director", comment: "") + ":"
			if (movie.directors.count > 1) {
				directorHeadlineLabel.text = NSLocalizedString("Directors", comment: "") + ":"
			}
			
			if (movie.directors.count > 0) {
				for index in 0...movie.directors.count-1 {
					if (index < 2) {
						directorLabels[index].text = movie.directors[index]
					}
				}
			}
			
			// hide unused director-fields
			
			if (movie.directors.count < 2) {
				setConstraintsToZero(directorLabel2HeightConstraint, directorLabel2VerticalSpaceConstraint)
			}
			if (movie.directors.count < 1) {
				setConstraintsToZero(directorLabelHeightConstraint, directorLabelVerticalSpaceConstraint, directorHeadlineLabelHeightConstraint,
					directorHeadlineLabelVerticalSpaceConstraint, line2HeightConstraint, line2VerticalSpaceConstraint, line1bHeightConstraint, line1bVerticalSpaceConstraint)
			}
			
			// show actor(s)
			
			actorHeadlineLabel.text = NSLocalizedString("Actors", comment: "") + ":"
			if (movie.actors.count > 0) {
				for index in 0...movie.actors.count-1 {
					if (index < 5) {
						actorLabels[index].text = movie.actors[index]
					}
				}
			}
			
			// hide unused actor-fields
			
			if (movie.actors.count < 5) {
				setConstraintsToZero(actorLabel5HeightConstraint, actorLabel5VerticalSpaceConstraint)
			}
			if (movie.actors.count < 4) {
				setConstraintsToZero(actorLabel4HeightConstraint, actorLabel4VerticalSpaceConstraint)
			}
			if (movie.actors.count < 3) {
				setConstraintsToZero(actorLabel3HeightConstraint, actorLabel3VerticalSpaceConstraint)
			}
			if (movie.actors.count < 2) {
				setConstraintsToZero(actorLabel2HeightConstraint, actorLabel2VerticalSpaceConstraint)
			}
			if (movie.actors.count < 1) {
				setConstraintsToZero(actorLabel1HeightConstraint, actorLabel1VerticalSpaceConstraint, actorHeadlineLabelHeightConstraint,
					actorHeadlineLabelVerticalSpaceConstraint, line3HeightConstraint, line3VerticalSpaceConstraint)
			}
			
			// show synopsis
			
			let synopsisForLanguage = movie.synopsisForLanguage
			storyHeadlineLabel.text = NSLocalizedString("Synopsis", comment: "") + ":"

			if (synopsisForLanguage.0.characters.count > 0) {
				storyLabel.text = synopsisForLanguage.0
				
				if (synopsisForLanguage.1 != movie.currentCountry.languageArrayIndex) {
					// synopsis is english as fallback
					storyHeadlineLabel.text = NSLocalizedString("SynopsisEnglish", comment: "") + ":"
				}
			}
			else {
				storyLabel.text = NSLocalizedString("NoSynopsis", comment: "")
			}

			// show textbuttons for imdb and trailers
			
			textButtons = [textButton1, textButton2, textButton3, textButton4, textButton5]
			var textButtonIndex = 0
			var buttonLines = [line6, line7, line8, line9, line10]
			
			if (movie.imdbId != nil) {
				textButtons[textButtonIndex].addTarget(self, action: Selector("imdbButtonTapped:"), forControlEvents: UIControlEvents.TouchUpInside)
				textButtons[textButtonIndex].setTitle(NSLocalizedString("ShowOnImdb", comment: ""), forState: UIControlState.Normal)
				textButtonIndex++
			}
			
			for trailerName in movie.trailerNames[movie.currentCountry.languageArrayIndex] {
				if (textButtonIndex < textButtons.count) {
					textButtons[textButtonIndex].addTarget(self, action: Selector("trailerButtonTapped:"), forControlEvents: UIControlEvents.TouchUpInside)
					textButtons[textButtonIndex].setTitle(NSLocalizedString("ShowTrailer", comment: "") + "'" + trailerName + "'", forState: UIControlState.Normal)
					textButtonIndex++
				}
			}
			
			if (movie.currentCountry.languageArrayIndex != MovieCountry.USA.languageArrayIndex) {
				// Non-English: Also show english trailers
				for trailerName in movie.trailerNames[MovieCountry.USA.languageArrayIndex] {
					if (textButtonIndex < textButtons.count) {
						textButtons[textButtonIndex].addTarget(self, action: Selector("trailerButtonTapped:"), forControlEvents: UIControlEvents.TouchUpInside)
						textButtons[textButtonIndex].setTitle(NSLocalizedString("ShowTrailer", comment: "") + "'" + trailerName + " (USA)'", forState: UIControlState.Normal)
						textButtonIndex++
					}
				}
			}
			
			setUpFavoriteButton()

			// hide unused button(s)
			
			for (var hideId = textButtonIndex; hideId < textButtons.count; hideId++) {
				textButtons[hideId].hidden = true
				buttonLines[hideId].hidden = true
			}

			// Set nice distance between lowest line and the bottom of the content view.
			
			contentView.addConstraint(NSLayoutConstraint(item: buttonLines[textButtonIndex - 1], attribute: NSLayoutAttribute.Bottom,
				relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 10))
		}
	}
	
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		view.layoutIfNeeded()
		
		// show vote average
		
		if let voteAverage = movie?.voteAverage, voteCount = movie?.voteCount where voteCount > 2 {
			UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveLinear,
				animations: {
					self.starsgreyWidthConstraint.constant = 150 - 15 * CGFloat(voteAverage)
					self.starsgoldWidthConstraint.constant = 15 * CGFloat(voteAverage)
					self.starsgoldTrailingConstraint.constant = 150 - 15 * CGFloat(voteAverage)
					self.view.layoutIfNeeded()
				},
				completion:  { _ in }
			)
		}
		
		if (movie?.thumbnailImage.1 == true) {
			
			// if needed: show poster-hint
		
			let posterHintAlreadyShown: Bool? = NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsPosterHintAlreadyShown) as? Bool

			if (posterHintAlreadyShown == nil) {
				// hint not already shown: show it
			
				var errorWindow: MessageWindow?
				
				dispatch_async(dispatch_get_main_queue()) {
					errorWindow = MessageWindow(parent: self.view, darkenBackground: true, titleStringId: "HintTitle", textStringId: "PosterHintText", buttonStringIds: ["Close"],
						handler: { (buttonIndex) -> () in
							errorWindow?.close()
						}
					)
				}
				
				NSUserDefaults(suiteName: Constants.movieStartsGroup)?.setObject(true, forKey: Constants.prefsPosterHintAlreadyShown)
			}
		}
	}

	
	// MARK: - UIViewController

	
	func safariViewControllerDidFinish(controller: SFSafariViewController) {
		controller.dismissViewControllerAnimated(true, completion: nil)
	}
	
	
	// MARK: - Button callbacks

	
	/**
		Calls the webview with the imdb page for the movie.
	
		- parameter sender:	The tapped button
	*/
	func imdbButtonTapped(sender:UIButton) {
		
		// check internet connection
		
		if IJReachability.isConnectedToNetwork() == false {
			NSLog("IMDb view: no network")
			noInternetConnection()
			return
		}
		
		// check if we open the idmb app or the webview
		
		let useApp: Bool? = NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsUseImdbApp) as? Bool
		
		if let imdbId = movie?.imdbId {
			let url: NSURL? = NSURL(string: "imdb:///title/\(imdbId)/")

			if let url = url where (useApp == true) && UIApplication.sharedApplication().canOpenURL(url) {
				// use the app instead of the webview
				UIApplication.sharedApplication().openURL(url)
			}
			else {
				// use the webview
				guard let webUrl = NSURL(string: "http://www.imdb.com/title/\(imdbId)") else { return }
				let webVC = SFSafariViewController(URL: webUrl)
				webVC.delegate = self
				self.presentViewController(webVC, animated: true, completion: nil)
			}
		}
	}


	/**
		Calls the webview with the trailer page for the movie.
	
		- parameter sender:	The tapped button
	*/
	func trailerButtonTapped(sender:UIButton) {
		
		guard let movie = movie else { return }
		
		// check internet connection
		
		if IJReachability.isConnectedToNetwork() == false {
			NSLog("Trailer: no network")
			noInternetConnection()
			return
		}
		
		// find out which trailer was tapped
		
		var index = 0
		
		if (movie.imdbId != nil) {
			index--
		}
		
		for button in textButtons {
			if (button == sender) {
				break
			}
			index++
		}
		
		// check if we open the youtube app or the webview
		let useApp: Bool? = NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsUseYoutubeApp) as? Bool
		var trailerId: String?
		
		if (index >= movie.trailerIds[movie.currentCountry.languageArrayIndex].count) {
			// index seems to be from the fallback-english trailers
			trailerId = movie.trailerIds[MovieCountry.USA.languageArrayIndex][index - movie.trailerIds[movie.currentCountry.languageArrayIndex].count]
		}
		else {
			// index from is from movie country
			trailerId = movie.trailerIds[movie.currentCountry.languageArrayIndex][index]
		}

		if let trailerId = trailerId {
			let url: NSURL? = NSURL(string: "https://www.youtube.com/v/\(trailerId)/")
			
			if let url = url where (useApp == true) && UIApplication.sharedApplication().canOpenURL(url) {
				// use the app instead of the webview
				UIApplication.sharedApplication().openURL(url)
			}
			else {
				guard let webUrl = NSURL(string: "https://www.youtube.com/watch?v=\(trailerId)&autoplay=1&o=U&noapp=1") else { return }
				let webVC = SFSafariViewController(URL: webUrl)
				webVC.delegate = self
				self.presentViewController(webVC, animated: true, completion: nil)
			}
		}
		else {
			NSLog("No TrailerId for movie \(movie.origTitle)")
			return
		}
	}
	
	
	/**
		Adds the current movie to favorites.
	
		- parameter sender:	The tapped button
	*/
	func addFavoriteButtonTapped(sender:UIButton) {
		if let movie = movie {
			Favorites.addMovie(movie, tabBarController: movieTabBarController)
			setUpFavoriteButton()
		}
	}

	
	/**
		Removes current movie from favorites.
	
		- parameter sender:	The tapped button
	*/
	func removeFavoriteButtonTapped(sender:UIButton) {
		if let movie = movie {
			Favorites.removeMovie(movie, tabBarController: movieTabBarController)
			setUpFavoriteButton()
		}
	}
	
	
	// MARK: - Helpers
	
	
	/**
		Sets the given constraint constant to 0.
	
		- parameter constraints: A number of NSLayoutConstraints to be set to 0
	*/
	private final func setConstraintsToZero(constraints: NSLayoutConstraint...) {
		for constraint in constraints {
			constraint.constant = 0
		}
	}

	private final func setUpFavoriteButton() {
		if let movie = movie {
			if (Favorites.IDs.contains(movie.id)) {
				// this movie is a favorite: show remove-button
				if let navigationController = navigationController, topViewController = navigationController.topViewController {
					topViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "favorite.png"), style: UIBarButtonItemStyle.Done, target: self, action: Selector("removeFavoriteButtonTapped:"))
				}
			}
			else {
				// this movie is not a favorite: show add-button
				if let navigationController = navigationController, topViewController = navigationController.topViewController {
					topViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "favoriteframe.png"), style: UIBarButtonItemStyle.Done, target: self, action: Selector("addFavoriteButtonTapped:"))
				}
			}
		}
	}
	
	private final func noInternetConnection() {
		var errorWindow: MessageWindow?
			
		dispatch_async(dispatch_get_main_queue()) {
			self.scrollView.scrollEnabled = false
			
			errorWindow = MessageWindow(parent: self.view, darkenBackground: true, titleStringId: "NoNetworkTitle", textStringId: "NoNetworkText", buttonStringIds: ["Close"],
				handler: { (buttonIndex) -> () in
					errorWindow?.close()
					self.scrollView.scrollEnabled = true
				}
			)
		}
	}
}
