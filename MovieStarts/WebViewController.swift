//
//  WebViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 07.06.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate, UIAlertViewDelegate {

	@IBOutlet weak var webview: UIWebView!
	
	var urlString: String?
	var activityIndicatorParent: UIView?
	var activityIndicator: UIActivityIndicatorView?
	var spinning = false

	var reloadButton: UIBarButtonItem?
	var backButton: UIBarButtonItem?
	var forwardButton: UIBarButtonItem?
	
	
	// MARK: - UIViewController
	
    override func viewDidLoad() {
        super.viewDidLoad()
		webview.delegate = self

		// avoid white flash
		webview.opaque = false

		if let saveUrlString = urlString, saveNSUrl = NSURL(string: saveUrlString) {
		
			let request = NSURLRequest(URL: saveNSUrl)
			webview.loadRequest(request)
		
			// create buttons in navigation bar
	
			reloadButton = UIBarButtonItem(image: UIImage(named: "WebViewRefresh.png"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("reloadButtonPressed"))
			backButton = UIBarButtonItem(image: UIImage(named: "WebViewBack.png"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("backButtonPressed"))
			forwardButton = UIBarButtonItem(image: UIImage(named: "WebViewForward.png"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("forwardButtonPressed"))
		
			if let saveRButton = reloadButton, saveFButton = forwardButton, saveBButton = backButton {
				navigationItem.rightBarButtonItems = [saveRButton, saveFButton, saveBButton]
			}
			
			reloadButton?.enabled = false
			backButton?.enabled = false
			forwardButton?.enabled = false
		}
    }

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)

		// when user goes back to film details, stop loading and remove activity indicator

		webview.stopLoading()
		activityIndicator?.stopAnimating()
		activityIndicatorParent?.removeFromSuperview()
			
		spinning = false
	}
	
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	
	// MARK: - UIWebViewDelegate
	
	func webViewDidStartLoad(webView: UIWebView) {
	
		// generate activity indicator and start it
	
		if (spinning == false) {
			activityIndicatorParent = UIView()
			activityIndicatorParent?.frame = webview.frame
			activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
	
			if let saveNavController = navigationController, saveActIndiParent = activityIndicatorParent, saveActIndi = activityIndicator {
			
				let totalHeight: CGFloat = webview.frame.size.height + webview.frame.origin.y
				let verticalCenter: CGFloat = totalHeight / 2 - webview.frame.origin.y - saveNavController.navigationBar.frame.size.height
	
				saveActIndi.center = CGPoint(x: saveActIndiParent.frame.size.width/2, y: verticalCenter - (saveActIndi.frame.size.height / 2))
	
				activityIndicatorParent?.addSubview(saveActIndi)
				view.addSubview(saveActIndiParent)
				saveActIndi.startAnimating()
	
				spinning = true
			}

			reloadButton?.enabled = false
			backButton?.enabled = false
			forwardButton?.enabled = false
		}
	}
	
	func webViewDidFinishLoad(webView: UIWebView) {
	
		// stop and remove activity indicator
	
		activityIndicator?.stopAnimating()
		activityIndicatorParent?.removeFromSuperview()
	
		reloadButton?.enabled = true
		backButton?.enabled = webview.canGoBack
		forwardButton?.enabled = webview.canGoForward
	
		spinning = false
	}
	
	
	func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
		if let error = error where (error.code != NSURLErrorCancelled) && (error.localizedDescription.characters.count > 0) {
			// error (not cancelled by user): show alert

			let alert = UIAlertView(title: "NetworkErrorSstring", message: error.localizedDescription, delegate: self, cancelButtonTitle: "OK")
			alert.show()
		}
	
		activityIndicator?.stopAnimating()
		activityIndicatorParent?.removeFromSuperview()
	
		reloadButton?.enabled = true
		backButton?.enabled = webview.canGoBack
		forwardButton?.enabled = webview.canGoForward
	
		spinning = false
	}

	
	// MARK: - UIAlertViewDelegate
	
	func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
		// user pressed OK in alert: do nothing (for now)
	}

	
	// MARK: - Button callbacks

	func reloadButtonPressed() {
		webview.reload()
	}
	
	func backButtonPressed() {
		webview.goBack()
	}
	
	func forwardButtonPressed() {
		webview.goForward()
	}

}
