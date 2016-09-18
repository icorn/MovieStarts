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
	@IBOutlet weak var infoHeadlineLabel: UILabel!
	@IBOutlet weak var actorHeadlineLabel: UILabel!
	@IBOutlet weak var storyHeadlineLabel: UILabel!
	@IBOutlet weak var storyLabel: UILabel!
	@IBOutlet weak var imdbButton: UIButton!
	@IBOutlet weak var trailerHeadlineLabel: UILabel!
	@IBOutlet weak var trailerStackView: UIStackView!
	@IBOutlet weak var actorStackView: UIStackView!
	@IBOutlet weak var infoStackView: UIStackView!
	
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
	@IBOutlet weak var infoHeadlineLabelHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var line2VerticalSpaceConstraint: NSLayoutConstraint!
	@IBOutlet weak var lineStoryHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var lineTrailersHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lineTopHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var line1VerticalSpaceConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var infoHeadlineLabelVerticalSpaceConstraint: NSLayoutConstraint!
	@IBOutlet weak var actorHeadlineLabelHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var titleLabelTopSpaceConstraint: NSLayoutConstraint!
	@IBOutlet weak var storyHeadlineLabelTopSpaceConstraint: NSLayoutConstraint!
	@IBOutlet weak var storyLabelTopSpaceConstraint: NSLayoutConstraint!
	@IBOutlet weak var lineInfoHeightConstraint: NSLayoutConstraint!
	
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
			return navigationController?.parent as? TabBarController
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
			
			baseImagePath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.movieStartsGroup)?.path
				
			// show movie data
			showPoster()
			showTitles()
			showRatings()
			showSynopsis()
			showActors()
			showInfos()
			showLinkButtons()
			showTrailers()

			setUpFavoriteButton()
			
			// shrink story label if needed
			
			view.layoutIfNeeded()
			shrinkStoryIfNeeded()

			// Set nice distance between lowest line and the bottom of the content view.

			contentView.addConstraint(NSLayoutConstraint(item: bottomLine, attribute: NSLayoutAttribute.bottom,
				relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 10))
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		view.layoutIfNeeded()
		
		if (movie?.thumbnailImage.1 == true) {
			
			// if needed: show poster-hint
		
			let posterHintAlreadyShown: Bool? = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsPosterHintAlreadyShown) as? Bool

			if (posterHintAlreadyShown == nil) {
				// hint not already shown: show it
			
				var errorWindow: MessageWindow?
				
				DispatchQueue.main.async {
					errorWindow = MessageWindow(parent: self.view, darkenBackground: true, titleStringId: "HintTitle", textStringId: "PosterHintText", buttonStringIds: ["Close"],
						handler: { (buttonIndex) -> () in
							errorWindow?.close()
						}
					)
				}
				
				UserDefaults(suiteName: Constants.movieStartsGroup)?.set(true, forKey: Constants.prefsPosterHintAlreadyShown)
				UserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
			}
		}
	}
	
	
	/**
		Updates a trailer button with a new image.
	
		- parameter index:		The index of the button inside the stackview
		- parameter trailerId:	The id of the trailer, which is also the filename of the trailer-image
	*/
	fileprivate final func updateTrailerButton(index: Int, trailerId: String) {
        if (index >= trailerStackView.arrangedSubviews.count) {
            return
        }
        
		guard let buttonToUpdate = trailerStackView.arrangedSubviews[index] as? UIButton else { return }
		guard let basePath = self.baseImagePath else { return }

		let trailerImageFilePath = basePath + Constants.trailerFolder + "/" + trailerId + ".jpg"
		
		guard let trailerImage = UIImage(contentsOfFile: trailerImageFilePath)?.cgImage else { return }

		let scaledImage = UIImage(cgImage: trailerImage, scale: 1.5, orientation: UIImageOrientation.up)

		DispatchQueue.main.async {
			buttonToUpdate.setImage(scaledImage, for: UIControlState())
		}
	}
	
	
	// MARK: - Show-Functions

	
	fileprivate final func showPoster()
	{
		posterImageView.image = self.movie?.thumbnailImage.0
		
		if let movie = self.movie , movie.thumbnailImage.1 {
			let rec = UITapGestureRecognizer(target: self, action: #selector(MovieViewController.thumbnailTapped(_:)))
			rec.numberOfTapsRequired = 1
			posterImageView.addGestureRecognizer(rec)
		}
	}
	
	fileprivate final func showTitles() {
		guard let movie = self.movie else { return }
		
		titleLabel?.text = movie.title[movie.currentCountry.languageArrayIndex]
			
		// show labels with subtitles
		
		var subtitleLabels = [subtitleText1, subtitleText2, subtitleText3]
		
		if let genreDict = movieTabBarController?.genreDict {
			for (index, subtitle) in movie.getSubtitleArray(genreDict: genreDict).enumerated() {
				subtitleLabels[index]?.text = subtitle
			}
			
			// hide unused labels
			
			for index in movie.getSubtitleArray(genreDict: genreDict).count ..< subtitleLabels.count {
				subtitleLabels[index]?.isHidden = true
			}
			
			// vertically "center" the labels
			let moveY = (subtitleLabels.count - movie.getSubtitleArray(genreDict: genreDict).count) * 19
			titleLabelTopSpaceConstraint.constant = CGFloat(moveY / 2) * -1 + 4
		}
	}

	fileprivate final func showRatings() {
		guard let movie = self.movie else { return }
	
		self.showRatingsFlag = (movie.ratingImdb != nil) || (movie.ratingTomato != nil) || (movie.ratingMetacritic != nil)
		
		if (self.showRatingsFlag) {
			setConstraintsToZero(constraints: line1VerticalSpaceConstraint, lineTopHeightConstraint /*, line2VerticalSpaceConstraint*/ )
			
			// IMDb rating
			
			imdbHeadlineLabel.text = NSLocalizedString("IMDbRating", comment: "")
			let numberFormatter = NumberFormatter()
			numberFormatter.numberStyle = NumberFormatter.Style.decimal
			numberFormatter.minimumFractionDigits = 1
			
			if let score = self.movie?.ratingImdb, let scoreString = numberFormatter.string(from: NSNumber(value: score)) {
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
				imdbRatingLabel.textColor = UIColor.darkGray
				imdbImageView.image = nil
				imdbImageViewWidthConstraint.constant = 0
			}
			
			// Rotten Tomatoes rating
			
			if let score = self.movie?.ratingTomato {
				tomatoesRatingLabel.text = "\(score)%"
				
				if let tomatoImageIndex = self.movie?.tomatoImage, let tomatoImage = TomatoImage(rawValue: tomatoImageIndex) {
					tomatoesImageView.image = UIImage.init(named: tomatoImage.filename)
				}
			}
			else {
				tomatoesRatingLabel.text = NSLocalizedString("Score unknown", comment: "")
				tomatoesRatingLabel.textColor = UIColor.darkGray
				tomatoesImageView.isHidden = true
				tomatoesImageViewWidthConstraint.constant = 0
			}
			
			// Metacritic rating
			
			if let score = self.movie?.ratingMetacritic {
				metascoreRatingLabel.text = "\(score)"
				
				switch score {
				case 0...39:
					// red score
					metascoreInnerView.backgroundColor = UIColor(red: 237.0/255.0, green: 12.0/255.0, blue: 25.0/255.0, alpha: 1.0)
					metascoreRatingLabel.textColor = UIColor.white
				case 40...60:
					// yellow score
					metascoreInnerView.backgroundColor = UIColor(red: 230.0/255.0, green: 225.0/255.0, blue: 49.0/255.0, alpha: 1.0)
					metascoreRatingLabel.textColor = UIColor.black
				default:
					// green score
					metascoreInnerView.backgroundColor = UIColor(red: 27.0/255.0, green: 184.0/255.0, blue: 31.0/255.0, alpha: 1.0)
					metascoreRatingLabel.textColor = UIColor.white
				}
			}
			else {
				metascoreRatingLabel.text = NSLocalizedString("Score unknown", comment: "")
				metascoreRatingLabel.textColor = UIColor.darkGray
				metascoreInnerView.backgroundColor = UIColor.clear
				metascoreRatingLabel.textColor = UIColor.black
			}
		}
		else {
			// hide all ratings stuff, because we have no ratings
			ratingStackView.isHidden = true
			setConstraintsToZero(constraints: ratingStackViewHeightConstraint, ratingStackViewVerticalSpaceConstraint,
								 line1VerticalSpaceConstraint, lineTopHeightConstraint)
		}
	}
	
	fileprivate final func showSynopsis() {
		guard let movie = self.movie else { return }
		
		let synopsisForLanguage = movie.synopsisForLanguage
		
		if (synopsisForLanguage.0.characters.count > 0) {
			storyHeadlineLabel.text = NSLocalizedString("Synopsis", comment: "") + ":"
			moreStoryButton.setTitle("▼  " + NSLocalizedString("ShowCompleteSynopsis", comment: "") + "  ▼",
			                         for: UIControlState())
			storyLabel.text = synopsisForLanguage.0
			
			if (synopsisForLanguage.1 != movie.currentCountry.languageArrayIndex) {
				// synopsis is english as fallback
				storyHeadlineLabel.text = NSLocalizedString("SynopsisEnglish", comment: "") + ":"
			}
		}
		else {
			// hide everything related to synopsis
			setConstraintsToZero(constraints: storyLabelTopSpaceConstraint, storyHeadlineLabelTopSpaceConstraint, lineStoryHeightConstraint)
			storyHeadlineLabel.addConstraint(NSLayoutConstraint(item: storyHeadlineLabel, attribute: NSLayoutAttribute.height,
				relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 0))
			storyLabel.addConstraint(NSLayoutConstraint(item: storyLabel, attribute: NSLayoutAttribute.height,
				relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 0))
		}
	}
	
	fileprivate final func showLinkButtons() {
		guard let movie = self.movie else { return }
		
		if (movie.imdbId != nil) {
			imdbButton.addTarget(self, action: #selector(MovieViewController.imdbButtonTapped(_:)), for: UIControlEvents.touchUpInside)
			imdbButton.setTitle(NSLocalizedString("ShowOnImdb", comment: ""), for: UIControlState())
		}
	}

	fileprivate final func showTrailers()	{
		guard let movie = self.movie else { return }
		trailerHeadlineLabel.text = NSLocalizedString("TrailerHeadline", comment: "") + ":"
		
		allTrailerIds = movie.trailerIds[movie.currentCountry.languageArrayIndex]
		
		if (movie.currentCountry.languageArrayIndex != MovieCountry.USA.languageArrayIndex) {
			allTrailerIds.append(contentsOf: movie.trailerIds[MovieCountry.USA.languageArrayIndex])
		}
		
		if (allTrailerIds.count == 0) {
			// no trailers: hide all related UI elements
			setConstraintsToZero(constraints: trailerStackViewVerticalSpaceConstraint, trailerHeadlineLabelVerticalSpaceConstraint)
			trailerHeadlineLabel.addConstraint(NSLayoutConstraint(item: trailerHeadlineLabel, attribute: NSLayoutAttribute.height,
				relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 0))
			return
		}
		
		guard let basePath = self.baseImagePath else { return }
		
		for (index, trailerId) in allTrailerIds.enumerated() {
			// try to load existing trailer-image
			let trailerImageFilePath = basePath + Constants.trailerFolder + "/" + trailerId + ".jpg"
			var trailerImage = UIImage(contentsOfFile: trailerImageFilePath)?.cgImage
			
			if (trailerImage == nil) {
				// trailer-image not found: use default-image
				trailerImage = UIImage(named: "YoutubeBack.png")?.cgImage
				
				// load the correct image from YouTube
				guard let sourceImageUrl = URL(string: "https://img.youtube.com/vi/" + trailerId + "/mqdefault.jpg") else { continue }
				
				let task = URLSession.shared.downloadTask(with: sourceImageUrl,
					completionHandler: { (location: URL?, response: URLResponse?, error: Error?) -> Void in
						
					if let error = error as? NSError {
						NSLog("Error getting poster from Youtube: \(error.localizedDescription)")
						log.error("Error getting poster from Youtube (\(error.code)): \(error.localizedDescription)")
					}
					else if let receivedPath = location?.path {
						// move received poster to target path where it belongs and update the button
						do {
							try FileManager.default.moveItem(atPath: receivedPath, toPath: trailerImageFilePath)
							self.updateTrailerButton(index: index, trailerId: trailerId)
						}
						catch let error as NSError {
							if ((error.domain == NSCocoaErrorDomain) && (error.code == NSFileWriteFileExistsError)) {
								// ignoring, because it's okay it it's already there
							}
							else {
								NSLog("Error moving trailer-poster: \(error.localizedDescription)")
								log.error("Error moving trailer-poster (\(error.code)): \(error.localizedDescription)")
							}
						}
					}
				})
				
				task.resume()
			}
			
			if let trailerImage = trailerImage {
				let scaledImage = UIImage(cgImage: trailerImage, scale: 1.5, orientation: UIImageOrientation.up)
				let button = UIButton()
				button.tag = Constants.tagTrailer + index
				button.setImage(scaledImage, for: UIControlState())
				button.contentMode = .scaleAspectFit
				button.addTarget(self, action: #selector(MovieViewController.trailerButtonTapped(_:)), for: UIControlEvents.touchUpInside)
				trailerStackView.addArrangedSubview(button)
			}
		}
		
		trailerStackView.layoutIfNeeded()
	}

	fileprivate final func shrinkStoryIfNeeded() {
		let numLinesOfStory = round(storyLabel.frame.height / storyLabel.font.lineHeight)
		
		if (numLinesOfStory > 9) {
			// set height to 8 lines and show button
			storyLabel.numberOfLines = 8
		}
		else {
			moreStoryButton.isHidden = true
			setConstraintsToZero(constraints: moreStoryButtonHeightConstraint, moreStoryButtonVerticalSpaceConstraint)
		}
	}
	
	
	// MARK: - SFSafariViewControllerDelegate

	
	func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
		controller.dismiss(animated: true, completion: nil)
	}
	
	
	// MARK: - Button callbacks

	
	final func imdbButtonTapped(_ sender: UIButton) {
		showImdbPage()
	}

	final func trailerButtonTapped(_ sender: UIButton) {
		
		guard let movie = movie else { return }
		
		// check if we open the youtube app or the webview
		let useApp: Bool? = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsUseYoutubeApp) as? Bool
		var trailerId: String?
		
		trailerId = allTrailerIds[sender.tag - Constants.tagTrailer]

		if let trailerId = trailerId {
			let url: URL? = URL(string: "https://www.youtube.com/v/\(trailerId)/")
			
			if let url = url , (useApp == true) && UIApplication.shared.canOpenURL(url) {
				// use the app instead of the webview
				UIApplication.shared.openURL(url)
			}
			else {
				guard let webUrl = URL(string: "https://www.youtube.com/watch?v=\(trailerId)&autoplay=1&o=U&noapp=1") else { return }
				let webVC = SFSafariViewController(url: webUrl)
				webVC.delegate = self
				self.present(webVC, animated: true, completion: nil)
			}
		}
		else {
			NSLog("No TrailerId for movie \(movie.origTitle)")
			return
		}
	}
	
	final func addFavoriteButtonTapped(_ sender:UIButton) {
		if let movie = movie {
			Favorites.addMovie(movie, tabBarController: movieTabBarController)
			setUpFavoriteButton()
			NotificationManager.updateFavoriteNotifications(favoriteMovies: movieTabBarController?.favoriteMovies)
		}
	}

	final func removeFavoriteButtonTapped(_ sender:UIButton) {
		if let movie = movie {
			Favorites.removeMovie(movie, tabBarController: movieTabBarController)
			setUpFavoriteButton()
			NotificationManager.updateFavoriteNotifications(favoriteMovies: movieTabBarController?.favoriteMovies)
		}
	}

	@IBAction func imdbRatingTapped(_ sender: UITapGestureRecognizer) {
		showImdbPage()
	}
	
	@IBAction func tomatoRatingTapped(_ sender: UITapGestureRecognizer) {
		if let urlString = movie?.tomatoURL {
			guard let webUrl = URL(string: urlString) else { return }
			let webVC = SFSafariViewController(url: webUrl)
			webVC.delegate = self
			self.present(webVC, animated: true, completion: nil)
		}
	}

	@IBAction func moreStoryButtonTapped(_ sender: AnyObject) {
		showCompleteStory = !showCompleteStory
		
		if (showCompleteStory) {
			moreStoryButton.setTitle("▲  " + NSLocalizedString("ShowShortSynopsis", comment: "") + "  ▲",
			                         for: UIControlState())
			storyLabel.numberOfLines = 0
		}
		else {
			moreStoryButton.setTitle("▼  " + NSLocalizedString("ShowCompleteSynopsis", comment: "") + "  ▼",
			                         for: UIControlState())
			storyLabel.numberOfLines = 8
		}
	}

	
	// MARK: - Helpers
	
	
	/**
		Sets the given constraint constant to 0.
	
		- parameter constraints: A number of NSLayoutConstraints to be set to 0
	*/
	fileprivate final func setConstraintsToZero(constraints: NSLayoutConstraint...) {
		for constraint in constraints {
			constraint.constant = 0
		}
	}

	fileprivate final func setUpFavoriteButton() {
		if let movie = movie {
			if (Favorites.IDs.contains(movie.id)) {
				// this movie is a favorite: show remove-button
				if let navigationController = navigationController, let topViewController = navigationController.topViewController {
					topViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "favorite.png"), style: UIBarButtonItemStyle.done, target: self, action: #selector(MovieViewController.removeFavoriteButtonTapped(_:)))
				}
			}
			else {
				// this movie is not a favorite: show add-button
				if let navigationController = navigationController, let topViewController = navigationController.topViewController {
					topViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "favoriteframe.png"), style: UIBarButtonItemStyle.done, target: self, action: #selector(MovieViewController.addFavoriteButtonTapped(_:)))
				}
			}
		}
	}

	fileprivate final func showImdbPage() {
		// check if we open the idmb app or the webview
		
		let useApp: Bool? = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsUseImdbApp) as? Bool
		
		if let imdbId = movie?.imdbId {
			let url: URL? = URL(string: "imdb:///title/\(imdbId)/")
			
			if let url = url , (useApp == true) && UIApplication.shared.canOpenURL(url) {
				// use the app instead of the webview
				UIApplication.shared.openURL(url)
			}
			else {
				// use the webview
				guard let webUrl = URL(string: "http://www.imdb.com/title/\(imdbId)") else { return }
				let webVC = SFSafariViewController(url: webUrl)
				webVC.delegate = self
				self.present(webVC, animated: true, completion: nil)
			}
		}
	}
	
	final func cropImage(_ inputImage: UIImage?) -> UIImage? {
		guard let inputImage = inputImage, let inputCgImage = inputImage.cgImage else { return nil }
		
		if let imageRef = inputCgImage.cropping(to: CGRect(x: 0, y: 0, width: 45, height: 60)) {
			return UIImage(cgImage: imageRef)
		}
		
		return nil
	}
}
