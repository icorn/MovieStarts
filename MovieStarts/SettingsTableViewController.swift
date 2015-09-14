//
//  SettingsTableViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 08.09.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

	@IBOutlet weak var imdbLabel: UILabel!
	@IBOutlet weak var youtubeLabel: UILabel!
	@IBOutlet weak var imdbSwitch: UISwitch!
	@IBOutlet weak var youtubeSwitch: UISwitch!
	@IBOutlet weak var aboutLabel: UILabel!
	
	let sectionUseApps	= 0
	let sectionAbout	= 1
	
    override func viewDidLoad() {
        super.viewDidLoad()

		imdbLabel.text = NSLocalizedString("SettingsUseImdb", comment: "")
		youtubeLabel.text = NSLocalizedString("SettingsUseYoutube", comment: "")
		aboutLabel.text = NSLocalizedString("SettingsAbout", comment: "")
		
		imdbSwitch.addTarget(self, action: Selector("imdbSwitchTapped"), forControlEvents: UIControlEvents.TouchUpInside)
		youtubeSwitch.addTarget(self, action: Selector("youtubeSwitchTapped"), forControlEvents: UIControlEvents.TouchUpInside)
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		// set status bar style to dark
		UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
		setNeedsStatusBarAppearanceUpdate()
		
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
	
	func imdbSwitchTapped() {
		NSUserDefaults(suiteName: Constants.MOVIESTARTS_GROUP)?.setObject(imdbSwitch.on, forKey: Constants.PREFS_USE_IMDB_APP)
	}

	func youtubeSwitchTapped() {
		NSUserDefaults(suiteName: Constants.MOVIESTARTS_GROUP)?.setObject(youtubeSwitch.on, forKey: Constants.PREFS_USE_YOUTUBE_APP)
	}

	
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

	
	// MARK: - Private helper functions

	
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
