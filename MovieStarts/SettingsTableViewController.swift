//
//  SettingsTableViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 08.09.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {

	@IBOutlet weak var imdbLabel: UILabel!
	@IBOutlet weak var youtubeLabel: UILabel!
	@IBOutlet weak var imdbSwitch: UISwitch!
	@IBOutlet weak var youtubeSwitch: UISwitch!
	@IBOutlet weak var aboutLabel: UILabel!
	@IBOutlet weak var rateLabel: UILabel!
	@IBOutlet weak var timePicker: UIPickerView!
	@IBOutlet weak var notificationLabel: UILabel!
	@IBOutlet weak var notificationTimeTableCell: UITableViewCell!
	@IBOutlet weak var notificationSwitch: UISwitch!
	@IBOutlet weak var notificationTimeLabel: UILabel!

	let sectionUseApps			= 0
	let sectionNotifications	= 1
	let sectionAbout			= 2
	
	let itemRate		= 0
	let itemAbout		= 1
	let dayComponent	= 0
	let timeComponent	= 1
	
	var notificationTimeArray = [
			[
				NSLocalizedString("5daysBefore", comment: ""), NSLocalizedString("4daysBefore", comment: ""), NSLocalizedString("3daysBefore", comment: ""),
				NSLocalizedString("2daysBefore", comment: ""), NSLocalizedString("1daysBefore", comment: ""), NSLocalizedString("0daysBefore", comment: "")
			],
			[]
		]
	
	var movieTabBarController: TabBarController? {
		get {
			return navigationController?.parentViewController as? TabBarController
		}
	}

	
    override func viewDidLoad() {
        super.viewDidLoad()

		// fill titles and strings
		navigationItem.title = NSLocalizedString("SettingsLong", comment: "")
		imdbLabel.text = NSLocalizedString("SettingsUseImdb", comment: "")
		youtubeLabel.text = NSLocalizedString("SettingsUseYoutube", comment: "")
		aboutLabel.text = NSLocalizedString("SettingsAbout", comment: "")
		rateLabel.text = NSLocalizedString("SettingsRateTheApp", comment: "")
		notificationLabel.text = NSLocalizedString("SettingsNotifications", comment: "")
		notificationTimeLabel.text = NSLocalizedString("SettingsNotificationTime", comment: "")
		
		imdbSwitch.addTarget(self, action: Selector("imdbSwitchTapped"), forControlEvents: UIControlEvents.TouchUpInside)
		youtubeSwitch.addTarget(self, action: Selector("youtubeSwitchTapped"), forControlEvents: UIControlEvents.TouchUpInside)
		notificationSwitch.addTarget(self, action: Selector("notificationSwitchTapped"), forControlEvents: UIControlEvents.TouchUpInside)
		
		// set up picker view
		for hour in Constants.notificationTimeMin...Constants.notificationTimeMax {
			notificationTimeArray[timeComponent].append(NSDateFormatter.localizedStringFromDate(NSDate().setHour(hour), dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle))
		}
		
		timePicker.delegate = self
		timePicker.dataSource = self
		timePicker.selectRow(notificationTimeArray[dayComponent].count - 1, inComponent: dayComponent, animated: false)
		timePicker.selectRow(5, inComponent: timeComponent, animated: false)
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		// set up the switches
		setUpSwitch(Constants.prefsUseImdbApp, switcher: imdbSwitch, label: imdbLabel, urlString: "imdb:")
		setUpSwitch(Constants.prefsUseYoutubeApp, switcher: youtubeSwitch, label: youtubeLabel, urlString: "youtube:")
		setUpSwitch(Constants.prefsNotifications, switcher: notificationSwitch, label: nil, urlString: nil)
		
		// set up picker
		
		if let day = NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsNotificationDay) as? Int,
		   let time = NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsNotificationTime) as? Int
		{
			timePicker.selectRow(day + Constants.notificationDays - 1, inComponent: dayComponent, animated: false)
			timePicker.selectRow(time - Constants.notificationTimeMin, inComponent: timeComponent, animated: false)
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
			case sectionUseApps:
				return 2
			case sectionNotifications:
				let notificationsOn: Bool? = NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(Constants.prefsNotifications) as? Bool

				if let notificationsOn = notificationsOn where notificationsOn == true {
					return 2
				}
				else {
					return 1
				}
			case sectionAbout:
				return 2
			default:
				return 0
		}
	}
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
			case sectionUseApps: 		return NSLocalizedString("SettingsUseApps", comment: "")
			case sectionNotifications:	return NSLocalizedString("SettingsNotificationsHeader", comment: "")
			default: return nil
		}
	}

	override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch section {
			case sectionUseApps: 		return NSLocalizedString("SettingsUseAppsFooter", comment: "")
			case sectionNotifications:	return NSLocalizedString("SettingsNotificationsFooter", comment: "")
			default: 					return nil
		}
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if (indexPath.section == sectionAbout) {
			if (indexPath.item == itemRate) {
				guard let rateUrl = NSURL(string: "itms-apps://itunes.apple.com/app/id1043041023") else { return }
				UIApplication.sharedApplication().openURL(rateUrl)
			}
			else if (indexPath.item == itemAbout) {
				if let storyboard = self.storyboard {
					if let aboutController: AboutViewController = storyboard.instantiateViewControllerWithIdentifier("AboutViewController") as? AboutViewController {
						navigationController?.pushViewController(aboutController, animated: true)
					}
				}
			}
		}
	}
	
	
	// MARK: - UIPickerView 
 
	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
		return 2
	}
	
	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return notificationTimeArray[component].count
	}

	func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
		var label = UILabel(frame: CGRect(x: 0, y: 0, width: timePicker.rowSizeForComponent(component).width, height: timePicker.rowSizeForComponent(component).height))
		
		if let view = view as? UILabel {
			label = view
		}
		
		label.font = UIFont.systemFontOfSize(22)
		label.text = notificationTimeArray[component][row]

		return label
	}
	
	func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
		switch (component) {
			case dayComponent: return pickerView.frame.width * 0.66
			case timeComponent: return pickerView.frame.width * 0.33
			default: return 0.0
		}
	}
	
	func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		saveNotificationTime()
		NotificationManager.updateFavoriteNotifications(movieTabBarController?.favoriteMovies)
	}
	

	// MARK: - Private helper functions

	
	func imdbSwitchTapped() {
		NSUserDefaults(suiteName: Constants.movieStartsGroup)?.setObject(imdbSwitch.on, forKey: Constants.prefsUseImdbApp)
		NSUserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
	}
	
	func youtubeSwitchTapped() {
		NSUserDefaults(suiteName: Constants.movieStartsGroup)?.setObject(youtubeSwitch.on, forKey: Constants.prefsUseYoutubeApp)
		NSUserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
	}
	
	func notificationSwitchTapped() {
		if (notificationSwitch.on) {
			// notification switch was turned on: try to activate notifications
			UIApplication.sharedApplication().registerUserNotificationSettings(
				UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, /*UIUserNotificationType.Badge,*/ UIUserNotificationType.Sound], categories: nil))
			saveNotificationTime()
			
			// if registration was successfull, the AppDelegate calls "switchNotifications(true)"
		}
		else {
			// notification switch was turned off
			switchNotifications(false)
		}
	}

	func switchNotifications(on: Bool) {
		if (notificationSwitch != nil) {
			notificationSwitch.setOn(on, animated: false)
		}
		
		NSUserDefaults(suiteName: Constants.movieStartsGroup)?.setObject(on, forKey: Constants.prefsNotifications)
		NSUserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()

		if (on) {
			if (tableView != nil) {
				tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: sectionNotifications)], withRowAnimation: UITableViewRowAnimation.Middle)
			}
			NotificationManager.updateFavoriteNotifications(movieTabBarController?.favoriteMovies)
		}
		else {
			let indexPathToDelete = NSIndexPath(forRow: 1, inSection: sectionNotifications)

			if ((tableView != nil) && (tableView.cellForRowAtIndexPath(indexPathToDelete) != nil)) {
				// delete time-setting-row if it exists
				tableView.deleteRowsAtIndexPaths([indexPathToDelete], withRowAnimation: UITableViewRowAnimation.Middle)
			}
			
			NotificationManager.removeAllFavoriteNotifications()
		}
	}
	
	private func saveNotificationTime() {
		let day = timePicker.selectedRowInComponent(dayComponent) - Constants.notificationDays + 1
		let time = timePicker.selectedRowInComponent(timeComponent) + Constants.notificationTimeMin
		
		NSUserDefaults(suiteName: Constants.movieStartsGroup)?.setObject(day, forKey: Constants.prefsNotificationDay)
		NSUserDefaults(suiteName: Constants.movieStartsGroup)?.setObject(time, forKey: Constants.prefsNotificationTime)
		NSUserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
	}
	
	private func setUpSwitch(prefKey: String, switcher: UISwitch, label: UILabel?, urlString: String?) {
		
		// set switch on or off
		let useApp: Bool? = NSUserDefaults(suiteName: Constants.movieStartsGroup)?.objectForKey(prefKey) as? Bool
		
		if let useApp = useApp where useApp == true {
			switcher.on = true
		}
		else {
			switcher.on = false
		}
		
		if let label = label, urlString = urlString {
			// set switch to enabled or not
			let url: NSURL? = NSURL(string: urlString)
		
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
}
