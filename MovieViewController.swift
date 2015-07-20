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
	@IBOutlet weak var certificateImageView: UIImageView!
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
	@IBOutlet weak var contentViewWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var certificateImageHeightConstraint: NSLayoutConstraint!
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
	
	var bigPosterView: UIImageView?
	var movie: MovieRecord?
	var textButtons = [UIButton]()
	var bottomButton: UIButton?
	var certificationDict: [String: CertificateLogo] = [
		"R" 	: CertificateLogo(filename: "certificateR.png", height: 30),
		"G" 	: CertificateLogo(filename: "certificateG.png", height: 30),
		"PG" 	: CertificateLogo(filename: "certificatePG.png", height: 30),
		"PG-13" : CertificateLogo(filename: "certificatePG-13.png", height: 30),
		"NC-17" : CertificateLogo(filename: "certificateNC-17.png", height: 30)
	]


	override func viewDidLoad() {
		super.viewDidLoad()

		println("view: \(view.frame), scrollview: \(scrollView.frame), content: \(contentView.frame)" )
		
		contentViewWidthConstraint.constant = view.frame.width
		
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
			
			if let saveDate = saveMovie.releaseDate {
				releaseDateLabel?.text = saveMovie.releaseDateString
			}
			else {
				// no release date (cannot happen)
				releaseDateLabel?.text = "-"
			}
			
			// show rating

			if (saveMovie.voteAverage > 0.1) {
				var numberFormatter = NSNumberFormatter()
				numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
				numberFormatter.minimumFractionDigits = 1

				var voteAverage = numberFormatter.stringFromNumber(saveMovie.voteAverage)
				var voteMaximum = numberFormatter.stringFromNumber(10.0)

				if let saveVoteAverage = voteAverage, saveVoteMaximum = voteMaximum {
					ratingLabel?.text = "\(saveVoteAverage) / \(saveVoteMaximum)"
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
			
			// show certificate
			
			var certificationImageName: String?
			
			if let saveCertification = saveMovie.certification, saveDict = certificationDict[saveCertification] {
				certificationImageName = saveDict.filename
				certificateImageHeightConstraint.constant = CGFloat(saveDict.height)
			}
			
			if let saveImageName = certificationImageName {
				certificateImageView?.image = UIImage(named: saveImageName)
			}
			else {
				// no valid image name for the certification found
				certificateImageView?.image = UIImage(named: "certificateNR.png")
				certificateImageHeightConstraint.constant = 30
			}
			
			// show director(s)
			
			if (saveMovie.directors.count > 0) {
				for index in 0...saveMovie.directors.count-1 {
					directorLabels[index].text = saveMovie.directors[index]
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
			
			if (saveMovie.actors.count > 0) {
				for index in 0...saveMovie.actors.count-1 {
					actorLabels[index].text = saveMovie.actors[index]
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
			
			if let synopsis = saveMovie.synopsis {
				storyLabel.text = synopsis
			}

			// show textbuttons for imdb, trailers, and favorites
			
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
			
			textButtons[textButtonIndex].addTarget(self, action: Selector("favoriteButtonTapped:"), forControlEvents: UIControlEvents.TouchUpInside)
			textButtons[textButtonIndex].setTitle(NSLocalizedString("AddToFavorites", comment: ""), forState: UIControlState.Normal)
			textButtonIndex++

			// hide unused button(s)
			
			for (var hideId = textButtonIndex; hideId < textButtons.count; hideId++) {
				textButtons[hideId].hidden = true
				buttonLines[hideId-1].hidden = true
			}
			
			bottomButton = textButtons[textButtonIndex-1]
			
			updateViewConstraints()
		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		if let navBarHeight = navigationController?.navigationBar.frame.height {
			// Move the content down a bit: the height of the navbar plus the height of the status bar plus 20 (looks nicer).
			// This is necessary, because both the status bar and the navbar are transparent.
			
//			posterImageTopSpaceConstraint.constant = 20 + navBarHeight + UIApplication.sharedApplication().statusBarFrame.size.height
		}
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		// Set the height of ohe content size of the scrollview.
/*
		let value = UIInterfaceOrientation.Portrait.rawValue
		UIDevice.currentDevice().setValue(value, forKey: "orientation")
*/
		
		if let maxY = bottomButton?.frame.maxY {
			scrollView.contentSize = CGSize(width: scrollView.frame.width, height: maxY + 30)
		}

		println("view: \(view.frame), scrollview: \(scrollView.frame), content: \(contentView.frame) ENDE" )
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	
	// MARK: Button callbacks
	
	func imdbButtonTapped(sender:UIButton!) {
		var webViewController = storyboard?.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
		
		if let saveImdbId = movie?.imdbId {
			webViewController.urlString = "http://www.imdb.com/title/\(saveImdbId)"
			navigationController?.pushViewController(webViewController, animated: true)
		}
	}

	func trailerButtonTapped(sender:UIButton!) {
		
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
		
		var webViewController = storyboard?.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController

		if let trailerId = movie?.trailerIds[index] {
			webViewController.urlString = "http://www.youtube.com/watch?v=\(trailerId)&autoplay=1"
			navigationController?.pushViewController(webViewController, animated: true)
		}

	}
	
	func favoriteButtonTapped(sender:UIButton!) {
		// TODO
	}
	
	
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

/*
	override func supportedInterfaceOrientations() -> Int {
		return Int(UIInterfaceOrientationMask.Portrait.rawValue)
	}
*/
	
	
	// MARK: Helpers
	
	private final func setConstraintsToZero(constraints: NSLayoutConstraint...) {
		for constraint in constraints {
			constraint.constant = 0
		}
	}
}
