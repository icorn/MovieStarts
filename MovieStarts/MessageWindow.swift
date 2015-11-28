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
	var buttons: [UIButton]
	var progressView: UIView
	var progressLabel: UILabel
	var spinner: UIActivityIndicatorView
	var progressViewWidthConstraint: NSLayoutConstraint?
	var buttonHeightConstraints: [NSLayoutConstraint]
	var buttonTopConstraints: [NSLayoutConstraint]
	
	let buttonHeight: CGFloat = 34.0
	let buttonTop: CGFloat = 10.0
	
	weak var parentView: UIView?
	var buttonHandler: ((buttonIndex: Int) -> ())?

	
	convenience init(parent: UIView, darkenBackground: Bool, titleStringId: String, textStringId: String, buttonStringIds: [String], handler: ((buttonIndex: Int) -> ())?) {
		self.init(parent: parent, darkenBackground: darkenBackground, titleStringId: titleStringId, textStringId: textStringId, buttonStringIds: buttonStringIds, error: nil, handler: handler)
	}
	
	
	init(parent: UIView, darkenBackground: Bool, titleStringId: String, textStringId: String, buttonStringIds: [String], error: NSError?, handler: ((buttonIndex: Int) -> ())?) {

		parentView = parent
		buttonHandler = handler
		
		// create views

		view = UIView()
		backView = UIView()
		progressView = UIView()
		spinner = UIActivityIndicatorView()
		progressLabel = UILabel()
		buttons = []
		buttonHeightConstraints = []
		buttonTopConstraints = []
		
		super.init()

		if (buttonStringIds.count == 0) {
			NSLog("MessageWindow must have buttons!")
			return
		}
		
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
		
		for (index, buttonStringId) in buttonStringIds.enumerate() {
			let button = UIButton()
			button.tag = index
			button.translatesAutoresizingMaskIntoConstraints = false
			button.setTitle(NSLocalizedString(buttonStringId, comment: ""), forState: UIControlState.Normal)
			button.setTitleColor(UIColor(red: 0.0, green: 170.0/255.0, blue: 170.0/255.0, alpha: 1.0), forState: UIControlState.Normal)
			button.setTitleColor(UIColor(red: 0.0, green: 120.0/255.0, blue: 120.0/255.0, alpha: 1.0), forState: UIControlState.Highlighted)
			button.addTarget(self, action: Selector("buttonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
			buttons.append(button)
		}
		
		progressView.translatesAutoresizingMaskIntoConstraints = false
		progressView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
		progressView.hidden = true
		
		spinner.translatesAutoresizingMaskIntoConstraints = false
		spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
		spinner.hidesWhenStopped = false
		
		progressLabel.translatesAutoresizingMaskIntoConstraints = false
		progressLabel.text = ""
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
		view.addSubview(progressView)

		for button in buttons {
			view.addSubview(button)
		}
		
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

		for (index, button) in buttons.enumerate() {
			view.addConstraints([
				NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: view,
					attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0),
				NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: view,
					attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0)
			])

			if (index == 0) {
				view.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal,
					toItem: msg, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 20))
			}
			else {
				let topConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal,
					toItem: buttons[index-1], attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: buttonTop)
				view.addConstraint(topConstraint)
				buttonTopConstraints.append(topConstraint)
				
				let heightConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal,
					toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: buttonHeight)
				view.addConstraint(heightConstraint)
				buttonHeightConstraints.append(heightConstraint)
			}
		}

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
			NSLayoutConstraint(item: progressView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: buttons[0],
				attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: progressView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: buttons[0],
				attribute: NSLayoutAttribute.Height, multiplier: 1.0, constant: 0)
		])

		progressViewWidthConstraint =  NSLayoutConstraint(item: progressView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil,
			attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: progressLabel.frame.width + 30)

		if let constraint = progressViewWidthConstraint {
			view.addConstraint(constraint)
		}
		
		parent.addConstraints([
			NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: parent,
				attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: buttons[buttons.count-1],
				attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 20)
		])
	}
	
	
	func buttonPressed(sender: UIButton!) {
		buttonHandler?(buttonIndex: sender.tag)
	}
	
	
	func close() {
		logoImageView?.removeFromSuperview()
		view.removeFromSuperview()
		backView.removeFromSuperview()
	}
	
	
	func showProgressIndicator(progressText: String) {
		for button in buttons {
			button.hidden = true
		}
		
		for constraint in buttonHeightConstraints {
			constraint.constant = 0
		}
		
		for constraint in buttonTopConstraints {
			constraint.constant = 0
		}
		
		spinner.startAnimating()
		progressView.hidden = false

		updateProgressIndicator(progressText)
	}
	
	
	func hideProgressIndicator() {
		spinner.stopAnimating()
		progressView.hidden = true
		
		for button in buttons {
			button.hidden = false
		}
		
		for constraint in buttonHeightConstraints {
			constraint.constant = buttonHeight
		}

		for constraint in buttonTopConstraints {
			constraint.constant = buttonTop
		}
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

