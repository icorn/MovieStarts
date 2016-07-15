//
//  MovieViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 14.05.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit
import SafariServices
import Crashlytics


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
	@IBOutlet weak var directorHeadlineLabel: UILabel!
	@IBOutlet weak var actorHeadlineLabel: UILabel!
	@IBOutlet weak var storyHeadlineLabel: UILabel!
	@IBOutlet weak var storyLabel: UILabel!
	@IBOutlet weak var imdbButton: UIButton!
	@IBOutlet weak var trailerHeadlineLabel: UILabel!
	@IBOutlet weak var trailerStackView: UIStackView!
	@IBOutlet weak var actorStackView: UIStackView!
	@IBOutlet weak var directorStackView: UIStackView!
	
	@IBOutlet weak var ratingStackView: UIStackView!
	@IBOutlet weak var imdbRatingLabel: UILabel!
    @IBOutlet weak var imdbImageView: UIImageView!
	@IBOutlet weak var imdbHeadlineLabel: UILabel!
	@IBOutlet weak var tomatoesImageView: UIImageView!
	@IBOutlet weak var tomatoesRatingLabel: UILabel!
	@IBOutlet weak var metascoreRatingLabel: UILabel!
	@IBOutlet weak var metascoreInnerView: UIView!
	@IBOutlet weak var moreStoryButton: UIButton!
	
	@IBOutlet weak var bottomLine: UIView!
	
	// constraints
	
	@IBOutlet weak var posterImageTopSpaceConstraint: NSLayoutConstraint!
	@IBOutlet weak var directorHeadlineLabelHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var lineReleaseDateHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var line2VerticalSpaceConstraint: NSLayoutConstraint!
	@IBOutlet weak var lineStoryHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var lineTrailersHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lineTopHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var line1VerticalSpaceConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var directorHeadlineLabelVerticalSpaceConstraint: NSLayoutConstraint!
	@IBOutlet weak var actorHeadlineLabelHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var titleLabelTopSpaceConstraint: NSLayoutConstraint!
	@IBOutlet weak var storyHeadlineLabelTopSpaceConstraint: NSLayoutConstraint!
	@IBOutlet weak var storyLabelTopSpaceConstraint: NSLayoutConstraint!
	@IBOutlet weak var lineDirectorsHeightConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var trailerHeadlineLabelVerticalSpaceConstraint: NSLayoutConstraint!
	@IBOutlet weak var trailerStackViewVerticalSpaceConstraint: NSLayoutConstraint!
	@IBOutlet weak var ratingStackViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var ratingStackViewVerticalSpaceConstraint: NSLayoutConstraint!
	@IBOutlet weak var imdbImageViewWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var tomatoesImageViewWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var lineActorsHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var moreStoryButtonHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var moreStoryButtonVerticalSpaceConstraint: NSLayoutConstraint!
	
    @IBOutlet weak var imdbOuterView: UIView!
    @IBOutlet weak var imdbInnerView: UIView!
    
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
	var allTrailerIds: [String] = []
	var showRatingsFlag: Bool = false
	var baseImagePath: String?
	var showCompleteStory: Bool = false
	
	
	// MARK: - UIViewController
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// start to show all movie details
		
		if let movie = movie {
			
			#if RELEASE
				// log this action
				let imdbId = (movie.imdbId != nil) ? movie.imdbId! : "<unknown ID>"
				let title = (movie.origTitle != nil) ? movie.origTitle! : "<unknown title>"
				Answers.logContentViewWithName(title, contentType: nil, contentId: imdbId, customAttributes: nil)
			#endif
			
			baseImagePath = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(Constants.movieStartsGroup)?.path
				
			// show movie data
			showPoster()
			showTitles()
			showReleaseDate()
			showRatings()
			showDirectors()
			showActors()
			showSynopsis()
			showLinkButtons()
			showTrailers()

			setUpFavoriteButton()
			
			// shrink story label if needed
			
			view.layoutIfNeeded()
			shrinkStoryIfNeeded()

			// Set nice distance between lowest line and the bottom of the content view.

			contentView.addConstraint(NSLayoutConstraint(item: bottomLine, attribute: NSLayoutAttribute.Bottom,
				relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 10))
		}
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		view.layoutIfNeeded()
		
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
				NSUserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
			}
		}
	}
	
	
	/**
		Updates a trailer button with a new image.
	
		- parameter index:		The index of the button inside the stackview
		- parameter trailerId:	The id of the trailer, which is also the filename of the trailer-image
	*/
	private final func updateTrailerButton(index: Int, trailerId: String) {
        if (index >= trailerStackView.arrangedSubviews.count) {
            return
        }
        
		guard let buttonToUpdate = trailerStackView.arrangedSubviews[index] as? UIButton else { return }
		guard let basePath = self.baseImagePath else { return }

		let trailerImageFilePath = basePath + Constants.trailerFolder + "/" + trailerId + ".jpg"
		
		guard let trailerImage = UIImage(contentsOfFile: trailerImageFilePath)?.CGImage else { return }

		let scaledImage = UIImage(CGImage: trailerImage, scale: 1.5, orientation: UIImageOrientation.Up)

		dispatch_async(dispatch_get_main_queue()) {
			buttonToUpdate.setImage(scaledImage, forState: UIControlState.Normal)
		}
	}
	
	
	// MARK: - Show-Functions

	
	private final func showPoster()
	{
		posterImageView.image = self.movie?.thumbnailImage.0
		
		if let movie = self.movie where movie.thumbnailImage.1 {
			let rec = UITapGestureRecognizer(target: self, action: #selector(MovieViewController.thumbnailTapped(_:)))
			rec.numberOfTapsRequired = 1
			posterImageView.addGestureRecognizer(rec)
		}
	}
	
	private final func showTitles() {
		guard let movie = self.movie else { return }
		
		titleLabel?.text = movie.title[movie.currentCountry.languageArrayIndex]
			
		// show labels with subtitles
		
		var subtitleLabels = [subtitleText1, subtitleText2, subtitleText3]
		
		if let genreDict = movieTabBarController?.genreDict {
			for (index, subtitle) in movie.getSubtitleArray(genreDict).enumerate() {
				subtitleLabels[index]?.text = subtitle
			}
			
			// hide unused labels
			
			for index in movie.getSubtitleArray(genreDict).count ..< subtitleLabels.count {
				subtitleLabels[index]?.hidden = true
			}
			
			// vertically "center" the labels
			let moveY = (subtitleLabels.count - movie.getSubtitleArray(genreDict).count) * 19
			titleLabelTopSpaceConstraint.constant = CGFloat(moveY / 2) * -1 + 4
		}
	}

	private final func showReleaseDate() {
		guard let movie = self.movie else { return }
		releaseDateHeadlineLabel.text = NSLocalizedString("ReleaseDate", comment: "") + ":"
		
		if (movie.releaseDate[movie.currentCountry.countryArrayIndex].compare(NSDate(timeIntervalSince1970: 0)) == NSComparisonResult.OrderedDescending) {
			releaseDateLabel?.text = movie.releaseDateString
		}
		else {
			// no release date (cannot happen)
			releaseDateLabel?.text = "-"
		}
	}
	
	private final func showRatings() {
		guard let movie = self.movie else { return }
	
		self.showRatingsFlag = (movie.ratingImdb != nil) || (movie.ratingTomato != nil) || (movie.ratingMetacritic != nil)
		
		if (self.showRatingsFlag) {
			setConstraintsToZero(line1VerticalSpaceConstraint, lineTopHeightConstraint, lineReleaseDateHeightConstraint,
								 line2VerticalSpaceConstraint)
			
			// IMDb rating
			
			imdbHeadlineLabel.text = NSLocalizedString("IMDbRating", comment: "")
			let numberFormatter = NSNumberFormatter()
			numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
			numberFormatter.minimumFractionDigits = 1
			
			if let score = self.movie?.ratingImdb, scoreString = numberFormatter.stringFromNumber(score) {
				imdbRatingLabel.text =  "\(scoreString)"
				
				if (score >= 7.0) {
					imdbImageView.image = UIImage.init(named: "arrowup.png")
				}
				else if (score < 6.0) {
					imdbImageView.image = UIImage.init(named: "arrowdown.png")
				}
				else {
					imdbImageView.image = UIImage.init(named: "arrowmedium.png")
				}
			}
			else {
				// vote was no number, shouldn't happen
				imdbRatingLabel.text = NSLocalizedString("Score unknown", comment: "")
				imdbRatingLabel.textColor = UIColor.darkGrayColor()
				imdbImageView.image = nil
				imdbImageViewWidthConstraint.constant = 0
			}
			
			// Rotten Tomatoes rating
			
			if let score = self.movie?.ratingTomato {
				tomatoesRatingLabel.text = "\(score)%"
				
				if let tomatoImageIndex = self.movie?.tomatoImage, tomatoImage = TomatoImage(rawValue: tomatoImageIndex) {
					tomatoesImageView.image = UIImage.init(named: tomatoImage.filename)
				}
			}
			else {
				tomatoesRatingLabel.text = NSLocalizedString("Score unknown", comment: "")
				tomatoesRatingLabel.textColor = UIColor.darkGrayColor()
				tomatoesImageView.hidden = true
				tomatoesImageViewWidthConstraint.constant = 0
			}
			
			// Metacritic rating
			
			if let score = self.movie?.ratingMetacritic {
				metascoreRatingLabel.text = "\(score)"
				
				switch score {
				case 0...39:
					// red score
					metascoreInnerView.backgroundColor = UIColor(red: 237.0/255.0, green: 12.0/255.0, blue: 25.0/255.0, alpha: 1.0)
					metascoreRatingLabel.textColor = UIColor.whiteColor()
				case 40...60:
					// yellow score
					metascoreInnerView.backgroundColor = UIColor(red: 230.0/255.0, green: 225.0/255.0, blue: 49.0/255.0, alpha: 1.0)
					metascoreRatingLabel.textColor = UIColor.blackColor()
				default:
					// green score
					metascoreInnerView.backgroundColor = UIColor(red: 27.0/255.0, green: 184.0/255.0, blue: 31.0/255.0, alpha: 1.0)
					metascoreRatingLabel.textColor = UIColor.whiteColor()
				}
			}
			else {
				metascoreRatingLabel.text = NSLocalizedString("Score unknown", comment: "")
				metascoreRatingLabel.textColor = UIColor.darkGrayColor()
				metascoreInnerView.backgroundColor = UIColor.clearColor()
				metascoreRatingLabel.textColor = UIColor.blackColor()
			}
		}
		else {
			// hide all ratings stuff, because we have no ratings
			ratingStackView.hidden = true
			setConstraintsToZero(ratingStackViewHeightConstraint, ratingStackViewVerticalSpaceConstraint,
								 line1VerticalSpaceConstraint, lineTopHeightConstraint)
		}
	}
	
	private final func showSynopsis() {
		guard let movie = self.movie else { return }
		
		let synopsisForLanguage = movie.synopsisForLanguage
		
		if (synopsisForLanguage.0.characters.count > 0) {
			storyHeadlineLabel.text = NSLocalizedString("Synopsis", comment: "") + ":"
			moreStoryButton.setTitle("▼  " + NSLocalizedString("ShowCompleteSynopsis", comment: "") + "  ▼",
			                         forState: UIControlState.Normal)
			storyLabel.text = synopsisForLanguage.0
			
			if (synopsisForLanguage.1 != movie.currentCountry.languageArrayIndex) {
				// synopsis is english as fallback
				storyHeadlineLabel.text = NSLocalizedString("SynopsisEnglish", comment: "") + ":"
			}
		}
		else {
			// hide everything related to synopsis
			setConstraintsToZero(storyLabelTopSpaceConstraint, storyHeadlineLabelTopSpaceConstraint, lineStoryHeightConstraint)
			storyHeadlineLabel.addConstraint(NSLayoutConstraint(item: storyHeadlineLabel, attribute: NSLayoutAttribute.Height,
				relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 0))
			storyLabel.addConstraint(NSLayoutConstraint(item: storyLabel, attribute: NSLayoutAttribute.Height,
				relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 0))
		}
	}
	
	private final func showLinkButtons() {
		guard let movie = self.movie else { return }
		
		if (movie.imdbId != nil) {
			imdbButton.addTarget(self, action: #selector(MovieViewController.imdbButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
			imdbButton.setTitle(NSLocalizedString("ShowOnImdb", comment: ""), forState: UIControlState.Normal)
		}
	}

	private final func showTrailers()	{
		guard let movie = self.movie else { return }
		trailerHeadlineLabel.text = NSLocalizedString("TrailerHeadline", comment: "") + ":"
		
		allTrailerIds = movie.trailerIds[movie.currentCountry.languageArrayIndex]
		
		if (movie.currentCountry.languageArrayIndex != MovieCountry.USA.languageArrayIndex) {
			allTrailerIds.appendContentsOf(movie.trailerIds[MovieCountry.USA.languageArrayIndex])
		}
		
		if (allTrailerIds.count == 0) {
			// no trailers: hide all related UI elements
			setConstraintsToZero(trailerStackViewVerticalSpaceConstraint, trailerHeadlineLabelVerticalSpaceConstraint)
			trailerHeadlineLabel.addConstraint(NSLayoutConstraint(item: trailerHeadlineLabel, attribute: NSLayoutAttribute.Height,
				relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 0))
			return
		}
		
		guard let basePath = self.baseImagePath else { return }
		
		for (index, trailerId) in allTrailerIds.enumerate() {
			// try to load existing trailer-image
			let trailerImageFilePath = basePath + Constants.trailerFolder + "/" + trailerId + ".jpg"
			var trailerImage = UIImage(contentsOfFile: trailerImageFilePath)?.CGImage
			
			if (trailerImage == nil) {
				// trailer-image not found: use default-image
				trailerImage = UIImage(named: "YoutubeBack.png")?.CGImage
				
				// load the correct image from YouTube
				guard let sourceImageUrl = NSURL(string: "https://img.youtube.com/vi/" + trailerId + "/mqdefault.jpg") else { continue }
				
				let task = NSURLSession.sharedSession().downloadTaskWithURL(sourceImageUrl, completionHandler: { (location: NSURL?, response: NSURLResponse?, error: NSError?) -> Void in
					if let error = error {
						NSLog("Error getting poster from Youtube: \(error.description)")
					}
					else if let receivedPath = location?.path {
						// move received poster to target path where it belongs and update the button
						do {
							try NSFileManager.defaultManager().moveItemAtPath(receivedPath, toPath: trailerImageFilePath)
							self.updateTrailerButton(index, trailerId: trailerId)
						}
						catch let error as NSError {
							if ((error.domain == NSCocoaErrorDomain) && (error.code == NSFileWriteFileExistsError)) {
								// ignoring, because it's okay it it's already there
							}
							else {
								NSLog("Error moving trailer-poster: \(error.description)")
							}
						}
					}
				})
				
				task.resume()
			}
			
			if let trailerImage = trailerImage {
				let scaledImage = UIImage(CGImage: trailerImage, scale: 1.5, orientation: UIImageOrientation.Up)
				let button = UIButton()
				button.tag = Constants.tagTrailer + index
				button.setImage(scaledImage, forState: UIControlState.Normal)
				button.contentMode = .ScaleAspectFit
				button.addTarget(self, action: #selector(MovieViewController.trailerButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
				trailerStackView.addArrangedSubview(button)
			}
		}
		
		trailerStackView.layoutIfNeeded()
	}

	private final func showDirectors() {
		guard let movie = self.movie else { return }
		
		if (movie.directors.count > 0) {
			directorHeadlineLabel.text = NSLocalizedString("Director", comment: "") + ":"
			
			if (movie.directors.count > 1) {
				directorHeadlineLabel.text = NSLocalizedString("Directors", comment: "") + ":"
			}
			
			for directorIndex in 0...movie.directors.count-1 {
				if let newSubview = addPersonToStackView(false,
				                                         filename: movie.directorPictures[directorIndex],
				                                         foldername: Constants.directorThumbnailFolder,
				                                         title: movie.directors[directorIndex],
				                                         subtitle: nil)
				{
					directorStackView.addArrangedSubview(newSubview)
				}
			}
		}
		else {
			// no directors
			
			// TODO
			
		}
	}
	
	private final func addPersonToStackView(hidden: Bool,
	                                        filename: String,
	                                        foldername: String,
	                                        title: String,
	                                        subtitle: String?) -> UIView?
	{
		let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
		imageView.contentMode = UIViewContentMode.ScaleAspectFill
		imageView.image = UIImage(named: "welcome")
		
		guard let basePath = self.baseImagePath else {
			return nil
		}
		
		if (filename.characters.count > 0) {
			
			let actorImageFilePath = basePath + foldername + filename
			imageView.image = self.cropImage(UIImage(contentsOfFile: actorImageFilePath))
			
			if (imageView.image == nil) {
				// image not found: use default-image
				imageView.image = UIImage(named: "welcome")
				
				// load the correct image from YouTube
				guard let sourceImageUrl = NSURL(string: "http://image.tmdb.org/t/p/w45" + filename) else {
					return nil
				}
				
				let task = NSURLSession.sharedSession().downloadTaskWithURL(sourceImageUrl, completionHandler: { (location: NSURL?, response: NSURLResponse?, error: NSError?) -> Void in
					
					if let error = error {
						NSLog("Error getting actor thumbnail: \(error.description)")
					}
					else if let receivedPath = location?.path {
						// move received poster to target path where it belongs and update the button
						do {
							try NSFileManager.defaultManager().moveItemAtPath(receivedPath, toPath: actorImageFilePath)
							imageView.image = self.cropImage(UIImage(contentsOfFile: actorImageFilePath))
						}
						catch let error as NSError {
							if ((error.domain == NSCocoaErrorDomain) && (error.code == NSFileWriteFileExistsError)) {
								// ignoring, because it's okay it it's already there
							}
							else {
								NSLog("Error moving actor/director thumbnail: \(error.description)")
							}
						}
					}
				})
				
				task.resume()
			}
		}
		
		let personNameLabel = UILabel()
		personNameLabel.text = title
		personNameLabel.font = UIFont.systemFontOfSize(14.0)
		
		let innerStackView = UIStackView(arrangedSubviews: [personNameLabel])
		innerStackView.axis = .Vertical
		innerStackView.alignment = UIStackViewAlignment.Leading
		innerStackView.distribution = UIStackViewDistribution.Fill
		innerStackView.spacing = 0
		
		if let subtitle = subtitle where subtitle.characters.count > 0 {
			let characterNameLabel = UILabel()
			characterNameLabel.text = NSLocalizedString("ActorAs", comment: "") + " " + subtitle
			characterNameLabel.font = UIFont.systemFontOfSize(12.0)
			innerStackView.addArrangedSubview(characterNameLabel)
		}
		
		let outerStackView = UIStackView(arrangedSubviews: [imageView, innerStackView])
		outerStackView.axis = .Horizontal
		outerStackView.alignment = UIStackViewAlignment.Center
		outerStackView.distribution = UIStackViewDistribution.Fill
		outerStackView.spacing = 8
		outerStackView.hidden = hidden
		
		return outerStackView
	}
	
	private final func shrinkStoryIfNeeded() {
		let numLinesOfStory = round(storyLabel.frame.height / storyLabel.font.lineHeight)
		
		if (numLinesOfStory > 9) {
			// set height to 8 lines and show button
			storyLabel.numberOfLines = 8
		}
		else {
			moreStoryButton.hidden = true
			setConstraintsToZero(moreStoryButtonHeightConstraint, moreStoryButtonVerticalSpaceConstraint)
		}
	}
	
	
	// MARK: - SFSafariViewControllerDelegate

	
	func safariViewControllerDidFinish(controller: SFSafariViewController) {
		controller.dismissViewControllerAnimated(true, completion: nil)
	}
	
	
	// MARK: - Button callbacks

	
	final func imdbButtonTapped(sender: UIButton) {
		showImdbPage()
	}

	final func trailerButtonTapped(sender: UIButton) {
		
		guard let movie = movie else { return }
		
		// check if we open the youtube app or the webview
		let useApp: Bool? = NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsUseYoutubeApp) as? Bool
		var trailerId: String?
		
		trailerId = allTrailerIds[sender.tag - Constants.tagTrailer]

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
	
	final func addFavoriteButtonTapped(sender:UIButton) {
		if let movie = movie {
			Favorites.addMovie(movie, tabBarController: movieTabBarController)
			setUpFavoriteButton()
			NotificationManager.updateFavoriteNotifications(movieTabBarController?.favoriteMovies)
		}
	}

	final func removeFavoriteButtonTapped(sender:UIButton) {
		if let movie = movie {
			Favorites.removeMovie(movie, tabBarController: movieTabBarController)
			setUpFavoriteButton()
			NotificationManager.updateFavoriteNotifications(movieTabBarController?.favoriteMovies)
		}
	}

	@IBAction func imdbRatingTapped(sender: UITapGestureRecognizer) {
		showImdbPage()
	}
	
	@IBAction func tomatoRatingTapped(sender: UITapGestureRecognizer) {
		if let urlString = movie?.tomatoURL {
			guard let webUrl = NSURL(string: urlString) else { return }
			let webVC = SFSafariViewController(URL: webUrl)
			webVC.delegate = self
			self.presentViewController(webVC, animated: true, completion: nil)
		}
	}

	@IBAction func moreStoryButtonTapped(sender: AnyObject) {
		showCompleteStory = !showCompleteStory
		
		if (showCompleteStory) {
			moreStoryButton.setTitle("▲  " + NSLocalizedString("ShowShortSynopsis", comment: "") + "  ▲",
			                         forState: UIControlState.Normal)
			storyLabel.numberOfLines = 0
		}
		else {
			moreStoryButton.setTitle("▼  " + NSLocalizedString("ShowCompleteSynopsis", comment: "") + "  ▼",
			                         forState: UIControlState.Normal)
			storyLabel.numberOfLines = 8
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
					topViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "favorite.png"), style: UIBarButtonItemStyle.Done, target: self, action: #selector(MovieViewController.removeFavoriteButtonTapped(_:)))
				}
			}
			else {
				// this movie is not a favorite: show add-button
				if let navigationController = navigationController, topViewController = navigationController.topViewController {
					topViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "favoriteframe.png"), style: UIBarButtonItemStyle.Done, target: self, action: #selector(MovieViewController.addFavoriteButtonTapped(_:)))
				}
			}
		}
	}

	private final func showImdbPage() {
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
	
	final func cropImage(inputImage: UIImage?) -> UIImage? {
		if let imageRef = CGImageCreateWithImageInRect(inputImage?.CGImage, CGRect(x: 0, y: 0, width: 45, height: 60)) {
			return UIImage(CGImage: imageRef)
		}
		
		return nil
	}
}
