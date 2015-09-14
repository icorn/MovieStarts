//
//  MessageWindow.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 14.09.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation
import UIKit

class MessageWindow: NSObject {
	
	var backView: UIView?
	var view: UIView?
	var logoImageView: UIImageView?
	var button: UIButton?
	var progressLabel: UILabel?
	var spinner: UIActivityIndicatorView?
	weak var parentView: UIView?
	var buttonHandler: (() -> ())?
	
	
	init(parent: UIView, darkenBackground: Bool, titleStringId: String, textStringId: String, buttonStringId: String, handler: (() -> ())?) {
		
		super.init()
		
		var viewWidth: CGFloat  = 280
		var viewHeight: CGFloat = 260 // we be overwritten later
		var bodyInset: CGFloat	= 15
		
		parentView = parent
		buttonHandler = handler
		
		backView = UIView(frame: parent.frame)
		view = UIView(frame: CGRect(x: parent.frame.width / 2 - viewWidth / 2, y: parent.frame.height / 2 - viewHeight / 2, width: viewWidth, height: viewHeight))
		
		if let view = view, backView = backView {
			
			if darkenBackground {
				backView.backgroundColor = UIColor.blackColor()
				backView.alpha = 0.7
			}
			
			view.layer.cornerRadius = 6
			view.backgroundColor = UIColor.whiteColor()
			view.opaque = false
			
			// title view
			var title = UILabel(frame: CGRect(x: 0, y: 40, width: viewWidth, height: 20))
			title.text = NSLocalizedString(titleStringId, comment: "")
			title.font = UIFont.systemFontOfSize(24)
			title.textAlignment = NSTextAlignment.Center
			title.textColor = UIColor.blackColor()
			title.backgroundColor = UIColor.clearColor()
			view.addSubview(title)
			
			// message text
			var msg = UILabel(frame: CGRect(x: bodyInset, y: title.frame.maxY + 10, width: viewWidth - 2 * bodyInset, height: 150))
			msg.text = NSLocalizedString(textStringId, comment: "")
			msg.font = UIFont.systemFontOfSize(16)
			msg.textAlignment = NSTextAlignment.Center
			msg.textColor = UIColor.blackColor()
			msg.backgroundColor = UIColor.clearColor()
			msg.numberOfLines = 0
			msg.sizeToFit()
			view.addSubview(msg)
			
			// button
			button = UIButton(frame: CGRect(x: 0, y: msg.frame.maxY + 20, width: viewWidth, height: 30))
			
			if let button = button {
				button.setTitle(NSLocalizedString(buttonStringId, comment: ""), forState: UIControlState.Normal)
				button.setTitleColor(UIColor(red: 0.0, green: 170.0/255.0, blue: 170.0/255.0, alpha: 1.0), forState: UIControlState.Normal)
				button.setTitleColor(UIColor(red: 0.0, green: 120.0/255.0, blue: 120.0/255.0, alpha: 1.0), forState: UIControlState.Highlighted)
				button.addTarget(self, action: Selector("buttonPressed"), forControlEvents: UIControlEvents.TouchUpInside)
				view.addSubview(button)
				
				// resize the view depending on the height of the content
				view.frame = CGRect(x: view.frame.minX, y: view.frame.minY, width: viewWidth, height: button.frame.maxY + 20)
			}
			
			// the nice logo
			var logoImage = UIImage(named: "welcome")
			if let logoImage = logoImage {
				logoImageView = UIImageView(frame: CGRect(x: parent.frame.width / 2 - logoImage.size.width / 2, y: view.frame.minY - logoImage.size.height / 2,
					width: logoImage.size.width, height: logoImage.size.height))
				logoImageView?.image = logoImage
			}
			
			parent.addSubview(backView)
			parent.addSubview(view)
			
			if let logoImageView = logoImageView {
				parent.addSubview(logoImageView)
			}
		}
	}
	
	
	func buttonPressed() {
		buttonHandler?()
	}
	
	
	func close() {
		logoImageView?.removeFromSuperview()
		button?.removeFromSuperview()
		view?.removeFromSuperview()
		backView?.removeFromSuperview()
	}

	
	func showProgressIndicator(progressText: String) {
		if let button = button, view = view {
			button.hidden = true
			
			spinner = UIActivityIndicatorView(frame: CGRect(x: 40, y: button.frame.minY + 5, width: 20, height: 20))
			
			if let spinner = spinner {
				spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
				spinner.startAnimating()
				view.addSubview(spinner)
				
				progressLabel = UILabel(frame: CGRect(x: spinner.frame.maxX + 10, y: spinner.frame.minY, width: 100, height: 30))
				
				if let progressLabel = self.progressLabel {
					progressLabel.text = progressText
					progressLabel.font = UIFont.systemFontOfSize(16)
					progressLabel.textAlignment = NSTextAlignment.Left
					progressLabel.textColor = UIColor.grayColor()
					progressLabel.backgroundColor = UIColor.clearColor()
					progressLabel.sizeToFit()
					view.addSubview(progressLabel)
					
					centerProgress()
				}
			}
		}
	}

	
	func updateProgressIndicator(progressText: String) {
		if let progressLabel = progressLabel {
			dispatch_async(dispatch_get_main_queue()) {
				progressLabel.text = progressText
				progressLabel.sizeToFit()
				self.centerProgress()
			}
		}
	}
	
	
	private func centerProgress() {
		// center both the spinner and the label
		if let progressLabel = progressLabel, spinner = spinner, view = view {
			var progressWidth = 20 + 10 + progressLabel.frame.width
			var newProgressX = (view.frame.width - progressWidth) / 2
			spinner.frame = CGRect(x: newProgressX, y: spinner.frame.minY, width: spinner.frame.width, height: spinner.frame.height)
			progressLabel.frame = CGRect(x: spinner.frame.maxX + 10, y: progressLabel.frame.minY, width: progressLabel.frame.width, height: progressLabel.frame.height)
		}
	}

}