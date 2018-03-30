//
//  ZoomImageView.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 30.03.18.
//  Copyright © 2018 Oliver Eichhorn. All rights reserved.
//

import UIKit

class BigImageTapGestureRecognizer: UITapGestureRecognizer
{
    var smallFrame: CGRect?
}

class ZoomImageView: UIView, UIScrollViewDelegate
{
    var bigImageViewTopConstraint: NSLayoutConstraint?
    var bigImageViewLeadingConstraint: NSLayoutConstraint?
    var bigImageViewWidthConstraint: NSLayoutConstraint?
    var bigImageViewHeightConstraint: NSLayoutConstraint?
    
    var bigImageBackView: UIView!
    var bigImageView: UIImageView!
    var bigImageScrollView: UIScrollView!
    var spinnerBackground: UIView!
    var spinner: UIActivityIndicatorView!

    var smallImage: UIImage?
    var smallFrame: CGRect?
    var bigImage: UIImage?
    var bigImageURL: String?
    var bigImageTargetPath: String?
    
    var navigationController: UINavigationController?
    var tabBar: UITabBar?
    var completionClosure: (() -> ())?

    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect)
    {
        super.init(frame: frame)

        bigImageBackView = UIView()
        bigImageBackView.backgroundColor = UIColor.clear
        bigImageBackView.translatesAutoresizingMaskIntoConstraints = false

        bigImageScrollView = UIScrollView()
        bigImageScrollView.minimumZoomScale = 1.0
        bigImageScrollView.maximumZoomScale = 6.0
        bigImageScrollView.contentSize = CGSize(width: frame.width, height: frame.height)
        bigImageScrollView.delegate = self
        bigImageScrollView.translatesAutoresizingMaskIntoConstraints = false

        bigImageView = UIImageView()
        bigImageView.contentMode = UIViewContentMode.scaleAspectFit
        bigImageView.translatesAutoresizingMaskIntoConstraints = false
        bigImageView.isUserInteractionEnabled = true
        bigImageView.translatesAutoresizingMaskIntoConstraints = false

        spinnerBackground = UIView()
        spinnerBackground.translatesAutoresizingMaskIntoConstraints = false
        spinnerBackground.backgroundColor = UIColor.black
        spinnerBackground.alpha = 0.6
        spinnerBackground.layer.cornerRadius = 6
        spinnerBackground.isHidden = true

        spinner = UIActivityIndicatorView()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        spinner.hidesWhenStopped = true

        // add subviews to views
        spinnerBackground.addSubview(spinner)
        bigImageView.addSubview(spinnerBackground)
        bigImageScrollView.addSubview(bigImageView)
        bigImageBackView.addSubview(bigImageScrollView)
        self.addSubview(bigImageBackView)
    }


    public func setup(smallImage: UIImage?,
                      smallFrame: CGRect,
                      bigImage: UIImage?,
                      bigImageURL: String,
                      bigImageTargetPath: String,
                      navController: UINavigationController,
                      tabBar: UITabBar?)
    {
        self.smallImage             = smallImage
        self.smallFrame             = smallFrame
        self.bigImage               = bigImage
        self.bigImageURL            = bigImageURL
        self.bigImageTargetPath     = bigImageTargetPath
        self.navigationController   = navController
        self.tabBar                 = tabBar
        
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
        
        // set up constraints
        let viewsDictionary:[String:UIView] = ["bigImageBackView"   : bigImageBackView,
                                               "bigImageScrollView" : bigImageScrollView,
                                               "bigImageView"       : bigImageView]
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[bigImageBackView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[bigImageBackView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary))
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
        }
    }
    
    
    public func startPresentation(_ completion: @escaping () -> ())
    {
        self.completionClosure = completion
        
        guard let navigationController = self.navigationController else { return }
        navigationController.setNavigationBarHidden(true, animated: false)
        self.tabBar?.isHidden = true
        self.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseOut,
                       animations:
            {
                self.bigImageBackView.backgroundColor = UIColor.black
                self.bigImageViewTopConstraint?.constant = 0
                self.bigImageViewLeadingConstraint?.constant = 0
                self.bigImageViewHeightConstraint?.constant = navigationController.view.frame.height
                self.bigImageViewWidthConstraint?.constant = navigationController.view.frame.width
                self.layoutIfNeeded()
            },
                       completion:
            {
                finished in
                
                if (self.bigImage != nil)
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
                self.loadBigImageFromURL()
            }
        )
    }

    fileprivate func loadBigImageFromURL()
    {
        guard let bigImageView = self.bigImageView,
              let bigImageURL = self.bigImageURL,
              let bigImageTargetPath = self.bigImageTargetPath,
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
                    self.layoutIfNeeded()
                },
                           completion:
                { finished in
                    navigationController.setNavigationBarHidden(false, animated: false)
                    self.tabBar?.isHidden = false
                    bigImageView.removeFromSuperview()
                    bigImageScrollView.removeFromSuperview()
                    bigImageBackView.removeFromSuperview()
                    self.bigImageView = nil
                    self.bigImageScrollView = nil
                    self.bigImageBackView = nil
                    self.completionClosure?()
                }
            )
        }
    }
    
    func stopSpinners()
    {
        DispatchQueue.main.async
            {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.spinner?.stopAnimating()
                self.spinnerBackground?.removeFromSuperview()
        }
    }

    
    // MARK: - UIScrollViewDelegate
    
    @objc(viewForZoomingInScrollView:) func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        return bigImageView
    }
}
