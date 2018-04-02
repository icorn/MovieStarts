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
                        UIApplication.shared.open(linkURL, options: [:], completionHandler: nil)
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
            self.attributedString?.addAttributes([NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue,
                                                  NSAttributedStringKey.foregroundColor: UIColor.blue], range: range)
            self.ranges?.append(range)
        }
        
        self.attributedString?.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 15.0), range: NSMakeRange(0, text.count))
    }
}
