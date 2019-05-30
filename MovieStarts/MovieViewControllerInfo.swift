//
//  MovieViewControllerInfoStackview.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 13.07.16.
//  Copyright © 2016 Oliver Eichhorn. All rights reserved.
//

import Foundation
import UIKit


extension MovieViewController
{
	final func showInfos()
    {
		guard let movie = self.movie else { return }
		
		var titleLabels: [UILabel] = []
		var valueLabels: [UILabel] = []
		
		// directors
		
		if (movie.directors.count == 1)
        {
			titleLabels.append(createTitleLabelWithText(NSLocalizedString("Director", comment: "") + ":"))
			valueLabels.append(createValueLabelWithText(movie.directors[0], andNumberOfLines: 1))
		}
		else if (movie.directors.count > 1)
        {
			titleLabels.append(createTitleLabelWithText(NSLocalizedString("Directors", comment: "") + ":"))
			
			var directorsString = ""
			for director in movie.directors
            {
				directorsString = directorsString + director + "\n"
			}
			
            directorsString.removeLast()
			let label = createValueLabelWithText(directorsString, andNumberOfLines: movie.directors.count)
			label.numberOfLines = movie.directors.count
			valueLabels.append(label)
		}
		
        // writers
        
        let writers = self.findScreenplayWritersInCrew(movie.crewWriting)
        
        if (writers.count == 1)
        {
            titleLabels.append(createTitleLabelWithText(NSLocalizedString("Screenplay", comment: "") + ":"))
            valueLabels.append(createValueLabelWithText(writers[0], andNumberOfLines: 1))
        }
        else if (writers.count > 1)
        {
            titleLabels.append(createTitleLabelWithText(NSLocalizedString("Screenplay", comment: "") + ":"))
            
            var writersString = ""
            for writer in writers
            {
                writersString = writersString + writer + "\n"
            }
  
            writersString.removeLast()
            let label = createValueLabelWithText(writersString, andNumberOfLines: writers.count)
            label.numberOfLines = writers.count
            valueLabels.append(label)
        }
        
        // release date
        
        if (movie.releaseDate[movie.currentCountry.countryArrayIndex].compare(Date(timeIntervalSince1970: 0)) == ComparisonResult.orderedDescending)
        {
            titleLabels.append(createTitleLabelWithText(NSLocalizedString("ReleaseDate", comment: "") + ":"))
            valueLabels.append(createValueLabelWithText(movie.releaseDateString, andNumberOfLines: 1))
        }
        
        // homepage
        
        if let homepage = movie.optimizedHomepageStringForLangIndex(movie.currentCountry.languageArrayIndex)
        {
            titleLabels.append(createTitleLabelWithText(NSLocalizedString("Homepage", comment: "") + ":"))
            let valueLabel = createValueLabelWithText(homepage, andNumberOfLines: 1)
            valueLabel.textColor = UIColor.blue
            valueLabel.isUserInteractionEnabled = true
            valueLabel.lineBreakMode = .byTruncatingTail
            
            let rec = UITapGestureRecognizer(target: self, action: #selector(MovieViewController.homepageTapped(_:)))
            valueLabel.addGestureRecognizer(rec)
            valueLabels.append(valueLabel)
        }
        
        // budget
        
        if let budget = movie.budgetString
        {
            titleLabels.append(createTitleLabelWithText(NSLocalizedString("Budget", comment: "") + ":"))
            valueLabels.append(createValueLabelWithText(budget, andNumberOfLines: 1))
        }

        // calculate layout
        
		let maxTitleWidth = getMaxLabelWidth(labels: titleLabels)
		let maxValueWidth = getMaxLabelWidth(labels: valueLabels)
		
		for i in 0 ..< titleLabels.count
        {
			addInfoToStackView(titleLabel: titleLabels[i], valueLabel: valueLabels[i], maxTitleWidth: maxTitleWidth, maxValueWidth: maxValueWidth);
		}
	}
    
    fileprivate final func findScreenplayWritersInCrew(_ crew: [String]) -> [String]
    {
        var writers: [String] = []

        for crewMember in crew
        {
            if (crewMember.hasSuffix("||Writer") || crewMember.hasSuffix("||Screenplay"))
            {
                let components = crewMember.components(separatedBy: "||")
                
                if ((components.count > 0) && (writers.contains(components[0]) == false))
                {
                    writers.append(components[0])
                }
            }
        }

        return writers;
    }
	
	fileprivate final func addInfoToStackView(titleLabel: UILabel, valueLabel: UILabel, maxTitleWidth: CGFloat, maxValueWidth: CGFloat)
    {
		let view = UIView()
		let paddingCenter: CGFloat = 5.0
		let paddingVertical: CGFloat = 2.0
		
		// calculate height of view and labels
		
		var labelfont = UIFont.systemFont(ofSize: 14.0)
		
		if let realLabelfont = valueLabel.font
        {
			labelfont = realLabelfont
		}
		
		let textAttributes = [NSAttributedString.Key.font: labelfont]
		var titleLabelHeight: CGFloat = 24.0
		
		if let titleRect = titleLabel.text?.boundingRect(with: CGSize(width: 320, height: 200),
		    options: .usesLineFragmentOrigin, attributes: textAttributes, context: nil)
		{
			titleLabelHeight = titleRect.size.height
		}

        let valueLabelHeight = "Ag".boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
                                                 options: .usesLineFragmentOrigin, attributes: textAttributes, context: nil).size.height * CGFloat(valueLabel.numberOfLines)
		let viewHeight = valueLabelHeight + 2.0 * paddingVertical

		// set up view and labels

		view.heightAnchor.constraint(equalToConstant: viewHeight).isActive = true
		view.widthAnchor.constraint(equalToConstant: maxTitleWidth + paddingCenter + maxValueWidth).isActive = true
		
		titleLabel.frame = CGRect(x: 0.0, y: paddingVertical, width: maxTitleWidth, height: titleLabelHeight)
		titleLabel.textAlignment = NSTextAlignment.right
		
		valueLabel.frame = CGRect(x: maxTitleWidth + paddingCenter,
		                          y: paddingVertical,
                                  // ugly: we don't have the width of the stackview, so use the screen width and
                                  // subtract 32 (the combined bigStackViews padding left and right)
		                          width: UIScreen.main.bounds.size.width - (maxTitleWidth + paddingCenter) - 32.0,
		                          height: valueLabelHeight)
		view.addSubview(titleLabel)
		view.addSubview(valueLabel)
        
		infoStackView.addArrangedSubview(view)
	}
	
	fileprivate final func createTitleLabelWithText(_ text: String) -> UILabel
    {
		let label = UILabel()
		label.text = text
		label.font = UIFont.boldSystemFont(ofSize: 14.0)
		return label
	}
	
    fileprivate final func createValueLabelWithText(_ text: String, andNumberOfLines numOfLines: Int) -> UILabel
    {
		let label = UILabel()
		label.text = text
		label.font = UIFont.systemFont(ofSize: 14.0)
        label.numberOfLines = numOfLines
		return label
	}

	fileprivate final func getMaxLabelWidth(labels: [UILabel]) -> CGFloat
    {
		var maxWidth: CGFloat = 0.0
		
		for label in labels
        {
			guard let labelfont = label.font else { continue }
			let textAttributes = [NSAttributedString.Key.font: labelfont]
			
			let rect = label.text?.boundingRect(with: CGSize(width: 320, height: 200),
			                                    options: .usesLineFragmentOrigin,
			                                    attributes: textAttributes,
	                                            context: nil)
			if let rect = rect
            {
				if (rect.size.width > maxWidth)
                {
					maxWidth = rect.size.width
				}
			}
		}
		
		return maxWidth
	}
    
    
    @objc func homepageTapped(_ recognizer: UITapGestureRecognizer)
    {
        guard let movie = movie else { return }
        let url = URL(string: movie.homepage[movie.currentCountry.languageArrayIndex])
        
        if let url = url, UIApplication.shared.canOpenURL(url)
        {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: { (Bool) in })
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
