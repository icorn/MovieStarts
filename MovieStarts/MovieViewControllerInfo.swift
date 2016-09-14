//
//  MovieViewControllerInfoStackview.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 13.07.16.
//  Copyright © 2016 Oliver Eichhorn. All rights reserved.
//

import Foundation
import UIKit


extension MovieViewController {

	final func showInfos() {
		guard let movie = self.movie else { return }
		
		var titleLabels: [UILabel] = []
		var valueLabels: [UILabel] = []
		
		// release date
		
		if (movie.releaseDate[movie.currentCountry.countryArrayIndex].compare(NSDate(timeIntervalSince1970: 0)) == NSComparisonResult.OrderedDescending)
		{
			titleLabels.append(createTitleLabelWithText(NSLocalizedString("ReleaseDate", comment: "") + ":"))
			valueLabels.append(createValueLabelWithText(movie.releaseDateString))
		}
		
		// budget
		
		if let budget = movie.budgetString {
			titleLabels.append(createTitleLabelWithText(NSLocalizedString("Budget", comment: "") + ":"))
			valueLabels.append(createValueLabelWithText(budget))
		}
		
		// directors
		
		if (movie.directors.count == 1) {
			titleLabels.append(createTitleLabelWithText(NSLocalizedString("Director", comment: "") + ":"))
			valueLabels.append(createValueLabelWithText(movie.directors[0]))
		}
		else if (movie.directors.count > 1) {
			titleLabels.append(createTitleLabelWithText(NSLocalizedString("Directors", comment: "") + ":"))
			
			var directorsString = ""
			for director in movie.directors {
				directorsString = directorsString + director + "\n"
			}
			
			directorsString = directorsString.substringToIndex(directorsString.endIndex.predecessor().predecessor())
			
			let label = createValueLabelWithText(directorsString)
			label.numberOfLines = movie.directors.count
			valueLabels.append(label)
		}
		
		let maxTitleWidth = getMaxLabelWidth(titleLabels)
		let maxValueWidth = getMaxLabelWidth(valueLabels)
		
		for i in 0 ..< titleLabels.count {
			addInfoToStackView(titleLabels[i], valueLabel: valueLabels[i], maxTitleWidth: maxTitleWidth, maxValueWidth: maxValueWidth);
		}
	}
	
	private final func addInfoToStackView(titleLabel: UILabel, valueLabel: UILabel, maxTitleWidth: CGFloat, maxValueWidth: CGFloat) {
		let view = UIView()
		let paddingHorizontal: CGFloat = 10.0
		let paddingCenter: CGFloat = 5.0
		let paddingVertical: CGFloat = 2.0
		
		// calculate height of view and labels
		
		let textAttributes = [NSFontAttributeName: valueLabel.font]
		var titleLabelHeight: CGFloat = 24.0
		
		if let titleRect = titleLabel.text?.boundingRectWithSize(CGSizeMake(320, 200),
		    options: .UsesLineFragmentOrigin, attributes: textAttributes, context: nil)
		{
			titleLabelHeight = titleRect.size.height + 1
		}
		
		var valueLabelHeight: CGFloat = 24.0
		
		if let valueRect = valueLabel.text?.boundingRectWithSize(CGSizeMake(320, 200),
			options: .UsesLineFragmentOrigin, attributes: textAttributes, context: nil)
		{
			valueLabelHeight = valueRect.size.height + 1
		}
		
		let viewHeight = valueLabelHeight + 2 * paddingVertical

		// set up view and labels

		view.heightAnchor.constraintEqualToConstant(viewHeight).active = true
		view.widthAnchor.constraintEqualToConstant(paddingHorizontal + maxTitleWidth + paddingCenter +
			maxValueWidth + paddingHorizontal).active = true
		
		titleLabel.frame = CGRect(x: 0.0, y: paddingVertical, width: maxTitleWidth + paddingHorizontal, height: titleLabelHeight)
		titleLabel.textAlignment = NSTextAlignment.Right
		
		valueLabel.frame = CGRect(x: maxTitleWidth + paddingHorizontal + paddingCenter,
		                          y: paddingVertical,
		                          width: maxValueWidth + paddingHorizontal,
		                          height: valueLabelHeight)
		view.addSubview(titleLabel)
		view.addSubview(valueLabel)
		
		infoStackView.addArrangedSubview(view)
	}
	
	private final func createTitleLabelWithText(text: String) -> UILabel {
		let label = UILabel()
		label.text = text
		label.font = UIFont.systemFontOfSize(14.0)
		return label
	}
	
	private final func createValueLabelWithText(text: String) -> UILabel {
		let label = UILabel()
		label.text = text
		label.font = UIFont.systemFontOfSize(14.0)
		return label
	}

	private final func getMaxLabelWidth(labels: [UILabel]) -> CGFloat {
		var maxWidth: CGFloat = 0.0
		
		for label in labels {
			let textAttributes = [NSFontAttributeName: label.font]
			let rect = label.text?.boundingRectWithSize(CGSizeMake(320, 200),
			     options: .UsesLineFragmentOrigin, attributes: textAttributes, context: nil)
			
			if let rect = rect {
				if (rect.size.width > maxWidth) {
					maxWidth = rect.size.width
				}
			}
		}
		
		return maxWidth
	}
}
