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

    final func configureTrailerLabel()
    {
        guard let movie = self.movie else { return }

        let numberOfTrailers = movie.trailerIds[MovieCountry.USA.languageArrayIndex].count +
            movie.trailerIds[MovieCountry.Germany.languageArrayIndex].count

        if (numberOfTrailers == 0)
        {
            self.trailerHeadlineLabel.removeFromSuperview()
            self.trailerStackView.removeFromSuperview()
            self.trailerSeparatorView.removeFromSuperview()
            self.trailerPaddingView.removeFromSuperview()
        }
        else if (numberOfTrailers == 1)
        {
            trailerHeadlineLabel.text = NSLocalizedString("TrailersSingular", comment: "")
        }
        else
        {
            trailerHeadlineLabel.text = NSLocalizedString("TrailersPlural", comment: "")
        }
    }

    
    func showTrailerLinks()
    {
        guard let basePath = self.baseImagePath else { return }
        guard let movie = self.movie else { return }
        let englishIDs = movie.trailerIds[MovieCountry.USA.languageArrayIndex]
        let germanIDs = movie.trailerIds[MovieCountry.Germany.languageArrayIndex]
        
        if ((englishIDs.count == 0) && (germanIDs.count == 0))
        {
            // no trailers: hide all related UI elements
            self.trailerStackView.removeFromSuperview()
            return
        }
        
        var showFlag = false

        if (movie.currentCountry.languageArrayIndex != MovieCountry.USA.languageArrayIndex)
        {
            // non-english country: show the little flag
            showFlag = true
        }

        var currentSubStackview: UIStackView?

        for (index, trailerId) in (englishIDs + germanIDs).enumerated()
        {
            if (index % 2 == 0)
            {
                // create new sub-stackview
                let subStackview = UIStackView()
                subStackview.axis = .horizontal
                subStackview.spacing = 10.0
                trailerStackView.addArrangedSubview(subStackview)
                currentSubStackview = subStackview
            }
            
            // try to load existing trailer-image
            let trailerImageFilePath = basePath + Constants.trailerFolder + "/" + trailerId + ".jpg"
            var trailerImage = UIImage(contentsOfFile: trailerImageFilePath)?.cgImage
            
            if (trailerImage == nil)
            {
                // trailer-image not found: use default-image
                trailerImage = UIImage(named: "no-trailer")?.cgImage
                
                // load the correct image from YouTube
                guard let sourceImageUrl = URL(string: "https://img.youtube.com/vi/" + trailerId + "/mqdefault.jpg") else { continue }
                
                let task = URLSession.shared.downloadTask(with: sourceImageUrl,
                                                          completionHandler:
                    {
                        [weak self] (location: URL?, response: URLResponse?, error: Error?) -> Void in
                        
                        if let location = location,
                           let weakSelf = self
                        {
                            weakSelf.youtubeImageDownloaded(location, error,
                                                            controller: weakSelf,
                                                            filepath: trailerImageFilePath,
                                                            trailerId: trailerId,
                                                            trailerIndex: index,
                                                            showFlag: showFlag)
                        }
                })
                
                task.resume()
            }

            if let trailerImage = trailerImage
            {
                let button = UIButton()
                button.tag = Constants.tagTrailers + index
                button.contentMode = .scaleAspectFit
                button.addTarget(self, action: #selector(MovieViewController.trailerButtonTapped(_:)), for: UIControl.Event.touchUpInside)
                setImage(trailerImage, withFlag: showFlag, toButton: button)
                currentSubStackview?.addArrangedSubview(button)
            }
        }
        
        trailerStackView.layoutIfNeeded()
    }
    
  
    fileprivate func youtubeImageDownloaded(_ location: URL,
                                            _ error: Error?,
                                            controller: MovieViewController,
                                            filepath: String,
                                            trailerId: String,
                                            trailerIndex: Int,
                                            showFlag: Bool) -> Void
    {
        if let error = error as NSError?
        {
            NSLog("Error getting poster from Youtube: \(error.localizedDescription)")
            return
        }

        // move received poster to target path where it belongs and update the button
        do
        {
            try FileManager.default.moveItem(atPath: location.path, toPath: filepath)
            controller.updateTrailerButton(index: trailerIndex,
                                           trailerId: trailerId,
                                           showFlag: showFlag)
        }
        catch let error as NSError
        {
            if ((error.domain == NSCocoaErrorDomain) && (error.code == NSFileWriteFileExistsError))
            {
                // ignoring, because it's okay it it's already there
            }
            else
            {
                NSLog("Error moving trailer-poster: \(error.localizedDescription)")
            }
        }
    }


    /**
        Updates a trailer button with a new image.

        - parameter index:		The index of the button inside the stackview
        - parameter trailerId:	The id of the trailer, which is also the filename of the trailer-image
    */
    final func updateTrailerButton(index: Int, trailerId: String, showFlag: Bool)
    {
        DispatchQueue.main.async
        {
            // find the button to update
            var foundButton: UIButton?
            
            outerLoop: for innerStackView in self.trailerStackView.arrangedSubviews
            {
                if let innerStackView = innerStackView as? UIStackView
                {
                    for button in innerStackView.arrangedSubviews
                    {
                        if button.tag == Constants.tagTrailers + index
                        {
                            foundButton = button as? UIButton
                            break outerLoop
                        }
                    }
                }
            }

            guard let buttonToUpdate = foundButton else { return }
            guard let basePath = self.baseImagePath else { return }
            
            let trailerImageFilePath = basePath + Constants.trailerFolder + "/" + trailerId + ".jpg"
            guard let trailerImage = UIImage(contentsOfFile: trailerImageFilePath)?.cgImage else { return }
            self.setImage(trailerImage, withFlag: showFlag, toButton: buttonToUpdate)
        }
    }


    @objc final func trailerButtonTapped(_ sender: UIButton)
    {
        guard let movie = self.movie else { return }

        let trailerIndex = sender.tag - Constants.tagTrailers
        var trailerId = ""

        if (trailerIndex < movie.trailerIds[MovieCountry.USA.languageArrayIndex].count)
        {
            // english trailer
            trailerId = movie.trailerIds[MovieCountry.USA.languageArrayIndex][trailerIndex]
        }
        else
        {
            // german trailer
            trailerId = movie.trailerIds[MovieCountry.Germany.languageArrayIndex][trailerIndex - movie.trailerIds[MovieCountry.USA.languageArrayIndex].count]
        }

        let useApp: Bool? =
            UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsUseYoutubeApp) as? Bool
        let url: URL? = URL(string: "youtube://\(trailerId)")

        if let url = url , (useApp == true) && UIApplication.shared.canOpenURL(url)
        {
            // use the app instead of the webview
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: { (Bool) in })
        }
        else
        {
            guard let webUrl = URL(string: "https://www.youtube.com/watch?v=\(trailerId)&autoplay=1&o=U&noapp=1") else { return }
            let webVC = RotatableSafariViewController(url: webUrl)
            webVC.delegate = self
            webVC.category = SafariCategory.Trailer
            self.present(webVC, animated: true, completion: nil)
        }
    }


    func setImage(_ image: CGImage, withFlag showFlag: Bool, toButton button: UIButton)
    {
        guard let movie = self.movie else { return }
        let scaleFactor = CGFloat(image.width) / ((self.view.frame.size.width - 2 * padding - self.linksStackView.spacing) / 2.0)
        let scaledImage = UIImage(cgImage: image, scale: scaleFactor, orientation: UIImage.Orientation.up)
        button.setImage(scaledImage, for: UIControl.State())
        
        if (showFlag)
        {
            var flagImageView: UIImageView?
            
            if (button.tag - Constants.tagTrailers < movie.trailerIds[MovieCountry.USA.languageArrayIndex].count)
            {
                // english flag
                flagImageView = UIImageView(image: UIImage(named: "usuk"))
            }
            else
            {
                // german flag
                flagImageView = UIImageView(image: UIImage(named: "germany"))
            }
            
            if let flagImageView = flagImageView
            {
                flagImageView.frame = CGRect(x: scaledImage.size.width - 34.0 - 8.0,
                                             y: 8.0,
                                             width: 34.0,
                                             height: 18.0)
                button.addSubview(flagImageView)
            }
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
