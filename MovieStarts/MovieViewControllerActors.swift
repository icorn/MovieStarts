//
//  MovieViewControllerActors.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 13.07.16.
//  Copyright © 2016 Oliver Eichhorn. All rights reserved.
//

import Foundation
import UIKit

extension MovieViewController
{
    var actorThumbnailSize: CGSize
    {
        get
        {
            switch (UIScreen.main.bounds.size.width)
            {
                case 320.0:
                    // small phones (iPhone SE)
                    return CGSize(width: 75.0, height: 100.0)
                case 375.0:
                    // medium phones (iPhone 7, iPhone 8, iPhone X)
                    return CGSize(width: 76.0, height: 101.0)
                default:
                    // large phones (iPhone 7 Plus, iPhone 8 Plus)
                    return CGSize(width: 84.0, height: 112.0)
            }
        }
    }
    
    final func showActors()
    {
        guard let movie = self.movie else { return }
        
        if (movie.actors.count < 1)
        {
            self.actorHeadlineLabel.removeFromSuperview()
            self.actorHorizontalView.removeFromSuperview()
            self.actorSeparatorView.removeFromSuperview()
            self.actorPaddingView.removeFromSuperview()
            return
        }
        
        let hGap: CGFloat = 3.0
        let vGap: CGFloat = 3.0
        let bottomGap: CGFloat = 6.0
        var maxLabelHeight: CGFloat = 0.0

        for (index, actorName) in movie.actors.enumerated()
        {
            // image view
            
            let imageView = UIImageView(frame: CGRect(x: (actorThumbnailSize.width + hGap) * CGFloat(index),
                                                      y: 0.0,
                                                      width: actorThumbnailSize.width,
                                                      height: actorThumbnailSize.height))
            imageView.contentMode = .scaleToFill
            imageView.image = UIImage(named: "no-actor")

            if let actorFilePath = getActorFilePathForActorWithIndex(index)
            {
                if let profileImageFromFile = UIImage(contentsOfFile: actorFilePath)
                {
                    // profile image already downloaded: use it
                    imageView.image = self.cropImageToProperHeight(profileImageFromFile)
                }
                else
                {
                    // profile image must be downloaded
                    self.downloadProfilePicture(movie.profilePictures[index], fromPath: actorFilePath, andShowItInImageView: imageView)
                }
            }
            
            self.actorContentView.addSubview(imageView)
            
            let rec = UITapGestureRecognizer(target: self, action: #selector(MovieViewController.actorThumbnailTapped(_:)))
            rec.numberOfTapsRequired = 1
            imageView.tag = index
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(rec)

            // label
            
            let label = UILabel()
            label.numberOfLines = 0
            label.font = UIFont.systemFont(ofSize: 11.0)
            label.attributedText = NSAttributedString(string: actorName, attributes: [NSAttributedString.Key.kern: -0.3])
            label.textAlignment = .center
            label.allowsDefaultTighteningForTruncation = true
            let labelSize = label.sizeThatFits(CGSize(width: actorThumbnailSize.width, height: 1000.0))
            label.frame = CGRect(x: imageView.frame.origin.x,
                                 y: imageView.frame.size.height + vGap,
                                 width: actorThumbnailSize.width,
                                 height: labelSize.height)
            self.actorContentView.addSubview(label)
            
            maxLabelHeight = labelSize.height > maxLabelHeight ? labelSize.height : maxLabelHeight
        }

        self.actorScrollHeightConstraint.constant = actorThumbnailSize.height + vGap + maxLabelHeight + bottomGap
        self.actorScrollContentWidthConstraint.constant = actorThumbnailSize.width * CGFloat(movie.actors.count) + hGap * CGFloat(movie.actors.count-1)
        self.actorScrollView.delegate = self
        self.actorHeadlineLabel.text = NSLocalizedString("Actors", comment: "")
    }
    
    
    // Enlarges the tapped thumbnail image
    @objc func actorThumbnailTapped(_ recognizer: UITapGestureRecognizer)
    {
        if let movie = movie,
           let navigationController = navigationController,
           let imageView = recognizer.view as? UIImageView
        {
            var bigImagePath = ""
            var smallImagePath = ""
            var bigImage: UIImage?
            var smallImage: UIImage?
            
            if let basePath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.movieStartsGroup)?.path
            {
                bigImagePath = basePath + Constants.actorBigFolder + movie.profilePictures[imageView.tag]
                smallImagePath = basePath + Constants.actorThumbnailFolder + movie.profilePictures[imageView.tag]
            }
            
            if (movie.profilePictures[imageView.tag].count > 0)
            {
                bigImage = UIImage(contentsOfFile: bigImagePath)
                smallImage = UIImage(contentsOfFile: smallImagePath)
            }
            else
            {
                // no picture available
                bigImage = UIImage(named: "no-actor")
                smallImage = UIImage(named: "no-actor")
            }

            // build zoom view and start it
            var actorName: String?
            var characterName: String?
            
            if ((movie.actors.count > imageView.tag) && (movie.actors[imageView.tag].count > 0))
            {
                actorName = movie.actors[imageView.tag]
            }
            if ((movie.characters.count > imageView.tag) && (movie.characters[imageView.tag].count > 0))
            {
                characterName = NSLocalizedString("ActorAs", comment: "") + " " + movie.characters[imageView.tag]
            }

            let zoomView = ZoomImageView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
            zoomView.navigationController = navigationController
            zoomView.tabBar = self.tabBarController?.tabBar
            zoomView.setup(smallImage: smallImage,
                           smallFrame: CGRect(x: self.bigStackView.frame.minX + imageView.frame.minX + self.actorHorizontalView.frame.minX + self.actorScrollView.frame.minX -
                            self.actorScrollView.contentOffset.x,
                                              y: navigationController.navigationBar.frame.origin.y + navigationController.navigationBar.frame.height + self.bigStackView.frame.minY +
                                                self.actorHorizontalView.frame.minY + self.actorScrollView.frame.minY - self.scrollView.contentOffset.y,
                                              width: imageView.frame.width,
                                              height: imageView.frame.height),
                           bigImage: bigImage,
                           bigImageURL: Constants.imageBaseUrl + ProfilePictureSizePath.Big.rawValue + movie.profilePictures[imageView.tag],
                           bigImageTargetPath: bigImagePath,
                           mainText: actorName,
                           secondText: characterName)
            
            self.view.addSubview(zoomView)
            self.posterImageTopSpaceConstraint.constant += navigationController.navigationBar.frame.height
            
            zoomView.startPresentation
            {
                zoomView.removeFromSuperview()
                self.posterImageTopSpaceConstraint.constant -= navigationController.navigationBar.frame.height
            }
        }
    }

    
    final private func downloadProfilePicture(_ profilePictureFilename: String, fromPath actorImageFilePath: String, andShowItInImageView imageView: UIImageView)
    {
        guard let sourceImageUrl = URL(string: Constants.imageBaseUrl + ProfilePictureSizePath.Small.rawValue + profilePictureFilename) else { return }

        let task = URLSession.shared.downloadTask(with: sourceImageUrl,
                                                  completionHandler:
        {
            [weak self] (location: URL?, response: URLResponse?, error: Error?) -> Void in
            
            if let error = error
            {
                NSLog("Error getting actor thumbnail: \(error.localizedDescription)")
            }
            else if let receivedPath = location?.path
            {
                // move received poster to target path where it belongs and update the imageview
                do
                {
                    try FileManager.default.moveItem(atPath: receivedPath, toPath: actorImageFilePath)
                    
                    DispatchQueue.main.async
                    {
                        imageView.image = self?.cropImageToProperHeight(UIImage(contentsOfFile: actorImageFilePath))
                    }
                }
                catch let error as NSError
                {
                    if ((error.domain == NSCocoaErrorDomain) && (error.code == NSFileWriteFileExistsError))
                    {
                        // ignoring, because it's okay it it's already there
                    }
                    else
                    {
                        NSLog("Error moving actor thumbnail: \(error.localizedDescription)")
                    }
                }
            }
        })
        
        task.resume()
    }

    
    // MARK: - Small helper functions
    
    final private func cropImageToProperHeight(_ inputImage: UIImage?) -> UIImage?
    {
        guard let inputImage = inputImage, let inputCgImage = inputImage.cgImage else { return nil }

        if let imageRef = inputCgImage.cropping(to:
            CGRect(x: 0.0, y: 0.0, width: 185.0, height: 247.0))
        {
            return UIImage(cgImage: imageRef)
        }

        return nil
    }

    final private func getActorFilePathForActorWithIndex(_ actorIndex: Int) -> String?
    {
        // check the basics
        guard let movie = self.movie else { return nil }
        guard let basePath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.movieStartsGroup)?.path else { return nil }
        if (movie.profilePictures.count <= actorIndex) { return nil }
        if (movie.profilePictures[actorIndex].count <= 0) { return nil }

        // get filename and path, merge them, return them
        return basePath + Constants.actorThumbnailFolder + movie.profilePictures[actorIndex]
    }
    
    
    // MARK: - UIScrollViewDelegate (for actor scroll-view)
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        if (scrollView == self.actorScrollView)
        {
            let cellWidth: CGFloat = actorThumbnailSize.width + 3.0 // imageWidth plus hGap (3)
            targetContentOffset.pointee.x = round(targetContentOffset.pointee.x / cellWidth) * cellWidth
        }
    }
}

