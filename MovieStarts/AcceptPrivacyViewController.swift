//
//  AcceptPrivacyViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 21.05.18.
//  Copyright © 2018 Oliver Eichhorn. All rights reserved.
//

import UIKit
import WebKit

class AcceptPrivacyViewController: UIViewController
{
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var webView: WKWebView!
    
    var acceptPrivacyDelegate: AcceptPrivacyDelegate?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.headlineLabel.text = NSLocalizedString("PrivacyStatement", comment: "")
        
        if (self.acceptPrivacyDelegate != nil)
        {
            self.acceptButton.setTitle(NSLocalizedString("AcceptPrivacy", comment: ""), for: .normal)
            self.acceptButton.addTarget(self, action: #selector(AcceptPrivacyViewController.buttonTapped(_:)), for: UIControl.Event.touchUpInside)
        }
        else
        {
            self.acceptButton.isHidden = true
            self.acceptButton.alpha = 1.0
        }
        
        // read privacy statment file
        if let filepath = Bundle.main.path(forResource: NSLocalizedString("PrivacyStatementFile", comment: ""), ofType: "html")
        {
            if let fileContents = try? String.init(contentsOfFile: filepath)
            {
                self.webView.loadHTMLString(fileContents, baseURL: nil)
            }
        }
    }
    
    
    @objc func buttonTapped(_ sender: UIButton!)
    {
        self.acceptPrivacyDelegate?.privacyStatementAccepted()
        self.dismiss(animated: true)
    }
}
