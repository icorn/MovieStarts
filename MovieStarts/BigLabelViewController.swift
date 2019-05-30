//
//  BigLabelViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 10.02.18.
//  Copyright © 2018 Oliver Eichhorn. All rights reserved.
//

import UIKit

class BigLabelViewController: UIViewController
{
    @IBOutlet weak var bigLabel: UILabel!
    public var attributedString : NSMutableAttributedString?
    private var ranges: [NSRange]?
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let attributedString = attributedString
        {
            bigLabel.attributedText = attributedString
        }
    }

    @IBAction func labelTapped(_ sender: Any)
    {
        if let rec = sender as? UITapGestureRecognizer,
           let ranges = self.ranges
        {
            for range in ranges
            {
                if (rec.didTapAttributedTextInLabel(label: bigLabel, inRange: range))
                {
                    if let linkString = self.bigLabel.attributedText?.attributedSubstring(from: range).string,
                       let linkURL = URL(string: linkString)
                    {
                        UIApplication.shared.open(linkURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                        break
                    }
                }
            }
        }
    }
    
    open func createAttributedStringForText(_ text: String, withLinks links: [String])
    {
        self.attributedString = NSMutableAttributedString(string: text)
        self.ranges = []
        
        for link in links
        {
            let range = (text as NSString).range(of: link)
            self.attributedString?.addAttributes([NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue,
                                                  NSAttributedString.Key.foregroundColor: UIColor.blue], range: range)
            self.ranges?.append(range)
        }
        
        self.attributedString?.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 15.0), range: NSMakeRange(0, text.count))
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
