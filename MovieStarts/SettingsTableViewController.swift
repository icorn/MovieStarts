//
//  SettingsTableViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 08.09.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UITableViewDelegate {

	@IBOutlet weak var imdbLabel: UILabel!
	@IBOutlet weak var youtubeLabel: UILabel!
	@IBOutlet weak var imdbSwitch: UISwitch!
	@IBOutlet weak var youtubeSwitch: UISwitch!
	@IBOutlet weak var aboutLabel: UILabel!
	
	let sectionUseApps	= 0
	let sectionAbout	= 1
	
    override func viewDidLoad() {
        super.viewDidLoad()

		navigationItem.title = NSLocalizedString("SettingsLong", comment: "")
		
		imdbLabel.text = NSLocalizedString("SettingsUseImdb", comment: "")
		youtubeLabel.text = NSLocalizedString("SettingsUseYoutube", comment: "")
		aboutLabel.text = NSLocalizedString("SettingsAbout", comment: "")
		
		imdbSwitch.addTarget(self, action: Selector("imdbSwitchTapped"), forControlEvents: UIControlEvents.TouchUpInside)
		youtubeSwitch.addTarget(self, action: Selector("youtubeSwitchTapped"), forControlEvents: UIControlEvents.TouchUpInside)
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		// set up the two switches
		setUpSwitch(Constants.PREFS_USE_IMDB_APP, switcher: imdbSwitch, label: imdbLabel, urlString: "imdb:")
		setUpSwitch(Constants.PREFS_USE_YOUTUBE_APP, switcher: youtubeSwitch, label: youtubeLabel, urlString: "youtube:")
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
			case sectionUseApps: 	return 2
			case sectionAbout: 		return 1
			default: 				return 0
		}
	}
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
			case 0: return NSLocalizedString("SettingsUseApps", comment: "")
			default: return nil
		}
	}

	override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		if section == 0 {
			return NSLocalizedString("SettingsUseAppsFooter", comment: "")
		}
		else {
			return nil
		}
	}
	
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		if (indexPath.section == sectionAbout) {
			if let saveStoryboard = self.storyboard {
				var aboutController: AboutViewController = saveStoryboard.instantiateViewControllerWithIdentifier("AboutViewController") as! AboutViewController
				navigationController?.pushViewController(aboutController, animated: true)
			}
		}
	}
	
		
	// MARK: - Private helper functions

	
	func imdbSwitchTapped() {
		NSUserDefaults(suiteName: Constants.MOVIESTARTS_GROUP)?.setObject(imdbSwitch.on, forKey: Constants.PREFS_USE_IMDB_APP)
	}
	
	func youtubeSwitchTapped() {
		NSUserDefaults(suiteName: Constants.MOVIESTARTS_GROUP)?.setObject(youtubeSwitch.on, forKey: Constants.PREFS_USE_YOUTUBE_APP)
	}
	
	private func setUpSwitch(prefKey: String, switcher: UISwitch, label: UILabel, urlString: String) {
		
		// set imdb switch on or off
		
		var useApp: Bool? = NSUserDefaults(suiteName: Constants.MOVIESTARTS_GROUP)?.objectForKey(prefKey) as! Bool?
		
		if let useApp = useApp where useApp == true {
			switcher.on = true
		}
		else {
			switcher.on = false
		}
		
		// set imdb switch to enabled or not
		var url: NSURL? = NSURL(string: urlString)
		
		if let url = url {
			if UIApplication.sharedApplication().canOpenURL(url) {
				// app is installed
				switcher.enabled = true
				label.enabled = true
			}
			else {
				// app is *not* installed
				switcher.enabled = false
				label.enabled = false
			}
		}
		else {
			// this actually cannot happen. still:
			switcher.enabled = false
			label.enabled = false
		}
	}
}
