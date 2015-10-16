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
	
	var backView: UIView
	var view: UIView
	var logoImageView: UIImageView?
	var button: UIButton
	var progressView: UIView
	var progressLabel: UILabel
	var spinner: UIActivityIndicatorView
	var progressViewWidthConstraint: NSLayoutConstraint?
	
	weak var parentView: UIView?
	var buttonHandler: (() -> ())?

	
	convenience init(parent: UIView, darkenBackground: Bool, titleStringId: String, textStringId: String, buttonStringId: String, handler: (() -> ())?) {
		self.init(parent: parent, darkenBackground: darkenBackground, titleStringId: titleStringId, textStringId: textStringId, buttonStringId: buttonStringId, error: nil, handler: handler)
	}
	
	
	init(parent: UIView, darkenBackground: Bool, titleStringId: String, textStringId: String, buttonStringId: String, error: NSError?, handler: (() -> ())?) {

		parentView = parent
		buttonHandler = handler
		
		// create views

		view = UIView()
		backView = UIView()
		button = UIButton()
		progressView = UIView()
		spinner = UIActivityIndicatorView()
		progressLabel = UILabel()

		super.init()

		// set up views
		
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.cornerRadius = 6
		view.backgroundColor = UIColor.whiteColor()
		view.opaque = false
		
		backView.translatesAutoresizingMaskIntoConstraints = false
		if darkenBackground {
			backView.backgroundColor = UIColor.blackColor()
			backView.alpha = 0.7
		}
		
		let logoImage = UIImage(named: "welcome")
		if let logoImage = logoImage {
			logoImageView = UIImageView()
			logoImageView?.translatesAutoresizingMaskIntoConstraints = false
			logoImageView?.image = logoImage
		}
		
		let title = UILabel()
		title.translatesAutoresizingMaskIntoConstraints = false
		title.text = NSLocalizedString(titleStringId, comment: "")
		title.font = UIFont.systemFontOfSize(24)
		title.textAlignment = NSTextAlignment.Center
		title.textColor = UIColor.blackColor()
		title.backgroundColor = UIColor.clearColor()

		let msg = UILabel()
		msg.translatesAutoresizingMaskIntoConstraints = false
		msg.text = NSLocalizedString(textStringId, comment: "")
		
		if let error = error {
			var messageText = NSLocalizedString(textStringId, comment: "") + " " + error.localizedDescription
			
			if let recoverySuggestion = error.localizedRecoverySuggestion {
				messageText = messageText + " " + recoverySuggestion
			}

			msg.text = messageText
			msg.font = UIFont.systemFontOfSize(14)
		}
		else {
			msg.text = NSLocalizedString(textStringId, comment: "")
			msg.font = UIFont.systemFontOfSize(16)
		}
		
		msg.textAlignment = NSTextAlignment.Center
		msg.textColor = UIColor.blackColor()
		msg.backgroundColor = UIColor.clearColor()
		msg.numberOfLines = 0
		msg.sizeToFit()
		
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle(NSLocalizedString(buttonStringId, comment: ""), forState: UIControlState.Normal)
		button.setTitleColor(UIColor(red: 0.0, green: 170.0/255.0, blue: 170.0/255.0, alpha: 1.0), forState: UIControlState.Normal)
		button.setTitleColor(UIColor(red: 0.0, green: 120.0/255.0, blue: 120.0/255.0, alpha: 1.0), forState: UIControlState.Highlighted)
		button.addTarget(self, action: Selector("buttonPressed"), forControlEvents: UIControlEvents.TouchUpInside)
		
		progressView.translatesAutoresizingMaskIntoConstraints = false
		progressView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
		progressView.hidden = true
		
		spinner.translatesAutoresizingMaskIntoConstraints = false
		spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
		spinner.hidesWhenStopped = false
		
		progressLabel.translatesAutoresizingMaskIntoConstraints = false
		progressLabel.text = "Hi"
		progressLabel.font = UIFont.systemFontOfSize(16)
		progressLabel.textAlignment = NSTextAlignment.Left
		progressLabel.textColor = UIColor.grayColor()
		progressLabel.backgroundColor = UIColor.clearColor()
		progressLabel.sizeToFit()
		
		// add views to parents
		
		parent.addSubview(backView)
		parent.addSubview(view)
		
		view.addSubview(title)
		view.addSubview(msg)
		view.addSubview(button)
		view.addSubview(progressView)

		progressView.addSubview(spinner)
		progressView.addSubview(progressLabel)

		if let logoImageView = logoImageView {
			parent.addSubview(logoImageView)
		}
		
		// create easy constraints in visual format
		
		let viewsDictionary = ["view": view, "backView": backView, "progressView": progressView]
		
		parent.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[backView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary))
		parent.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[backView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary))
		parent.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[view]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary))
		
		// create the more complicated constraints in code

		if let logoImageView = logoImageView, logoImage = logoImage {
			parent.addConstraints([
				NSLayoutConstraint(item: logoImageView,	attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view,
					attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: -1 * (logoImage.size.height / 2)),
				NSLayoutConstraint(item: logoImageView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view,
					attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0)
			])
		}
		
		view.addConstraints([
			NSLayoutConstraint(item: title, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view,
				attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 40),
			NSLayoutConstraint(item: title, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: view,
				attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: title, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: view,
				attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0)
		])
				
		view.addConstraints([
			NSLayoutConstraint(item: msg, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: title,
				attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 10),
			NSLayoutConstraint(item: msg, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: view,
				attribute: NSLayoutAttribute.Leading, multiplier: 1.0, 	constant: 15),
			NSLayoutConstraint(item: msg, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: view,
				attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: -15)
		])

		view.addConstraints([
			NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: view,
				attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: view,
				attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: msg,
				attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 20)
		])
		
		progressView.addConstraints([
			NSLayoutConstraint(item: spinner, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: progressView,
				attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: spinner, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: progressView,
				attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0),
			
			NSLayoutConstraint(item: progressLabel, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: spinner,
				attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 10),
			NSLayoutConstraint(item: progressLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: progressView,
				attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0)
		])
		
		view.addConstraints([
			NSLayoutConstraint(item: progressView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view,
				attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: progressView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: button,
				attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0),

			NSLayoutConstraint(item: progressView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: button,
				attribute: NSLayoutAttribute.Height, multiplier: 1.0, constant: 0),

		])

		progressViewWidthConstraint =  NSLayoutConstraint(item: progressView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil,
			attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: progressLabel.frame.width + 30)

		if let constraint = progressViewWidthConstraint {
			view.addConstraint(constraint)
		}
		
		parent.addConstraints([
			NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: parent,
				attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: button,
				attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 20)
		])
	}
	
	
	func buttonPressed() {
		buttonHandler?()
	}
	
	
	func close() {
		logoImageView?.removeFromSuperview()
		view.removeFromSuperview()
		backView.removeFromSuperview()
	}
	
	
	func showProgressIndicator(progressText: String) {
		button.hidden = true
		spinner.startAnimating()
		progressView.hidden = false

		updateProgressIndicator(progressText)
	}
	
	
	func hideProgressIndicator() {
		spinner.stopAnimating()
		progressView.hidden = true
		button.hidden = false
	}
	
	
	func updateProgressIndicator(progressText: String) {
		
		dispatch_async(dispatch_get_main_queue()) {
			self.progressLabel.text = progressText
			self.progressLabel.sizeToFit()
		
			if let constraint = self.progressViewWidthConstraint {
				constraint.constant = self.progressLabel.frame.width + 30
			}
		}
	}
	
}

