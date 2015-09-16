//
//  MovieViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 14.05.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit


class MovieViewController: UIViewController {

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
	
	@IBOutlet weak var line7: UIView!
	@IBOutlet weak var line8: UIView!
	@IBOutlet weak var line9: UIView!
	@IBOutlet weak var line10: UIView!
	
	// constraints
	
	@IBOutlet weak var posterImageTopSpaceConstraint: NSLayoutConstraint!
	@IBOutlet weak var directorHeadlineLabelHeightConstraint: NSLayoutConstraint!
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
	
	
	var movieTabBarController: TabBarController? {
		get {
			return navigationController?.parentViewController as? TabBarController
		}
	}

	var bigPosterView: UIImageView?
	var movie: MovieRecord?
	var textButtons = [UIButton]()
	var favoriteButtonIndex: Int = 0
	var certificationDict: [String: CertificateLogo] = [
		"R" 	: CertificateLogo(filename: "certificateR.png", height: 30),
		"G" 	: CertificateLogo(filename: "certificateG.png", height: 30),
		"PG" 	: CertificateLogo(filename: "certificatePG.png", height: 30),
		"PG-13" : CertificateLogo(filename: "certificatePG-13.png", height: 30),
		"NC-17" : CertificateLogo(filename: "certificateNC-17.png", height: 30)
	]


	// MARK: - UIViewController
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// start to show all movie details

		var actorLabels = [actorLabel1, actorLabel2, actorLabel3, actorLabel4, actorLabel5]
		var directorLabels = [directorLabel, directorLabel2]
		
		if let saveMovie = movie {
			
			// show poster
			
			if (saveMovie.thumbnailImage.1) {
				posterImageView.image = saveMovie.thumbnailImage.0
				var rec = UITapGestureRecognizer(target: self, action: Selector("thumbnailTapped:"))
				rec.numberOfTapsRequired = 1
				posterImageView.addGestureRecognizer(rec)
			}

			// fill labels
			
			titleLabel?.text = saveMovie.title

			// show labels with subtitles
			
			var subtitleLabels = [subtitleText1, subtitleText2, subtitleText3]
			
			for (index, subtitle) in enumerate(saveMovie.subtitleArray) {
				subtitleLabels[index]?.text = subtitle
			}
			
			// hide unused labels
			
			for (var index = saveMovie.subtitleArray.count; index < subtitleLabels.count; index++) {
				subtitleLabels[index]?.hidden = true
			}

			// vertically "center" the labels
			var moveY = (subtitleLabels.count - saveMovie.subtitleArray.count) * 19
			titleLabelTopSpaceConstraint.constant = CGFloat(moveY / 2) * -1 + 4

			// show release date
			
			releaseDateHeadlineLabel.text = NSLocalizedString("ReleaseDate", comment: "") + ":"
			if let saveDate = saveMovie.releaseDate {
				releaseDateLabel?.text = saveMovie.releaseDateString
			}
			else {
				// no release date (cannot happen)
				releaseDateLabel?.text = "-"
			}
			
			// show rating
			
			ratingHeadlineLabel.text = NSLocalizedString("UserRating", comment: "") + ":"
			if (saveMovie.voteAverage > 0.1) {
				var numberFormatter = NSNumberFormatter()
				numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
				numberFormatter.minimumFractionDigits = 1

				var voteAverage = numberFormatter.stringFromNumber(saveMovie.voteAverage)
				var voteMaximum = numberFormatter.stringFromNumber(10.0)

				if let saveVoteAverage = voteAverage, saveVoteMaximum = voteMaximum {
					ratingLabel?.text =  "\(saveVoteAverage)" // "\(saveVoteAverage) / \(saveVoteMaximum)"
				}
				else {
					// vote was no number, shouldn't happen
					ratingLabel?.text = "-"
				}
			}
			else {
				// no or not enough votes
				ratingLabel?.text = "-"
			}
			
			// show director(s)

			directorHeadlineLabel.text = NSLocalizedString("Director", comment: "") + ":"
			if (saveMovie.directors.count > 1) {
				directorHeadlineLabel.text = NSLocalizedString("Directors", comment: "") + ":"
			}
			
			if (saveMovie.directors.count > 0) {
				for index in 0...saveMovie.directors.count-1 {
					if (index < 2) {
						directorLabels[index].text = saveMovie.directors[index]
					}
				}
			}
			
			// hide unused director-fields
			
			if (saveMovie.directors.count < 2) {
				setConstraintsToZero(directorLabel2HeightConstraint, directorLabel2VerticalSpaceConstraint)
			}
			if (saveMovie.directors.count < 1) {
				setConstraintsToZero(directorLabelHeightConstraint, directorLabelVerticalSpaceConstraint, directorHeadlineLabelHeightConstraint,
					directorHeadlineLabelVerticalSpaceConstraint, line2HeightConstraint, line2VerticalSpaceConstraint)
			}
			
			// show actor(s)
			
			actorHeadlineLabel.text = NSLocalizedString("Actors", comment: "") + ":"
			if (saveMovie.actors.count > 0) {
				for index in 0...saveMovie.actors.count-1 {
					if (index < 5) {
						actorLabels[index].text = saveMovie.actors[index]
					}
				}
			}
			
			// hide unused actor-fields
			
			if (saveMovie.actors.count < 5) {
				setConstraintsToZero(actorLabel5HeightConstraint, actorLabel5VerticalSpaceConstraint)
			}
			if (saveMovie.actors.count < 4) {
				setConstraintsToZero(actorLabel4HeightConstraint, actorLabel4VerticalSpaceConstraint)
			}
			if (saveMovie.actors.count < 3) {
				setConstraintsToZero(actorLabel3HeightConstraint, actorLabel3VerticalSpaceConstraint)
			}
			if (saveMovie.actors.count < 2) {
				setConstraintsToZero(actorLabel2HeightConstraint, actorLabel2VerticalSpaceConstraint)
			}
			if (saveMovie.actors.count < 1) {
				setConstraintsToZero(actorLabel1HeightConstraint, actorLabel1VerticalSpaceConstraint, actorHeadlineLabelHeightConstraint,
					actorHeadlineLabelVerticalSpaceConstraint, line3HeightConstraint, line3VerticalSpaceConstraint)
			}
			
			// show story
			
			storyHeadlineLabel.text = NSLocalizedString("Synopsis", comment: "") + ":"
			if let synopsis = saveMovie.synopsis {
				storyLabel.text = synopsis
			}

			// show textbuttons for imdb and trailers
			
			textButtons = [textButton1, textButton2, textButton3, textButton4, textButton5]
			var textButtonIndex = 0
			var buttonLines = [line7, line8, line9, line10]
			
			if let imdbId = saveMovie.imdbId {
				textButtons[textButtonIndex].addTarget(self, action: Selector("imdbButtonTapped:"), forControlEvents: UIControlEvents.TouchUpInside)
				textButtons[textButtonIndex].setTitle(NSLocalizedString("ShowOnImdb", comment: ""), forState: UIControlState.Normal)
				textButtonIndex++
			}
			
			for trailerName in saveMovie.trailerNames {
				textButtons[textButtonIndex].addTarget(self, action: Selector("trailerButtonTapped:"), forControlEvents: UIControlEvents.TouchUpInside)
				textButtons[textButtonIndex].setTitle(NSLocalizedString("ShowTrailer", comment: "") + "'" + trailerName + "'", forState: UIControlState.Normal)
				textButtonIndex++
			}
			
			// generate favorite button

			favoriteButtonIndex = textButtonIndex
			setUpFavoriteButton()
			
			textButtonIndex++

			// hide unused button(s)
			
			for (var hideId = textButtonIndex; hideId < textButtons.count; hideId++) {
				textButtons[hideId].hidden = true
				buttonLines[hideId-1].hidden = true
			}

			// Set nice distance between lowest line and the bottom of the content view.

			contentView.addConstraint(NSLayoutConstraint(item: buttonLines[textButtonIndex - 2], attribute: NSLayoutAttribute.Bottom,
				relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 20))
		}
	}
	
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	
	// MARK: - Button callbacks
	
	
	/**
		Calls the webview with the imdb page for the movie.
	
		:param: sender	The tapped button
	*/
	func imdbButtonTapped(sender:UIButton!) {
		
		// check internet connection
		
		if IJReachability.isConnectedToNetwork() == false {
			NSLog("IMDb view: no network")
			noInternetConnection()
			return
		}
		
		// check if we open the idmb app or the webview
		
		var useApp: Bool? = NSUserDefaults(suiteName: Constants.MOVIESTARTS_GROUP)?.objectForKey(Constants.PREFS_USE_IMDB_APP) as! Bool?
		
		if let imdbId = movie?.imdbId {
			var url: NSURL? = NSURL(string: "imdb:///title/\(imdbId)/")

			if let url = url where (useApp == true) && UIApplication.sharedApplication().canOpenURL(url) {
				// use the app instead of the webview
				UIApplication.sharedApplication().openURL(url)
			}
			else {
				// use the webview
				var webViewController = storyboard?.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
				webViewController.urlString = "http://www.imdb.com/title/\(imdbId)"
				navigationController?.pushViewController(webViewController, animated: true)
			}
		}
	}


	/**
		Calls the webview with the trailer page for the movie.
	
		:param: sender	The tapped button
	*/
	func trailerButtonTapped(sender:UIButton!) {
		
		// check internet connection
		
		if IJReachability.isConnectedToNetwork() == false {
			NSLog("Trailer: no network")
			noInternetConnection()
			return
		}
		
		// find out which trailer was tapped
		
		var index = 0
		
		if ((movie != nil) && (movie?.imdbId != nil)) {
			index--
		}
		
		for button in textButtons {
			if (button == sender) {
				break
			}
			index++
		}
		
		// check if we open the youtube app or the webview
		
		var useApp: Bool? = NSUserDefaults(suiteName: Constants.MOVIESTARTS_GROUP)?.objectForKey(Constants.PREFS_USE_YOUTUBE_APP) as! Bool?
		
		if let trailerId = movie?.trailerIds[index] {
			var url: NSURL? = NSURL(string: "http://www.youtube.com/v/\(trailerId)/")
			
			if let url = url where (useApp == true) && UIApplication.sharedApplication().canOpenURL(url) {
				// use the app instead of the webview
				UIApplication.sharedApplication().openURL(url)
			}
			else {
				// use the webview
				var webViewController = storyboard?.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
				webViewController.urlString = "http://www.youtube.com/watch?v=\(trailerId)&autoplay=1"
				navigationController?.pushViewController(webViewController, animated: true)
			}
		}
	}
	
	
	/**
		Adds the current movie to favorites.
	
		:param: sender	The tapped button
	*/
	func addFavoriteButtonTapped(sender:UIButton!) {
		if let movie = movie {
			Favorites.addMovie(movie, tabBarController: movieTabBarController)
			setUpFavoriteButton()
		}
	}

	
	/**
		Removes current movie from favorites.
	
		:param: sender	The tapped button
	*/
	func removeFavoriteButtonTapped(sender:UIButton!) {
		if let movie = movie {
			Favorites.removeMovieID(movie.id, tabBarController: movieTabBarController)
			setUpFavoriteButton()
		}
	}
	
	
	/**
		Enlarges the tapped thumbnail poster.
	
		:param: recognizer	The gesture recognizer - unused.
	*/
	func thumbnailTapped(recognizer: UITapGestureRecognizer) {
		
		if let saveMovie = movie, thumbnailImage = saveMovie.thumbnailImage.0 {
			
			// add new image view
			
			bigPosterView = UIImageView(frame: CGRect(x: posterImageView.frame.minX, y: posterImageView.frame.minY,
				width: posterImageView.frame.width, height: posterImageView.frame.height))
			
			if let bigPosterView = bigPosterView {
				bigPosterView.contentMode = UIViewContentMode.ScaleAspectFit
				bigPosterView.image = thumbnailImage
				bigPosterView.userInteractionEnabled = true
				bigPosterView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("bigPosterTapped:")))
				self.view.addSubview(bigPosterView)
				
				// animate it to a bigger poster
				
				UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut,
					animations: {
						bigPosterView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
					},
					completion: { finished in }
				)
			}
		}
	}
	
	
	/**
		Closes the enlarged poster.
	
		:param: recognizer	The gesture recognizer - unused.
	*/
	func bigPosterTapped(recognizer: UITapGestureRecognizer) {
		
		if let bigPosterView = bigPosterView {
			UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut,
				animations: {
					bigPosterView.frame = CGRect(x: self.posterImageView.frame.minX, y: self.posterImageView.frame.minY,
						width: self.posterImageView.frame.width, height: self.posterImageView.frame.height)
				},
				completion: { finished in
					bigPosterView.removeFromSuperview()
					self.bigPosterView = nil
				}
			)
		}
	}
	
	
	// MARK: - Helpers
	
	
	/**
		Sets the given constraint constant to 0.
	
		:param: constraints		A number of NSLayoutConstraints to be set to 0
	*/
	private final func setConstraintsToZero(constraints: NSLayoutConstraint...) {
		for constraint in constraints {
			constraint.constant = 0
		}
	}

	private final func setUpFavoriteButton() {
		if let movie = movie {
			textButtons[favoriteButtonIndex].removeTarget(nil, action: nil, forControlEvents: UIControlEvents.AllEvents)
			
			if (contains(Favorites.IDs, movie.id)) {
				// this movie is a favorite: show remove-button
				textButtons[favoriteButtonIndex].addTarget(self, action: Selector("removeFavoriteButtonTapped:"), forControlEvents: UIControlEvents.TouchUpInside)
				textButtons[favoriteButtonIndex].setTitle(NSLocalizedString("RemoveFromFavorites", comment: ""), forState: UIControlState.Normal)
			}
			else {
				// this movie is not a favorite: show add-button
				textButtons[favoriteButtonIndex].addTarget(self, action: Selector("addFavoriteButtonTapped:"), forControlEvents: UIControlEvents.TouchUpInside)
				textButtons[favoriteButtonIndex].setTitle(NSLocalizedString("AddToFavorites", comment: ""), forState: UIControlState.Normal)
			}
		}
	}
	
	private final func noInternetConnection() {
		var errorWindow: MessageWindow?
			
		dispatch_async(dispatch_get_main_queue()) {
			self.scrollView.scrollEnabled = false
			
			errorWindow = MessageWindow(parent: self.view, darkenBackground: true, titleStringId: "NoNetworkTitle", textStringId: "NoNetworkText", buttonStringId: "Close", handler: {
				errorWindow?.close()
				self.scrollView.scrollEnabled = true
			})
		}
	}
}
