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
		
		if (movie.releaseDate[movie.currentCountry.countryArrayIndex].compare(Date(timeIntervalSince1970: 0)) == ComparisonResult.orderedDescending)
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
			
			directorsString = directorsString.substringByRemovingLastCharacters(numberOfCharacters: 2)
			let label = createValueLabelWithText(directorsString)
			label.numberOfLines = movie.directors.count
			valueLabels.append(label)
		}
		
		let maxTitleWidth = getMaxLabelWidth(labels: titleLabels)
		let maxValueWidth = getMaxLabelWidth(labels: valueLabels)
		
		for i in 0 ..< titleLabels.count {
			addInfoToStackView(titleLabel: titleLabels[i], valueLabel: valueLabels[i], maxTitleWidth: maxTitleWidth, maxValueWidth: maxValueWidth);
		}
	}
	
	fileprivate final func addInfoToStackView(titleLabel: UILabel, valueLabel: UILabel, maxTitleWidth: CGFloat, maxValueWidth: CGFloat) {
		let view = UIView()
		let paddingHorizontal: CGFloat = 10.0
		let paddingCenter: CGFloat = 5.0
		let paddingVertical: CGFloat = 2.0
		
		// calculate height of view and labels
		
		var labelfont = UIFont.systemFont(ofSize: 14.0)
		
		if let realLabelfont = valueLabel.font {
			labelfont = realLabelfont
		}
		
		let textAttributes = [NSAttributedStringKey.font: labelfont]
		var titleLabelHeight: CGFloat = 24.0
		
		if let titleRect = titleLabel.text?.boundingRect(with: CGSize(width: 320, height: 200),
		    options: .usesLineFragmentOrigin, attributes: textAttributes, context: nil)
		{
			titleLabelHeight = titleRect.size.height + 1
		}
		
		var valueLabelHeight: CGFloat = 24.0
		
		if let valueRect = valueLabel.text?.boundingRect(with: CGSize(width: 320, height: 200),
			options: .usesLineFragmentOrigin, attributes: textAttributes, context: nil)
		{
			valueLabelHeight = valueRect.size.height + 1
		}
		
		let viewHeight = valueLabelHeight + 2 * paddingVertical

		// set up view and labels

		view.heightAnchor.constraint(equalToConstant: viewHeight).isActive = true
		view.widthAnchor.constraint(equalToConstant: paddingHorizontal + maxTitleWidth + paddingCenter +
			maxValueWidth + paddingHorizontal).isActive = true
		
		titleLabel.frame = CGRect(x: 0.0, y: paddingVertical, width: maxTitleWidth + paddingHorizontal, height: titleLabelHeight)
		titleLabel.textAlignment = NSTextAlignment.right
		
		valueLabel.frame = CGRect(x: maxTitleWidth + paddingHorizontal + paddingCenter,
		                          y: paddingVertical,
		                          width: maxValueWidth + paddingHorizontal,
		                          height: valueLabelHeight)
		view.addSubview(titleLabel)
		view.addSubview(valueLabel)
		
		infoStackView.addArrangedSubview(view)
	}
	
	fileprivate final func createTitleLabelWithText(_ text: String) -> UILabel {
		let label = UILabel()
		label.text = text
		label.font = UIFont.systemFont(ofSize: 14.0)
		return label
	}
	
	fileprivate final func createValueLabelWithText(_ text: String) -> UILabel {
		let label = UILabel()
		label.text = text
		label.font = UIFont.systemFont(ofSize: 14.0)
		return label
	}

	fileprivate final func getMaxLabelWidth(labels: [UILabel]) -> CGFloat {
		var maxWidth: CGFloat = 0.0
		
		for label in labels {
			guard let labelfont = label.font else { continue }
			let textAttributes = [NSAttributedStringKey.font: labelfont]
			
			let rect = label.text?.boundingRect(with: CGSize(width: 320, height: 200),
			                                    options: .usesLineFragmentOrigin,
			                                    attributes: textAttributes,
	                                            context: nil)
			if let rect = rect {
				if (rect.size.width > maxWidth) {
					maxWidth = rect.size.width
				}
			}
		}
		
		return maxWidth
	}
}
