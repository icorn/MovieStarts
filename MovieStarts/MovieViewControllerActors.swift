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
			actorHeadlineLabel.text = NSLocalizedString("Actors", comment: "")
			
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
		showAllActorsButton.setTitle("▼  " + NSLocalizedString("ShowAllActors", comment: ""), for: UIControlState())
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
		showLessActorsButton.setTitle("▲  " + NSLocalizedString("ShowLessActors", comment: ""), for: UIControlState())
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

        let actorView = ActorView()
        actorView.setupWithActor(movie.actors[actorIndex],
                                 characterName: movie.characters[actorIndex],
                                 profilePicture: movie.profilePictures[actorIndex],
                                 hidden: hidden)
        self.actorStackView.addArrangedSubview(actorView)
	}
	
	
	// MARK: - Button callbacks

	
	func showAllActorsButtonPressed(_ sender: UIButton!) {
		guard let movie = self.movie else { return }

        for actorIndex in 5...movie.actors.count-1 {
            self.actorStackView.arrangedSubviews[actorIndex].alpha = 1.0
            (self.actorStackView.arrangedSubviews[actorIndex] as? ActorView)?.imageView?.frame =
                CGRect(x: ActorView.imageSize/2, y: ActorView.imageSize/2, width: 0, height: 0)
        }

		UIView.animate(
            withDuration: 0.2,
            animations: {
                for actorIndex in 5...movie.actors.count-1 {
                    self.actorStackView.arrangedSubviews[actorIndex].isHidden = false
                    (self.actorStackView.arrangedSubviews[actorIndex] as? ActorView)?.imageView?.frame =
                        CGRect(x: 0, y: 0, width: ActorView.imageSize, height: ActorView.imageSize)
                }
            },
		    completion: { (_) in
                self.actorStackView.removeLastArrangedSubView()
                self.addShowLessActorsButtonToStackView()
            }
        )
	}
	
	func showLessActorsButtonPressed(_ sender: UIButton!) {
		guard let movie = self.movie else { return }
		
		UIView.animate(
            withDuration: 0.2,
            animations: {
                for actorIndex in 5...movie.actors.count-1 {
                    self.actorStackView.arrangedSubviews[actorIndex].isHidden = true
                    self.actorStackView.arrangedSubviews[actorIndex].alpha = 0.0
                }
			},
            completion: { (_) in
				self.actorStackView.removeLastArrangedSubView()
				self.addShowAllActorsButtonToStackView()
            }
        )
	}
}

