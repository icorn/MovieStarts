//
//  AcceptPrivacyViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 21.05.18.
//  Copyright © 2018 Oliver Eichhorn. All rights reserved.
//

import UIKit

class AcceptPrivacyViewController: UIViewController
{
    @IBOutlet weak var privacyLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var headlineLabel: UILabel!
    
    var acceptPrivacyDelegate: AcceptPrivacyDelegate?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.privacyLabel.text = NSLocalizedString("PrivacyStatementText", comment: "")
        self.headlineLabel.text = NSLocalizedString("PrivacyStatement", comment: "")
        self.acceptButton.setTitle(NSLocalizedString("AcceptPrivacy", comment: ""), for: .normal)
        self.acceptButton.addTarget(self, action: #selector(AcceptPrivacyViewController.buttonTapped(_:)), for: UIControlEvents.touchUpInside)
    }
    
    
    @objc func buttonTapped(_ sender: UIButton!)
    {
        self.acceptPrivacyDelegate?.privacyStatementAccepted()
        self.dismiss(animated: true)
    }
}
