//
//  MovieViewControllerPosters.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 20.09.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation
import UIKit
import CFNetwork


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
            
            self.createBigImageUI(smallImage: movie.thumbnailImage.0,
                                  smallFrame: CGRect(x: posterImageView.frame.minX,
                                                     y: posterImageView.frame.minY + navigationController.navigationBar.frame.height +
                                                        navigationController.navigationBar.frame.origin.y - self.scrollView.contentOffset.y,
                                                     width: posterImageView.frame.width,
                                                     height: posterImageView.frame.height),
                                  bigImage: movie.bigPoster,
                                  bigImageURL: sourcePathString,
                                  bigImageTargetPath: targetPath)
		}
	}
	
	
	/**
		Loads the big movie poster and stores it on the device.
	*/
	func loadBigPoster()
    {
		guard let bigImageView = bigImageView,
              let movie = movie,
              let targetPath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.movieStartsGroup)?.path else
        {
			self.stopSpinners()
			return
		}
		
        var errorWindow: MessageWindow?
		let sourcePath = Constants.imageBaseUrl + PosterSizePath.Big.rawValue
		var posterUrl = movie.posterUrl[movie.currentCountry.languageArrayIndex]
		
		if (posterUrl.count == 0)
        {
			// if there is no poster in wanted language, try the english one
			posterUrl = movie.posterUrl[MovieCountry.USA.languageArrayIndex]
		}
		
		if (posterUrl.count <= 0)
        {
			self.stopSpinners()
			return
		}
		
		guard let sourceUrl = URL(string: sourcePath + posterUrl) else
        {
            // poster file is missing
			self.stopSpinners()
			return
		}
		
		// configure download task
		let config = URLSessionConfiguration.default
		config.allowsCellularAccess = true
		config.timeoutIntervalForRequest = 10
		config.timeoutIntervalForResource = 10
		
		let session = URLSession(configuration: config)
		
		// start the download
		let task = session.downloadTask(with: sourceUrl,
		                                completionHandler:
        {
            (location: URL?, response: URLResponse?, error: Error?) -> Void in
			
            self.stopSpinners()
			
			if let error = error as NSError?
            {
				NSLog("Error getting missing thumbnail: \(error.localizedDescription)")
				
				if (Int32(error.code) == CFNetworkErrors.cfurlErrorTimedOut.rawValue)
                {
					DispatchQueue.main.async
                    {
						errorWindow = MessageWindow(parent: bigImageView,
                                                    darkenBackground: true,
                                                    titleStringId: "BigPosterErrorTitle",
                                                    textStringId: "BigPosterTimeOut",
                                                    buttonStringIds: ["Close"],
                                                    handler:
                        { (buttonIndex) -> () in
							errorWindow?.close()
						})
					}
				}
				else {
					DispatchQueue.main.async {
						errorWindow = MessageWindow(parent: bigImageView,
                                                    darkenBackground: true,
                                                    titleStringId: "BigPosterErrorTitle",
                                                    textStringId: "BigPosterErrorText",
                                                    buttonStringIds: ["Close"],
                                                    handler:
                        { (buttonIndex) -> () in
							errorWindow?.close()
						})
					}
				}
			}
			else if let receivedPath = location?.path
            {
				// move received poster to target path where it belongs
				do
                {
					try FileManager.default.moveItem(atPath: receivedPath, toPath: targetPath + Constants.bigPosterFolder + posterUrl)
				}
				catch let error as NSError
                {
					if ((error.domain == NSCocoaErrorDomain) && (error.code == NSFileWriteFileExistsError))
                    {
						// ignoring, because it's okay it it's already there
					}
					else
                    {
						NSLog("Error moving missing poster: \(error.localizedDescription)")

						DispatchQueue.main.async
                        {
							errorWindow = MessageWindow(parent: bigImageView,
                                                        darkenBackground: true,
                                                        titleStringId: "BigPosterErrorTitle",
                                                        textStringId: "BigPosterErrorText",
                                                        buttonStringIds: ["Close"],
                                                        handler:
                            { (buttonIndex) -> () in
								errorWindow?.close()
							})
						}
						return
					}
				}

				// load and show poster
				if let bigPoster = movie.bigPoster
                {
					DispatchQueue.main.async
                    {
						bigImageView.image = bigPoster
					}
					return
				}

				// poster not loaded or error
				if let error = error as NSError?
                {
					NSLog("Error getting big poster: \(error.code) (\(error.localizedDescription))")
				}

				DispatchQueue.main.async
                {
					errorWindow = MessageWindow(parent: bigImageView,
                                                darkenBackground: true,
                                                titleStringId: "BigPosterErrorTitle",
                                                textStringId: "BigPosterErrorText",
                                                buttonStringIds: ["Close"],
                                                handler:
                    { (buttonIndex) -> () in
						errorWindow?.close()
					})
				}
			}
		})
		
		task.resume()
	}

}
