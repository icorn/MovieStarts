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
    public var contentText : String?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let contentText = contentText
        {
            bigLabel.text = contentText
        }
    }
}
