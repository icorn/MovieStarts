//
//  AboutViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 15.09.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

	@IBOutlet weak var versionLabel: UILabel!
	@IBOutlet weak var taglineLabel: UILabel!
	@IBOutlet weak var developerHeadlineLabel: UILabel!
	@IBOutlet weak var supportHeadlineLabel: UILabel!
	@IBOutlet weak var webHeadlineLabel: UILabel!
	@IBOutlet weak var emailHeadlineLabel: UILabel!
	@IBOutlet weak var twitterHeadlineLabel: UILabel!
	@IBOutlet weak var swiftLabel: UILabel!
	@IBOutlet weak var appzgearLabel: UILabel!
	@IBOutlet weak var reachabilityLabel: UILabel!
	@IBOutlet weak var mitLicenseLabel: UILabel!
	
	@IBOutlet weak var webLinkButton: UIButton!
	@IBOutlet weak var emailLinkButton: UIButton!
	@IBOutlet weak var twitterLinkButton: UIButton!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

		var appInfo = NSBundle.mainBundle().infoDictionary
		
		if let appInfo = appInfo, version = appInfo["CFBundleShortVersionString"] as? String {
			versionLabel.text = NSLocalizedString("Version", comment: "") + " " + version
		}

		taglineLabel.text = NSLocalizedString("TagLine", comment: "")
		
		developerHeadlineLabel.text = NSLocalizedString("developerHeadline", comment: "")
		supportHeadlineLabel.text = NSLocalizedString("supportHeadline", comment: "")
		webHeadlineLabel.text = NSLocalizedString("webHeadline", comment: "")
		emailHeadlineLabel.text = NSLocalizedString("emailHeadline", comment: "")
		twitterHeadlineLabel.text = NSLocalizedString("twitterHeadline", comment: "")
		swiftLabel.text = NSLocalizedString("swift", comment: "")
		appzgearLabel.text = NSLocalizedString("appzgear", comment: "")
		reachabilityLabel.text = NSLocalizedString("reachability", comment: "")
		mitLicenseLabel.text = NSLocalizedString("mitLicense", comment: "")
	}

	@IBAction func webLinkTouched(sender: AnyObject) {
		var url = NSURL(string: "http://calibrateapp.com")

		if let url = url where UIApplication.sharedApplication().canOpenURL(url) {
			UIApplication.sharedApplication().openURL(url)
		}
	}
	
	@IBAction func emailLinkTouched(sender: AnyObject) {
		var url = NSURL(string: "mailto:info@calibrateapp.com")
		
		if let url = url where UIApplication.sharedApplication().canOpenURL(url) {
			UIApplication.sharedApplication().openURL(url)
		}
	}
	
	@IBAction func twitterLinkgTouched(sender: AnyObject) {
		var url = NSURL(string: "https://twitter.com/CalibrateApp")
		
		if let url = url where UIApplication.sharedApplication().canOpenURL(url) {
			UIApplication.sharedApplication().openURL(url)
		}
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
