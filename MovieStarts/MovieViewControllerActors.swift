//
//  MovieViewControllerActorStackview.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 13.07.16.
//  Copyright © 2016 Oliver Eichhorn. All rights reserved.
//

import Foundation
import UIKit


extension MovieViewController {

	final func showActors() {
		guard let movie = self.movie else { return }
		
		if (movie.actors.count > 0) {
			actorHeadlineLabel.text = NSLocalizedString("Actors", comment: "") + ":"
			
			for actorIndex in 0...movie.actors.count-1 {
				addActorToStackView(actorIndex: actorIndex, hidden: actorIndex > 4)
			}
			
			if (movie.actors.count > 5) {
				addShowAllActorsButtonToStackView()
			}
		}
		else {
			// no actors
			
			// TODO
			
		}
	}
	
	fileprivate final func addShowAllActorsButtonToStackView() {
		let showAllActorsButton = UIButton()
		showAllActorsButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
		showAllActorsButton.setTitle("▼  " + NSLocalizedString("ShowAllActors", comment: "") + "  ▼", for: UIControlState())
		showAllActorsButton.setTitleColor(UIColor(red: 0.0, green: 170.0/255.0, blue: 170.0/255.0, alpha: 1.0),
		                                  for: UIControlState())
		showAllActorsButton.setTitleColor(UIColor(red: 0.0, green: 120.0/255.0, blue: 120.0/255.0, alpha: 1.0),
		                                  for: UIControlState.highlighted)
		showAllActorsButton.addTarget(self, action: #selector(MovieViewController.showAllActorsButtonPressed(_:)),
		                              for: UIControlEvents.touchUpInside)
		actorStackView.addArrangedSubview(showAllActorsButton)
	}
	
	fileprivate final func addShowLessActorsButtonToStackView() {
		let showLessActorsButton = UIButton()
		showLessActorsButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
		showLessActorsButton.setTitle("▲  " + NSLocalizedString("ShowLessActors", comment: "") + "  ▲", for: UIControlState())
		showLessActorsButton.setTitleColor(UIColor(red: 0.0, green: 170.0/255.0, blue: 170.0/255.0, alpha: 1.0),
		                                   for: UIControlState())
		showLessActorsButton.setTitleColor(UIColor(red: 0.0, green: 120.0/255.0, blue: 120.0/255.0, alpha: 1.0),
		                                   for: UIControlState.highlighted)
		showLessActorsButton.addTarget(self, action: #selector(MovieViewController.showLessActorsButtonPressed(_:)),
		                               for: UIControlEvents.touchUpInside)
		actorStackView.addArrangedSubview(showLessActorsButton)
	}
	
	fileprivate final func addActorToStackView(actorIndex: Int, hidden: Bool) {
		guard let movie = self.movie else { return }
		
		// actor thumbnail
		
		let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
		imageView.contentMode = UIViewContentMode.scaleAspectFill
		imageView.image = UIImage(named: "welcome")
		
		guard let basePath = self.baseImagePath else { return }
		
		if (movie.profilePictures[actorIndex].characters.count > 0) {
			
			let actorImageFilePath = basePath + Constants.actorThumbnailFolder + movie.profilePictures[actorIndex]
			imageView.image = self.cropImage(UIImage(contentsOfFile: actorImageFilePath))
			
			if (imageView.image == nil) {
				// actor-image not found: use default-image
				imageView.image = UIImage(named: "welcome")
				
				// load the correct image from YouTube
				guard let sourceImageUrl = URL(string: "http://image.tmdb.org/t/p/w45" + movie.profilePictures[actorIndex]) else {
					return
				}
				
				let task = URLSession.shared.downloadTask(with: sourceImageUrl, completionHandler: { (location: URL?, response: URLResponse?, error: Error?) -> Void in
					
					if let error = error {
						NSLog("Error getting actor thumbnail: \(error.localizedDescription)")
					}
					else if let receivedPath = location?.path {
						// move received poster to target path where it belongs and update the button
						do {
							try FileManager.default.moveItem(atPath: receivedPath, toPath: actorImageFilePath)
							imageView.image = self.cropImage(UIImage(contentsOfFile: actorImageFilePath))
						}
						catch let error as NSError {
							if ((error.domain == NSCocoaErrorDomain) && (error.code == NSFileWriteFileExistsError)) {
								// ignoring, because it's okay it it's already there
							}
							else {
								NSLog("Error moving actor thumbnail: \(error.localizedDescription)")
							}
						}
					}
				})
				
				task.resume()
			}
		}
		
		let actorNameLabel = UILabel()
		actorNameLabel.text = movie.actors[actorIndex]
		actorNameLabel.font = UIFont.systemFont(ofSize: 14.0)
		
		let innerStackView = UIStackView(arrangedSubviews: [actorNameLabel])
		innerStackView.axis = .vertical
		innerStackView.alignment = UIStackViewAlignment.leading
		innerStackView.distribution = UIStackViewDistribution.fill
		innerStackView.spacing = 0
		
		if (movie.characters[actorIndex].characters.count > 0) {
			let characterNameLabel = UILabel()
			characterNameLabel.text = NSLocalizedString("ActorAs", comment: "") + " " + movie.characters[actorIndex]
			characterNameLabel.font = UIFont.systemFont(ofSize: 12.0)
			innerStackView.addArrangedSubview(characterNameLabel)
		}
		
		let outerStackView = UIStackView(arrangedSubviews: [imageView, innerStackView])
		outerStackView.axis = .horizontal
		outerStackView.alignment = UIStackViewAlignment.center
		outerStackView.distribution = UIStackViewDistribution.fill
		outerStackView.spacing = 8
		outerStackView.isHidden = hidden
		
		actorStackView.addArrangedSubview(outerStackView)
	}
	
	
	// MARK: - Button callbacks

	
	func showAllActorsButtonPressed(_ sender: UIButton!) {
		guard let movie = self.movie else { return }
		
		UIView.animate(withDuration: 0.2, animations: {
			for actorIndex in 5...movie.actors.count-1 {
				self.actorStackView.arrangedSubviews[actorIndex].isHidden = false
			}
			}, completion: { (_) in
				self.actorStackView.removeLastArrangedSubView()
				self.addShowLessActorsButtonToStackView()
		})
	}
	
	func showLessActorsButtonPressed(_ sender: UIButton!) {
		guard let movie = self.movie else { return }
		
		UIView.animate(withDuration: 0.2, animations: {
			for actorIndex in 5...movie.actors.count-1 {
				self.actorStackView.arrangedSubviews[actorIndex].isHidden = true
			}
			}, completion: { (_) in
				self.actorStackView.removeLastArrangedSubView()
				self.addShowAllActorsButtonToStackView()
		})
	}
	

}
