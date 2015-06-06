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
	
	@IBOutlet weak var posterImageView: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var runtimeCountriesLabel: UILabel!
	@IBOutlet weak var genresLabel: UILabel!
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
	
	// constraints
	
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
	
	
	var movie: MovieRecord?
	var actorLabels: [UILabel] = []
	var directorLabels: [UILabel] = []
	var certificationDict: [String: CertificateLogo] = [
		"R" 	: CertificateLogo(filename: "certificateR.png", height: 30),
		"G" 	: CertificateLogo(filename: "certificateG.png", height: 30),
		"PG" 	: CertificateLogo(filename: "certificatePG.png", height: 30),
		"PG-13" : CertificateLogo(filename: "certificatePG-13.png", height: 30),
		"NC-17" : CertificateLogo(filename: "certificateNC-17.png", height: 30)
	]
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		actorLabels = [actorLabel1, actorLabel2, actorLabel3, actorLabel4, actorLabel5]
		directorLabels = [directorLabel, directorLabel2]
		
		if let saveMovie = movie {
			
			// fill labels
			
			titleLabel?.text = saveMovie.title
			runtimeCountriesLabel?.text = MovieStartsUtil.generateDetailSubtitle(saveMovie)
			genresLabel?.text = MovieStartsUtil.generateGenreString(saveMovie)
			
			// show release date
			
			if let saveDate = saveMovie.releaseDate {
				var dateFormatter = NSDateFormatter()
				dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
				dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
				releaseDateLabel?.text = dateFormatter.stringFromDate(saveDate)
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
			
			updateViewConstraints()
		}
	}

	override func viewDidAppear(animated: Bool) {
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	private final func setConstraintsToZero(constraints: NSLayoutConstraint...) {
		for constraint in constraints {
			constraint.constant = 0
		}
	}
}
