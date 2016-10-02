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
	var buttonHandler: ((Int) -> ())?

	convenience init(parent: UIView, darkenBackground: Bool, titleStringId: String, textStringId: String, textStringAlignment: NSTextAlignment? = nil, buttonStringIds: [String], error: NSError? = nil, handler: ((Int) -> ())?) {
		
		self.init(parent: parent, darkenBackground: darkenBackground, titleStringId: titleStringId, textString: NSLocalizedString(textStringId, comment: ""), textStringAlignment: textStringAlignment, buttonStringIds: buttonStringIds, error: nil, handler: handler)
	}

	init(parent: UIView, darkenBackground: Bool, titleStringId: String, textString: String, textStringAlignment: NSTextAlignment? = nil, buttonStringIds: [String], error: NSError? = nil, handler: ((Int) -> ())?) {

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
/*
		if (buttonStringIds.count == 0) {
			NSLog("MessageWindow must have buttons!")
			return
		}
*/
		// set up views
		
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.cornerRadius = 6
		view.backgroundColor = UIColor.white
		view.isOpaque = false
		
		backView.translatesAutoresizingMaskIntoConstraints = false
		if darkenBackground {
			backView.backgroundColor = UIColor.black
			backView.alpha = 0.7
		}
		
		let logoImage = UIImage(named: "message-icon")
		if let logoImage = logoImage {
			logoImageView = UIImageView()
			logoImageView?.translatesAutoresizingMaskIntoConstraints = false
			logoImageView?.image = logoImage
		}
		
		let title = UILabel()
		title.translatesAutoresizingMaskIntoConstraints = false
		title.text = NSLocalizedString(titleStringId, comment: "")
		title.font = UIFont.systemFont(ofSize: 24)
		title.textAlignment = NSTextAlignment.center
		title.textColor = UIColor.black
		title.backgroundColor = UIColor.clear

		let msg = UILabel()
		msg.translatesAutoresizingMaskIntoConstraints = false
		msg.text = textString
		
		if let error = error {
			var messageText = textString + " " + error.localizedDescription
			
			if let recoverySuggestion = error.localizedRecoverySuggestion {
				messageText = messageText + " " + recoverySuggestion
			}

			msg.text = messageText
			msg.font = UIFont.systemFont(ofSize: 14)
		}
		else {
			msg.text = textString
			msg.font = UIFont.systemFont(ofSize: 16)
		}
		
		if let textStringAlignment = textStringAlignment {
			msg.textAlignment = textStringAlignment
		}
		else {
			msg.textAlignment = NSTextAlignment.center
		}
		
		msg.textColor = UIColor.black
		msg.backgroundColor = UIColor.clear
		msg.numberOfLines = 0
		msg.sizeToFit()
		
		for (index, buttonStringId) in buttonStringIds.enumerated() {
			let button = UIButton()
			button.tag = index
			button.translatesAutoresizingMaskIntoConstraints = false
			button.setTitle(NSLocalizedString(buttonStringId, comment: ""), for: UIControlState())
			button.setTitleColor(UIColor(red: 0.0, green: 170.0/255.0, blue: 170.0/255.0, alpha: 1.0), for: UIControlState())
			button.setTitleColor(UIColor(red: 0.0, green: 120.0/255.0, blue: 120.0/255.0, alpha: 1.0), for: UIControlState.highlighted)
			button.addTarget(self, action: #selector(MessageWindow.buttonPressed(_:)), for: UIControlEvents.touchUpInside)
			buttons.append(button)
		}
		
		progressView.translatesAutoresizingMaskIntoConstraints = false
		progressView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
		progressView.isHidden = true
		
		spinner.translatesAutoresizingMaskIntoConstraints = false
		spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
		spinner.hidesWhenStopped = false
		
		progressLabel.translatesAutoresizingMaskIntoConstraints = false
		progressLabel.text = ""
		progressLabel.font = UIFont.systemFont(ofSize: 16)
		progressLabel.textAlignment = NSTextAlignment.left
		progressLabel.textColor = UIColor.gray
		progressLabel.backgroundColor = UIColor.clear
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
		
		parent.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[backView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary))
		parent.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[backView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary))
		parent.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[view]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary))
		
		// create the more complicated constraints in code

		if let logoImageView = logoImageView, let logoImage = logoImage {
			parent.addConstraints([
				NSLayoutConstraint(item: logoImageView,	attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view,
					attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: -1 * (logoImage.size.height / 2)),
				NSLayoutConstraint(item: logoImageView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view,
					attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0)
			])
		}

		view.addConstraints([
			NSLayoutConstraint(item: title, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view,
				attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 40),
			NSLayoutConstraint(item: title, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view,
				attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: title, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view,
				attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0)
		])

		view.addConstraints([
			NSLayoutConstraint(item: msg, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: title,
				attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 10),
			NSLayoutConstraint(item: msg, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view,
				attribute: NSLayoutAttribute.leading, multiplier: 1.0, 	constant: 15),
			NSLayoutConstraint(item: msg, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view,
				attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: -15)
		])

		for (index, button) in buttons.enumerated() {
			view.addConstraints([
				NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view,
					attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0),
				NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view,
					attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0)
			])

			if (index == 0) {
				view.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal,
					toItem: msg, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 20))
			}
			else {
				let topConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal,
					toItem: buttons[index-1], attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: buttonTop)
				view.addConstraint(topConstraint)
				buttonTopConstraints.append(topConstraint)
				
				let heightConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal,
					toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: buttonHeight)
				view.addConstraint(heightConstraint)
				buttonHeightConstraints.append(heightConstraint)
			}
		}

		progressView.addConstraints([
			NSLayoutConstraint(item: spinner, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: progressView,
				attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: spinner, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: progressView,
				attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0),
			
			NSLayoutConstraint(item: progressLabel, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: spinner,
				attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 10),
			NSLayoutConstraint(item: progressLabel, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: progressView,
				attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0)
		])

		view.addConstraint(
			NSLayoutConstraint(item: progressView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view,
				attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0))

		if (buttons.count > 0) {
			view.addConstraints([
				NSLayoutConstraint(item: progressView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: buttons[0],
					attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0),
				NSLayoutConstraint(item: progressView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: buttons[0],
					attribute: NSLayoutAttribute.height, multiplier: 1.0, constant: 0)
				])
		}
		else {
			view.addConstraints([
				NSLayoutConstraint(item: progressView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: msg,
					attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 10),
				NSLayoutConstraint(item: progressView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: msg,
					attribute: NSLayoutAttribute.height, multiplier: 1.0, constant: 0)
				])
		}

		progressViewWidthConstraint =  NSLayoutConstraint(item: progressView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil,
			attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: progressLabel.frame.width + 30)

		if let constraint = progressViewWidthConstraint {
			view.addConstraint(constraint)
		}
		
		parent.addConstraint(
			NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: parent,
				attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0)
		)

		if (buttons.count > 0) {
			parent.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal,
				toItem: buttons[buttons.count-1], attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 20))
		}
		else {
			parent.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal,
				toItem: progressView, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 20))
		}
	}
	
	
	func buttonPressed(_ sender: UIButton!) {
		buttonHandler?(sender.tag)
	}
	
	
	func close() {
		logoImageView?.removeFromSuperview()
		view.removeFromSuperview()
		backView.removeFromSuperview()
	}
	
	
	func showProgressIndicator(_ progressText: String) {
		for button in buttons {
			button.isHidden = true
		}
		
		for constraint in buttonHeightConstraints {
			constraint.constant = 0
		}
		
		for constraint in buttonTopConstraints {
			constraint.constant = 0
		}
		
		spinner.startAnimating()
		progressView.isHidden = false

		updateProgressIndicator(progressText)
	}
	
	
	func hideProgressIndicator() {
		spinner.stopAnimating()
		progressView.isHidden = true
		
		for button in buttons {
			button.isHidden = false
		}
		
		for constraint in buttonHeightConstraints {
			constraint.constant = buttonHeight
		}

		for constraint in buttonTopConstraints {
			constraint.constant = buttonTop
		}
	}
	
	
	func updateProgressIndicator(_ progressText: String) {
		
		DispatchQueue.main.async {
			self.progressLabel.text = progressText
			self.progressLabel.sizeToFit()
		
			if let constraint = self.progressViewWidthConstraint {
				constraint.constant = self.progressLabel.frame.width + 30
			}
		}
	}
	
}

