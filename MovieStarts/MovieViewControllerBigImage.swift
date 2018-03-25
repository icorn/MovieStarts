import UIKit


public class BigImageTapGestureRecognizer: UITapGestureRecognizer
{
    var smallFrame: CGRect?
}


extension MovieViewController
{
    func stopSpinners()
    {
        DispatchQueue.main.async
        {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.spinner?.stopAnimating()
            self.spinnerBackground?.removeFromSuperview()
        }
    }
    
    func createBigImageUI(smallImage: UIImage?, smallFrame: CGRect, bigImage: UIImage?, bigImageURL: String, bigImageTargetPath: String)
    {
        // create poster background, scrollview, and imageview
        bigImageBackView = UIView()
        bigImageScrollView = UIScrollView()
        bigImageView = UIImageView()
        
        spinnerBackground = UIView()
        spinner = UIActivityIndicatorView()
        
        if let bigImageView = bigImageView,
            let bigImageScrollView = bigImageScrollView,
            let bigImageBackView = bigImageBackView,
            let spinnerBackground = self.spinnerBackground,
            let spinner = self.spinner,
            let navigationController = navigationController
        {
            bigImageBackView.backgroundColor = UIColor.clear
            bigImageBackView.translatesAutoresizingMaskIntoConstraints = false
            
            bigImageScrollView.minimumZoomScale = 1.0
            bigImageScrollView.maximumZoomScale = 6.0
            bigImageScrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height)
            bigImageScrollView.delegate = self
            bigImageScrollView.translatesAutoresizingMaskIntoConstraints = false
            
            bigImageView.contentMode = UIViewContentMode.scaleAspectFit
            bigImageView.translatesAutoresizingMaskIntoConstraints = false
            bigImageView.isUserInteractionEnabled = true
            let rec = BigImageTapGestureRecognizer(target: self, action: #selector(bigImageTapped(_:)))
            rec.smallFrame = smallFrame
            bigImageView.addGestureRecognizer(rec)

            if let bigImage = bigImage
            {
                bigImageView.image = bigImage
            }
            else
            {
                bigImageView.image = smallImage
            }
            
            spinnerBackground.translatesAutoresizingMaskIntoConstraints = false
            spinnerBackground.backgroundColor = UIColor.black
            spinnerBackground.alpha = 0.6
            spinnerBackground.layer.cornerRadius = 6
            spinnerBackground.isHidden = true
            
            spinner.translatesAutoresizingMaskIntoConstraints = false
            spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
            spinner.hidesWhenStopped = true
            
            bigImageView.translatesAutoresizingMaskIntoConstraints = false
            
            // add subviews to views
            spinnerBackground.addSubview(spinner)
            bigImageView.addSubview(spinnerBackground)
            bigImageScrollView.addSubview(bigImageView)
            bigImageBackView.addSubview(bigImageScrollView)
            self.view.addSubview(bigImageBackView)
            
            // set up constraints
            let viewsDictionary = ["bigImageBackView"   : bigImageBackView,
                                   "bigImageScrollView" : bigImageScrollView,
                                   "bigImageView"  : bigImageView]
            
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[bigImageBackView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary))
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[bigImageBackView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary))
            bigImageBackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[bigImageScrollView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary))
            bigImageBackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[bigImageScrollView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary))
            
            bigImageViewTopConstraint = NSLayoutConstraint(item: bigImageView,
                                                           attribute: NSLayoutAttribute.top,
                                                           relatedBy: NSLayoutRelation.equal,
                                                           toItem: bigImageScrollView,
                                                           attribute: NSLayoutAttribute.top,
                                                           multiplier: 1.0,
                                                           constant: smallFrame.origin.y)
            bigImageViewLeadingConstraint = NSLayoutConstraint(item: bigImageView,
                                                               attribute: NSLayoutAttribute.leading,
                                                               relatedBy: NSLayoutRelation.equal,
                                                               toItem: bigImageScrollView,
                                                               attribute: NSLayoutAttribute.leading,
                                                               multiplier: 1.0,
                                                               constant: smallFrame.origin.x)
            bigImageViewWidthConstraint = NSLayoutConstraint(item: bigImageView,
                                                             attribute: NSLayoutAttribute.width,
                                                             relatedBy: NSLayoutRelation.equal,
                                                             toItem: nil,
                                                             attribute: NSLayoutAttribute.notAnAttribute,
                                                             multiplier: 1.0,
                                                             constant: smallFrame.size.width)
            bigImageViewHeightConstraint = NSLayoutConstraint(item: bigImageView,
                                                              attribute: NSLayoutAttribute.height,
                                                              relatedBy: NSLayoutRelation.equal,
                                                              toItem: nil,
                                                              attribute: NSLayoutAttribute.notAnAttribute,
                                                              multiplier: 1.0,
                                                              constant: smallFrame.size.height)
            bigImageView.addConstraints([
                NSLayoutConstraint(item: spinnerBackground, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal,
                                   toItem: bigImageView, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: spinnerBackground, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal,
                                   toItem: bigImageView,    attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: spinnerBackground, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal,
                                   toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 80),
                NSLayoutConstraint(item: spinnerBackground, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal,
                                   toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 80)
                ])
            spinnerBackground.addConstraints([
                NSLayoutConstraint(item: spinner, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal,
                                   toItem: spinnerBackground, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: spinner, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal,
                                   toItem: spinnerBackground, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0)
                ])
            
            if let imageViewTopConstraint = bigImageViewTopConstraint,
               let imageViewLeadingConstraint = bigImageViewLeadingConstraint,
               let imageViewWidthConstraint = bigImageViewWidthConstraint,
               let imageViewHeightConstraint = bigImageViewHeightConstraint
            {
                bigImageScrollView.addConstraints([imageViewTopConstraint, imageViewLeadingConstraint, imageViewWidthConstraint, imageViewHeightConstraint])
                
                // animate it to a bigger poster
                
                navigationController.setNavigationBarHidden(true, animated: false)
                self.tabBarController?.tabBar.isHidden = true
                posterImageTopSpaceConstraint.constant += navigationController.navigationBar.frame.height
                view.layoutIfNeeded()
                
                UIView.animate(withDuration: 0.2,
                               delay: 0.0,
                               options: UIViewAnimationOptions.curveEaseOut,
                               animations:
                    {
                        bigImageBackView.backgroundColor = UIColor.black
                        imageViewTopConstraint.constant = 0
                        imageViewLeadingConstraint.constant = 0
                        imageViewHeightConstraint.constant = navigationController.view.frame.height
                        imageViewWidthConstraint.constant = navigationController.view.frame.width
                        self.view.layoutIfNeeded()
                    },
                               completion:
                    {
                        finished in
                        
                        if bigImage != nil
                        {
                            // big image already loaded, that's it
                            return
                        }
                        
                        // turn on network indicator and spinner
                        DispatchQueue.main.async
                            {
                                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                                self.spinnerBackground?.isHidden = false
                                self.spinner?.startAnimating()
                        }
                        
                        // no big poster here: load it!
                        self.loadBigImageFromURL(bigImageURL, toPath: bigImageTargetPath)
                    }
                )
            }
        }
    }
    
    
    fileprivate func loadBigImageFromURL(_ bigImageURL: String, toPath bigImageTargetPath: String)
    {
        guard let bigImageView = bigImageView,
              let sourceUrl = URL(string: bigImageURL) else
        {
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
        var errorWindow: MessageWindow?
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
                        try FileManager.default.moveItem(atPath: receivedPath, toPath: bigImageTargetPath)
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
                    if let bigImage = UIImage(contentsOfFile: bigImageTargetPath)
                    {
                        DispatchQueue.main.async
                        {
                            bigImageView.image = bigImage
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

    
    @objc func bigImageTapped(_ recognizer: BigImageTapGestureRecognizer)
    {
        if let bigImageView = bigImageView,
           let bigImageScrollView = bigImageScrollView,
           let bigImageBackView = bigImageBackView,
           let navigationController = navigationController,
           let smallFrame = recognizer.smallFrame
        {
            self.spinner?.stopAnimating()
            self.spinnerBackground?.removeFromSuperview()
            
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut,
                           animations:
                            {
                                bigImageBackView.backgroundColor = UIColor.clear
                                self.bigImageViewTopConstraint?.constant = smallFrame.origin.y
                                self.bigImageViewLeadingConstraint?.constant = smallFrame.origin.x
                                self.bigImageViewHeightConstraint?.constant = smallFrame.size.height
                                self.bigImageViewWidthConstraint?.constant = smallFrame.size.width
                                bigImageView.alpha = 0.3
                                self.view.layoutIfNeeded()
                            },
                           completion:
                            { finished in
                                navigationController.setNavigationBarHidden(false, animated: false)
                                self.tabBarController?.tabBar.isHidden = false
                                self.posterImageTopSpaceConstraint.constant -= navigationController.navigationBar.frame.height
                                bigImageView.removeFromSuperview()
                                bigImageScrollView.removeFromSuperview()
                                bigImageBackView.removeFromSuperview()
                                self.bigImageView = nil
                                self.bigImageScrollView = nil
                                self.bigImageBackView = nil
                            }
            )
        }
    }
    
    
    // MARK: - UIScrollViewDelegate (for big poster view)
    
    @objc(viewForZoomingInScrollView:) func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        return bigImageView
    }

}
