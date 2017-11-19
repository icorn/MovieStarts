//
//  MovieViewControllerTrailers.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 23.09.16.
//  Copyright © 2016 Oliver Eichhorn. All rights reserved.
//

import Foundation
import UIKit


extension MovieViewController {

    final func configureTrailerLabel() {
        guard let movie = self.movie else { return }

        let numberOfTrailers = movie.trailerIds[MovieCountry.USA.languageArrayIndex].count +
            movie.trailerIds[MovieCountry.Germany.languageArrayIndex].count

        if (numberOfTrailers == 0) {
            setConstraintsToZero(trailerHeadlineLabelVerticalSpaceConstraint)
            trailerHeadlineLabel.addConstraint(
                NSLayoutConstraint(item: trailerHeadlineLabel,
                                   attribute: NSLayoutAttribute.height,
                                   relatedBy: NSLayoutRelation.equal,
                                   toItem: nil,
                                   attribute: NSLayoutAttribute.notAnAttribute,
                                   multiplier: 1.0,
                                   constant: 0))
        }
        else if (numberOfTrailers == 1) {
            trailerHeadlineLabel.text = NSLocalizedString("TrailersSingular", comment: "")
        }
        else {
            trailerHeadlineLabel.text = NSLocalizedString("TrailersPlural", comment: "")
        }
    }


    final func showTrailersIn(_ stackview: UIStackView,
                              spaceConstraint: NSLayoutConstraint,
                              trailerIDs: [String],
                              tagStart: Int){

        if (trailerIDs.count == 0) {
            // no trailers: hide all related UI elements
            setConstraintsToZero(spaceConstraint)
            return
        }

        guard let basePath = self.baseImagePath else { return }
        guard let movie = self.movie else { return }

        var showFlag = false

        if (movie.currentCountry.languageArrayIndex != MovieCountry.USA.languageArrayIndex) {
            // non-english country: show the little flag
            showFlag = true
        }

        for (index, trailerId) in trailerIDs.enumerated() {
            // try to load existing trailer-image
            let trailerImageFilePath = basePath + Constants.trailerFolder + "/" + trailerId + ".jpg"
            var trailerImage = UIImage(contentsOfFile: trailerImageFilePath)?.cgImage

            if (trailerImage == nil) {
                // trailer-image not found: use default-image
                trailerImage = UIImage(named: "no-trailer")?.cgImage

                // load the correct image from YouTube
                guard let sourceImageUrl = URL(string: "https://img.youtube.com/vi/" + trailerId + "/mqdefault.jpg") else { continue }

                let task = URLSession.shared.downloadTask(with: sourceImageUrl,
                            completionHandler: {
                                [unowned self] (location: URL?, response: URLResponse?, error: Error?) -> Void in
                                self.youtubeImageDownloaded(location, response, error, stackview,
                                                            controller: self,
                                                            filepath: trailerImageFilePath,
                                                            trailerId: trailerId,
                                                            trailerIndex: index,
                                                            showFlag: showFlag)
                            })

                task.resume()
            }
            
            if let trailerImage = trailerImage {
                let scaledImage = UIImage(cgImage: trailerImage, scale: 1.5, orientation: UIImageOrientation.up)
                let button = UIButton()
                button.tag = tagStart + index
                button.setImage(scaledImage, for: UIControlState())
                button.contentMode = .scaleAspectFit
                button.addTarget(self, action: #selector(MovieViewController.trailerButtonTapped(_:)), for: UIControlEvents.touchUpInside)
                if (showFlag) {
                    addFlagToButton(button)
                }
                stackview.addArrangedSubview(button)
            }
        }
        
        stackview.layoutIfNeeded()
    }


    fileprivate func youtubeImageDownloaded(_ location: URL?,
                                            _ response: URLResponse?,
                                            _ error: Error?,
                                            _ stackview: UIStackView,
                                            controller: MovieViewController,
                                            filepath: String,
                                            trailerId: String,
                                            trailerIndex: Int,
                                            showFlag: Bool) -> Void {

        if let error = error as NSError? {
            NSLog("Error getting poster from Youtube: \(error.localizedDescription)")
        }
        else if let receivedPath = location?.path {
            // move received poster to target path where it belongs and update the button
            do {
                try FileManager.default.moveItem(atPath: receivedPath, toPath: filepath)
                controller.updateTrailerButton(index: trailerIndex,
                                               trailerId: trailerId,
                                               stackview: stackview,
                                               showFlag: showFlag)
            }
            catch let error as NSError {
                if ((error.domain == NSCocoaErrorDomain) && (error.code == NSFileWriteFileExistsError)) {
                    // ignoring, because it's okay it it's already there
                }
                else {
                    NSLog("Error moving trailer-poster: \(error.localizedDescription)")
                }
            }
        }
    }


    /**
        Updates a trailer button with a new image.

        - parameter index:		The index of the button inside the stackview
        - parameter trailerId:	The id of the trailer, which is also the filename of the trailer-image
    */
    final func updateTrailerButton(index: Int, trailerId: String, stackview: UIStackView, showFlag: Bool) {
        DispatchQueue.main.async {
            if (index >= stackview.arrangedSubviews.count) {
                return
            }

            guard let buttonToUpdate = stackview.arrangedSubviews[index] as? UIButton else { return }
            guard let basePath = self.baseImagePath else { return }

            let trailerImageFilePath = basePath + Constants.trailerFolder + "/" + trailerId + ".jpg"

            guard let trailerImage = UIImage(contentsOfFile: trailerImageFilePath)?.cgImage else { return }

            let scaledImage = UIImage(cgImage: trailerImage, scale: 1.5, orientation: UIImageOrientation.up)
            buttonToUpdate.setImage(scaledImage, for: UIControlState())

            if (showFlag) {
                self.addFlagToButton(buttonToUpdate)
            }
        }
    }


    @objc final func trailerButtonTapped(_ sender: UIButton) {
        guard let movie = self.movie else { return }

        var trailerId = ""

        if (sender.tag >= Constants.tagTrailerGerman) {
            // german trailer
            trailerId = movie.trailerIds[MovieCountry.Germany.languageArrayIndex][sender.tag - Constants.tagTrailerGerman]
        }
        else {
            // english trailer
            trailerId = movie.trailerIds[MovieCountry.USA.languageArrayIndex][sender.tag - Constants.tagTrailerEnglish]
        }

        let useApp: Bool? =
            UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsUseYoutubeApp) as? Bool
        let url: URL? = URL(string: "youtube://\(trailerId)")

        if let url = url , (useApp == true) && UIApplication.shared.canOpenURL(url) {
            // use the app instead of the webview
            UIApplication.shared.openURL(url)
        }
        else {
            guard let webUrl = URL(string: "https://www.youtube.com/watch?v=\(trailerId)&autoplay=1&o=U&noapp=1") else { return }
            let webVC = RotatableSafariViewController(url: webUrl)
            webVC.delegate = self
            self.present(webVC, animated: true, completion: nil)
        }
    }


    final func addFlagToButton(_ button: UIButton) {
        var flagImageView: UIImageView?

        if (button.tag >= Constants.tagTrailerGerman) {
            // german flag
            flagImageView = UIImageView(image: UIImage(named: "germany"))
        }
        else {
            // english flag
            flagImageView = UIImageView(image: UIImage(named: "imdb"))
        }

        if let flagImageView = flagImageView {
            flagImageView.frame = CGRect(x: 176.0, y: 8.0, width: 30, height: 18)
            button.addSubview(flagImageView)
        }
    }
}
