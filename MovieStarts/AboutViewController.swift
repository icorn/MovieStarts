//
//  AboutViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 15.09.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController
{
	@IBOutlet weak var versionLabel: UILabel!
	@IBOutlet weak var taglineLabel: UILabel!
	@IBOutlet weak var supportHeadlineLabel: UILabel!
	@IBOutlet weak var webHeadlineLabel: UILabel!
	@IBOutlet weak var emailHeadlineLabel: UILabel!
	@IBOutlet weak var twitterHeadlineLabel: UILabel!
	@IBOutlet weak var swiftLabel: UILabel!
    @IBOutlet weak var acknowledgmentsButton: UIButton!
    @IBOutlet weak var privacyButton: UIButton!
    
	@IBOutlet weak var webLinkButton: UIButton!
	@IBOutlet weak var emailLinkButton: UIButton!
	@IBOutlet weak var twitterLinkButton: UIButton!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var impressumLabel: UILabel!
    @IBOutlet weak var impressumHeadlineLabel: UILabel!
    
	
    override func viewDidLoad()
    {
        super.viewDidLoad()

		let appInfo = Bundle.main.infoDictionary
		
		if let appInfo = appInfo, let version = appInfo["CFBundleShortVersionString"] as? String
        {
			versionLabel.text = NSLocalizedString("Version", comment: "") + " " + version
		}

		taglineLabel.text = NSLocalizedString("TagLine", comment: "")
		
		supportHeadlineLabel.text = NSLocalizedString("supportHeadline", comment: "")
		webHeadlineLabel.text = NSLocalizedString("webHeadline", comment: "")
		emailHeadlineLabel.text = NSLocalizedString("emailHeadline", comment: "")
		twitterHeadlineLabel.text = NSLocalizedString("twitterHeadline", comment: "")
		swiftLabel.text = NSLocalizedString("swift", comment: "")
        impressumHeadlineLabel.text = NSLocalizedString("ImpressumHeadline", comment: "")
        impressumLabel.text = NSLocalizedString("Impressum", comment: "")
        
        acknowledgmentsButton.setTitle(NSLocalizedString("Acknowledgements", comment: ""), for: UIControlState.normal)
        acknowledgmentsButton.addTarget(self, action: #selector(AboutViewController.acknowledgmentsButtonTapped(_:)), for: UIControlEvents.touchUpInside)

        privacyButton.setTitle(NSLocalizedString("PrivacyStatement", comment: ""), for: UIControlState.normal)
        privacyButton.addTarget(self, action: #selector(AboutViewController.privacyButtonTapped(_:)), for: UIControlEvents.touchUpInside)
}
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        AnalyticsClient.trackScreenName("About Screen")
    }

    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()

        if #available(iOS 11.0, *)
        {
            guard let keyWindow = UIApplication.shared.keyWindow else { return }
            self.leadingConstraint.constant = keyWindow.safeAreaInsets.left
            self.trailingConstraint.constant = keyWindow.safeAreaInsets.right
        }
    }
    
    
    // MARK: - Handlers
    
	@IBAction func webLinkTouched(_ sender: AnyObject)
    {
		let url = URL(string: "http://MovieStartsApp.com")

		if let url = url , UIApplication.shared.canOpenURL(url)
        {
            UIApplication.shared.open(url, options: [:], completionHandler: { (Bool) in })
		}
	}
	
	@IBAction func emailLinkTouched(_ sender: AnyObject)
    {
		let url = URL(string: "mailto:info@MovieStartsApp.com")
		
		if let url = url , UIApplication.shared.canOpenURL(url)
        {
            UIApplication.shared.open(url, options: [:], completionHandler: { (Bool) in })
		}
	}
	
	@IBAction func twitterLinkgTouched(_ sender: AnyObject)
    {
		let url = URL(string: "https://twitter.com/MovieStartsApp")
		
		if let url = url , UIApplication.shared.canOpenURL(url)
        {
            UIApplication.shared.open(url, options: [:], completionHandler: { (Bool) in })
		}
	}

    @objc func acknowledgmentsButtonTapped(_ sender: UIButton!)
    {
        if let ackController = storyboard?.instantiateViewController(withIdentifier: "AcknowledgementsViewController") as? AcknowledgementsViewController
        {
            navigationController?.pushViewController(ackController, animated: true)
        }
    }

    @objc func privacyButtonTapped(_ sender: UIButton!)
    {
        if let acceptPrivacyViewController = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyViewController") as? AcceptPrivacyViewController
        {
            navigationController?.pushViewController(acceptPrivacyViewController, animated: true)
        }

/*
        if let bigLabelController = storyboard?.instantiateViewController(withIdentifier: "BigLabelViewController") as? BigLabelViewController
        {
            bigLabelController.createAttributedStringForText(NSLocalizedString("PrivacyStatementText", comment: ""),
                                                             withLinks: ["https://www.google.com/policies/privacy/",
                                                                         "https://adssettings.google.com/authenticated",
                                                                         "https://datenschutz-generator.de/"])
            bigLabelController.navigationItem.title = NSLocalizedString("PrivacyStatement", comment: "")
            navigationController?.pushViewController(bigLabelController, animated: true)
        }
 */
    }
    
}
