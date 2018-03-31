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
    @IBOutlet weak var bigLabel: UITextView!
    @IBOutlet weak var bigLabelHeightConstraint: NSLayoutConstraint!
    public var contentText : String?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let contentText = contentText
        {
            bigLabel.text = contentText
            let labelSize = bigLabel.sizeThatFits(CGSize(width: self.bigLabel.frame.width, height: CGFloat.greatestFiniteMagnitude))
            self.bigLabelHeightConstraint.constant = labelSize.height
        }
    }
}
