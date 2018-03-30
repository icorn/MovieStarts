//
//  MovieViewControllerPosters.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 20.09.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation
import UIKit


extension MovieViewController
{
	//	Enlarges the tapped thumbnail poster
	@objc func posterThumbnailTapped(_ recognizer: UITapGestureRecognizer)
    {
		if let movie = movie,
           let navigationController = navigationController
        {
            // build URL for big poster
            var posterUrlString = movie.posterUrl[movie.currentCountry.languageArrayIndex]
            
            if (posterUrlString.count == 0)
            {
                // if there is no poster in wanted language, try the english one
                posterUrlString = movie.posterUrl[MovieCountry.USA.languageArrayIndex]
            }
            
            let sourcePathString = Constants.imageBaseUrl + PosterSizePath.Big.rawValue + posterUrlString
            
            // build target path for big poster
            var targetPath = ""
            
            if let basePath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.movieStartsGroup)?.path
            {
                targetPath = basePath + Constants.bigPosterFolder + posterUrlString
            }
            
            // build zoom view and start it
            let zoomView = ZoomImageView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
            zoomView.navigationController = navigationController
            zoomView.tabBar = self.tabBarController?.tabBar
            zoomView.setup(smallImage: movie.thumbnailImage.0,
                           smallFrame: CGRect(x: posterImageView.frame.minX,
                                              y: posterImageView.frame.minY + navigationController.navigationBar.frame.height +
                                                navigationController.navigationBar.frame.origin.y - self.scrollView.contentOffset.y,
                                              width: posterImageView.frame.width,
                                              height: posterImageView.frame.height),
                           bigImage: movie.bigPoster,
                           bigImageURL: sourcePathString,
                           bigImageTargetPath: targetPath)
            
            self.view.addSubview(zoomView)
            self.posterImageTopSpaceConstraint.constant += navigationController.navigationBar.frame.height
            
            zoomView.startPresentation
            {
                zoomView.removeFromSuperview()
                self.posterImageTopSpaceConstraint.constant -= navigationController.navigationBar.frame.height
            }
		}
	}
}
