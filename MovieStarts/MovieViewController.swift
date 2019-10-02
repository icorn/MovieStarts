//
//  MovieViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 14.05.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit
import SafariServices


class MovieViewController: UIViewController, UIScrollViewDelegate, SFSafariViewControllerDelegate
{
	// outlets
    @IBOutlet weak var bigStackView: UIStackView!
	@IBOutlet weak var contentView: UIView!
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var posterImageView: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var subtitleText1: UILabel!
	@IBOutlet weak var subtitleText2: UILabel!
	@IBOutlet weak var subtitleText3: UILabel!
	@IBOutlet weak var infoHeadlineLabel: UILabel!
	@IBOutlet weak var actorHeadlineLabel: UILabel!
	@IBOutlet weak var storyLabel: UILabel!
	@IBOutlet weak var trailerHeadlineLabel: UILabel!
	@IBOutlet weak var trailerStackView: UIStackView!
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
    @IBOutlet weak var actorHorizontalView: UIView!
    @IBOutlet weak var actorScrollView: UIScrollView!
    @IBOutlet weak var actorContentView: UIView!
    @IBOutlet weak var imdbOuterView: UIView!
    @IBOutlet weak var tomatoesOuterView: UIView!
    @IBOutlet weak var metascoreOuterView: UIView!
    @IBOutlet weak var imdbInnerView: UIView!
    @IBOutlet weak var linksStackView: UIStackView!
    @IBOutlet weak var linksHeadlineLabel: UILabel!
    
    @IBOutlet weak var ratingSeparatorView: UIView!
    @IBOutlet weak var storySeparatorView: UIView!
    @IBOutlet weak var actorSeparatorView: UIView!
    @IBOutlet weak var actorPaddingView: UIView!
    @IBOutlet weak var infoSeparatorView: UIView!
    @IBOutlet weak var trailerSeparatorView: UIView!
    @IBOutlet weak var trailerPaddingView: UIView!
    
	// constraints
	@IBOutlet weak var posterImageTopSpaceConstraint: NSLayoutConstraint!
	@IBOutlet weak var titleLabelTopSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var actorScrollContentWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var actorScrollHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var imdbImageViewWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var tomatoesImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var linksStackViewHeightConstraint: NSLayoutConstraint!
    
    var movieTabBarController: TabBarController? {
        get {
            return navigationController?.parent as? TabBarController
        }
    }

	var movie: MovieRecord?
	var showRatingsFlag: Bool = false
	var baseImagePath: String?
	var showCompleteStory: Bool = false
	
    let padding: CGFloat = 16.0
    
	
	// MARK: - UIViewController
	
	override func viewDidLoad()
    {
		super.viewDidLoad()
		
		// start to show all movie details
		
		if let _ = movie
        {
			baseImagePath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.movieStartsGroup)?.path
				
            self.drawHairLineInViews(self.storySeparatorView, self.actorSeparatorView, self.infoSeparatorView, self.trailerSeparatorView)
            
			// show movie data
			showPoster()
			showTitles()
			showRatings()
			showSynopsis()
            showActors()
			showInfos()
			showLinkButtons()
            configureTrailerLabel()
            showTrailerLinks()
			setUpFavoriteButton()
			
			// shrink story label if needed
			
			view.layoutIfNeeded()
			shrinkStoryIfNeeded()
		}
	}
	
	override func viewDidAppear(_ animated: Bool)
    {
		super.viewDidAppear(animated)
		view.layoutIfNeeded()
        AnalyticsClient.trackScreenName("Detail Screen")
	}
	    

    // MARK: - Show-Functions

	
	fileprivate final func showPoster()
	{
		posterImageView.image = self.movie?.thumbnailImage.0
		
		if let movie = self.movie, movie.thumbnailImage.1
        {
			let rec = UITapGestureRecognizer(target: self, action: #selector(MovieViewController.posterThumbnailTapped(_:)))
			rec.numberOfTapsRequired = 1
			posterImageView.addGestureRecognizer(rec)
		}
	}
	
	fileprivate final func showTitles() {
		guard let movie = self.movie else { return }
		
		titleLabel?.text = movie.title[movie.currentCountry.languageArrayIndex]
			
		// show labels with subtitles
		
		let subtitleLabels = [subtitleText1, subtitleText2, subtitleText3]
		
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
        
		if (self.showRatingsFlag)
        {
			// IMDb rating
			
			imdbHeadlineLabel.text = NSLocalizedString("IMDbRating", comment: "")
			let numberFormatter = NumberFormatter()
			numberFormatter.numberStyle = NumberFormatter.Style.decimal
			numberFormatter.minimumFractionDigits = 1
			
			if let score = self.movie?.ratingImdb, let scoreString = numberFormatter.string(from: NSNumber(value: score)) {
				imdbRatingLabel.text =  "\(scoreString)"
				
				if (score >= 7.0) {
					imdbImageView.image = UIImage.init(named: "arrow-up")
				}
				else if (score < 6.0) {
					imdbImageView.image = UIImage.init(named: "arrow-down")
				}
				else {
					imdbImageView.image = UIImage.init(named: "arrow-medium")
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
			}
		}
		else
        {
			// hide all ratings stuff, because we have no ratings
            ratingStackView.removeFromSuperview()
            ratingSeparatorView.removeFromSuperview()
		}
	}
	
	fileprivate final func showSynopsis() {
		guard let movie = self.movie else { return }
		
		let synopsisForLanguage = movie.synopsisForLanguage
		
		if (synopsisForLanguage.0.count > 0)
        {
			moreStoryButton.setTitle("▼  " + NSLocalizedString("ShowCompleteSynopsis", comment: ""),
			                         for: UIControl.State())
			storyLabel.text = synopsisForLanguage.0
		}
		else
        {
			// hide everything related to synopsis
            self.storyLabel.removeFromSuperview()
            self.moreStoryButton.removeFromSuperview()
            self.storySeparatorView.removeFromSuperview()
		}
	}
	
	fileprivate final func showLinkButtons()
    {
		guard let movie = self.movie else { return }
        
        if (movie.imdbId != nil)
        {
            let imdbButton = UIImageView(image: UIImage(named: "imdb"))
            imdbButton.contentMode = UIView.ContentMode.scaleAspectFit
            imdbButton.isUserInteractionEnabled = true
            imdbButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MovieViewController.imdbButtonTapped(_:))))
            self.linksStackView.addArrangedSubview(imdbButton)
        }

        if (movie.tomatoURL != nil)
        {
            let tomatoButton = UIImageView(image: UIImage(named: "rotten-tomatoes"))
            tomatoButton.contentMode = UIView.ContentMode.scaleAspectFit
            tomatoButton.isUserInteractionEnabled = true
            tomatoButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MovieViewController.rottenTomatoesButtonTapped(_:))))
            self.linksStackView.addArrangedSubview(tomatoButton)
        }

        if (movie.tmdbId != nil) {
            let tmdbButton = UIImageView(image: UIImage(named: "tmdb"))
            tmdbButton.contentMode = UIView.ContentMode.scaleAspectFit
            tmdbButton.isUserInteractionEnabled = true
            tmdbButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MovieViewController.tmdbButtonTapped(_:))))
            self.linksStackView.addArrangedSubview(tmdbButton)
        }
      
        for _ in stride(from: 3, to: self.linksStackView.subviews.count, by: -1)
        {
            let dummyView = UIView()
            self.linksStackView.addArrangedSubview(dummyView)
        }
        
        // calculate neccessary height of stackview for ideal images
        
        let imageWidth = (self.view.frame.size.width - 2 * padding - 2 * self.linksStackView.spacing) / 3.0
        let imageHeight = imageWidth * 0.475
        self.linksStackViewHeightConstraint.constant = imageHeight
	}

	fileprivate final func shrinkStoryIfNeeded()
    {
		let numLinesOfStory = round(storyLabel.frame.height / storyLabel.font.lineHeight)
		
		if (numLinesOfStory > 9)
        {
			// set height to 8 lines and show button
			storyLabel.numberOfLines = 8
		}
		else
        {
            self.moreStoryButton.removeFromSuperview()
		}
	}
	
	
	// MARK: - SFSafariViewControllerDelegate

	
	func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
		controller.dismiss(animated: true, completion: nil)
	}
	
	
	// MARK: - Button callbacks

	
	@objc final func imdbButtonTapped(_ sender: UIButton) {
		showImdbPage()
	}

    @objc final func rottenTomatoesButtonTapped(_ sender: UIButton) {
        if let tomatoURLString = movie?.tomatoURL {
            guard let webUrl = URL(string: tomatoURLString) else { return }
            let webVC = RotatableSafariViewController(url: webUrl)
            webVC.delegate = self
            webVC.category = SafariCategory.RottenTomatoes
            self.present(webVC, animated: true, completion: nil)
        }
    }
    
    @objc final func tmdbButtonTapped(_ sender: UIButton) {
        guard let tmdbId = movie?.tmdbId else { return }
        guard let tmdbURL = URL(string: "http://themoviedb.org/movie/\(tmdbId)") else { return }

        let webVC = RotatableSafariViewController(url: tmdbURL)
        webVC.delegate = self
        webVC.category = SafariCategory.TMDb
        self.present(webVC, animated: true, completion: nil)
    }
    
	@objc final func addFavoriteButtonTapped(_ sender:UIButton) {
		if let movie = movie {
			Favorites.addMovie(movie, tabBarController: movieTabBarController)
			setUpFavoriteButton()
			NotificationManager.updateFavoriteNotifications(favoriteMovies: movieTabBarController?.favoriteMovies)
		}
	}

	@objc final func removeFavoriteButtonTapped(_ sender:UIButton) {
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
			let webVC = RotatableSafariViewController(url: webUrl)
			webVC.delegate = self
            webVC.category = SafariCategory.RottenTomatoes
			self.present(webVC, animated: true, completion: nil)
		}
	}

	@IBAction func moreStoryButtonTapped(_ sender: AnyObject)
    {
		showCompleteStory = !showCompleteStory
		
		if (showCompleteStory)
        {
			moreStoryButton.setTitle("▲  " + NSLocalizedString("ShowShortSynopsis", comment: ""),
			                         for: UIControl.State())
/*
            UIView.animate(withDuration: 0.1,
                           delay: 0.0,
                           options: UIViewAnimationOptions.curveEaseOut,
                           animations:
                {
*/
                    self.storyLabel.numberOfLines = 0
/*
                    self.storyLabel.sizeToFit()
                    self.view.layoutIfNeeded()
                }
            )
*/
		}
		else
        {
			moreStoryButton.setTitle("▼  " + NSLocalizedString("ShowCompleteSynopsis", comment: ""),
			                         for: UIControl.State())
/*
            UIView.animate(withDuration: 0.1,
                           delay: 0.0,
                           options: UIViewAnimationOptions.curveEaseOut,
                           animations:
                {
*/
                    self.storyLabel.numberOfLines = 8
/*
                    self.view.layoutIfNeeded()
                }
            )
*/
		}
	}

	
	// MARK: - Helpers
		
	final func setConstraintsToZero(_ constraints: NSLayoutConstraint...)
    {
		for constraint in constraints
        {
			constraint.constant = 0
		}
	}

    final func setConstraintsToZero(_ constraints: [NSLayoutConstraint])
    {
        for constraint in constraints
        {
            constraint.constant = 0
        }
    }
    
    final func drawHairLineInViews(_ views: UIView...)
    {
        for view in views
        {
            let line = UIView(frame: CGRect(x: 0.0, y: 10.0, width: UIScreen.main.bounds.size.width, height: 1.0 / UIScreen.main.scale))
            line.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
            view.addSubview(line)
            view.clipsToBounds = true
        }
    }

	fileprivate final func setUpFavoriteButton()
    {
		if let movie = movie
        {
			if (Favorites.IDs.contains(movie.id))
            {
				// this movie is a favorite: show remove-button
				if let navigationController = navigationController, let topViewController = navigationController.topViewController
                {
					topViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "favorite"), style: UIBarButtonItem.Style.done, target: self, action: #selector(MovieViewController.removeFavoriteButtonTapped(_:)))
				}
			}
			else
            {
				// this movie is not a favorite: show add-button
				if let navigationController = navigationController, let topViewController = navigationController.topViewController
                {
					topViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "favorite-frame"), style: UIBarButtonItem.Style.done, target: self, action: #selector(MovieViewController.addFavoriteButtonTapped(_:)))
				}
			}
		}
	}

	fileprivate final func showImdbPage() {
		// check if we open the idmb app or the webview
		
		let useApp: Bool? = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsUseImdbApp) as? Bool
		
		if let imdbId = movie?.imdbId {
			let url: URL? = URL(string: "imdb:///title/\(imdbId)/")
			
			if let url = url , (useApp == true) && UIApplication.shared.canOpenURL(url)
            {
				// use the app instead of the webview
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: { (Bool) in })
			}
			else
            {
				// use the webview
				guard let webUrl = URL(string: "http://www.imdb.com/title/\(imdbId)") else { return }
				let webVC = RotatableSafariViewController(url: webUrl)
				webVC.delegate = self
                webVC.category = SafariCategory.IMDb
				self.present(webVC, animated: true, completion: nil)
			}
		}
	}
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
