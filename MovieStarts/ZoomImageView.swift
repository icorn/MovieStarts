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
    var mainLabel: UILabel!
    var secondLabel: UILabel!

    var smallImage: UIImage?
    var smallFrame: CGRect?
    var bigImage: UIImage?
    var bigImageURL: String?
    var bigImageTargetPath: String?
    
    var completionClosure: (() -> ())?

    open var navigationController: UINavigationController?
    open var tabBar: UITabBar?

    
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
        bigImageView.contentMode = UIView.ContentMode.scaleAspectFit
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
        spinner.style = UIActivityIndicatorView.Style.large
        spinner.hidesWhenStopped = true

        mainLabel = UILabel()
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        mainLabel.backgroundColor = UIColor.black
        mainLabel.textColor = UIColor.white
        mainLabel.textAlignment = .center
        mainLabel.font = UIFont.systemFont(ofSize: 18.0)
        mainLabel.alpha = 0.0
        mainLabel.isHidden = true
        
        secondLabel = UILabel()
        secondLabel.translatesAutoresizingMaskIntoConstraints = false
        secondLabel.backgroundColor = UIColor.black
        secondLabel.textColor = UIColor.lightGray
        secondLabel.textAlignment = .center
        secondLabel.font = UIFont.systemFont(ofSize: 16.0)
        secondLabel.alpha = 0.0
        secondLabel.isHidden = true

        // add subviews to views
        spinnerBackground.addSubview(spinner)
        bigImageView.addSubview(spinnerBackground)
        bigImageScrollView.addSubview(bigImageView)
        bigImageBackView.addSubview(bigImageScrollView)
        bigImageBackView.addSubview(mainLabel)
        bigImageBackView.addSubview(secondLabel)
        self.addSubview(bigImageBackView)
    }


    public func setup(smallImage: UIImage?,
                      smallFrame: CGRect,
                      bigImage: UIImage?,
                      bigImageURL: String,
                      bigImageTargetPath: String,
                      mainText: String? = nil,
                      secondText: String? = nil)
    {
        self.smallImage             = smallImage
        self.smallFrame             = smallFrame
        self.bigImage               = bigImage
        self.bigImageURL            = bigImageURL
        self.bigImageTargetPath     = bigImageTargetPath

        mainLabel.text = mainText
        mainLabel.isHidden = (mainText == nil)
        secondLabel.text = secondText
        secondLabel.isHidden = (secondText == nil)

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
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[bigImageBackView]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[bigImageBackView]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary))
        bigImageBackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[bigImageScrollView]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary))
        bigImageBackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[bigImageScrollView]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary))

        bigImageViewTopConstraint = NSLayoutConstraint(item: bigImageView as Any, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: bigImageScrollView,
                                                       attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: smallFrame.origin.y)
        bigImageViewLeadingConstraint = NSLayoutConstraint(item: bigImageView as Any, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal,
                                                           toItem: bigImageScrollView, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1.0, constant: smallFrame.origin.x)
        bigImageViewWidthConstraint = NSLayoutConstraint(item: bigImageView as Any, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal,
                                                         toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1.0, constant: smallFrame.size.width)
        bigImageViewHeightConstraint = NSLayoutConstraint(item: bigImageView as Any, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal,
                                                          toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1.0, constant: smallFrame.size.height)
        bigImageView.addConstraints([
            NSLayoutConstraint(item: spinnerBackground as Any, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal,
                               toItem: bigImageView, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: spinnerBackground as Any, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal,
                               toItem: bigImageView,    attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: spinnerBackground as Any, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal,
                               toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1.0, constant: 80),
            NSLayoutConstraint(item: spinnerBackground as Any, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal,
                               toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1.0, constant: 80)
            ])
        spinnerBackground.addConstraints([
            NSLayoutConstraint(item: spinner as Any, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal,
                               toItem: spinnerBackground, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: spinner as Any, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal,
                               toItem: spinnerBackground, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 0)
            ])

        var bottomPadding: CGFloat = 0.0
        
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        {
            bottomPadding = -window.safeAreaInsets.bottom
        }
        
        if (secondLabel.isHidden == false)
        {
            let labelSize = secondLabel.sizeThatFits(self.frame.size)

            bigImageBackView.addConstraints([
                NSLayoutConstraint(item: secondLabel as Any, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal,
                                   toItem: bigImageBackView, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: bottomPadding),
                NSLayoutConstraint(item: secondLabel as Any, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal,
                                   toItem: bigImageBackView, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: secondLabel as Any, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal,
                                   toItem: bigImageBackView, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: secondLabel as Any, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal,
                                   toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1.0, constant: labelSize.height + 10.0)
                ])
        }

        if (mainLabel.isHidden == false)
        {
            if (secondLabel.isHidden)
            {
                bigImageBackView.addConstraint(NSLayoutConstraint(item: mainLabel as Any, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal,
                                                                  toItem: bigImageBackView, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: bottomPadding))
            }
            else
            {
                bigImageBackView.addConstraint(NSLayoutConstraint(item: mainLabel as Any, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal,
                                                                  toItem: secondLabel, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: 0.0))
            }

            let labelSize = mainLabel.sizeThatFits(self.frame.size)

            bigImageBackView.addConstraints([
                NSLayoutConstraint(item: mainLabel as Any, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal,
                                   toItem: bigImageBackView, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: mainLabel as Any, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal,
                                   toItem: bigImageBackView, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: mainLabel as Any, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal,
                                   toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1.0, constant: labelSize.height + 8.0)
                ])
        }

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
                       options: UIView.AnimationOptions.curveEaseOut,
                       animations:
            {
                self.bigImageBackView.backgroundColor = UIColor.black
                self.bigImageViewTopConstraint?.constant = 0
                self.bigImageViewLeadingConstraint?.constant = 0
                self.bigImageViewHeightConstraint?.constant = navigationController.view.frame.height
                self.bigImageViewWidthConstraint?.constant = navigationController.view.frame.width
                self.mainLabel.alpha = 0.75
                self.secondLabel.alpha = 0.75
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
            
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut,
                           animations:
                {
                    bigImageBackView.backgroundColor = UIColor.clear
                    self.bigImageViewTopConstraint?.constant = smallFrame.origin.y
                    self.bigImageViewLeadingConstraint?.constant = smallFrame.origin.x
                    self.bigImageViewHeightConstraint?.constant = smallFrame.size.height
                    self.bigImageViewWidthConstraint?.constant = smallFrame.size.width
                    bigImageView.alpha = 0.3
                    self.mainLabel.alpha = 0.0
                    self.secondLabel.alpha = 0.0
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
