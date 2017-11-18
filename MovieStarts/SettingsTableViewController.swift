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
			return navigationController?.parent as? TabBarController
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
		
		imdbSwitch.addTarget(self, action: #selector(SettingsTableViewController.imdbSwitchTapped), for: UIControlEvents.touchUpInside)
		youtubeSwitch.addTarget(self, action: #selector(SettingsTableViewController.youtubeSwitchTapped), for: UIControlEvents.touchUpInside)
		notificationSwitch.addTarget(self, action: #selector(SettingsTableViewController.notificationSwitchTapped), for: UIControlEvents.touchUpInside)
		
		// set up picker view
		for hour in Constants.notificationTimeMin...Constants.notificationTimeMax {
			notificationTimeArray[timeComponent].append(DateFormatter.localizedString(from: Date().setHour(hour), dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.short))
		}
		
		timePicker.delegate = self
		timePicker.dataSource = self
		timePicker.selectRow(notificationTimeArray[dayComponent].count - 1, inComponent: dayComponent, animated: false)
		timePicker.selectRow(5, inComponent: timeComponent, animated: false)
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// set up the switches
		setUpSwitch(Constants.prefsUseImdbApp, switcher: imdbSwitch, label: imdbLabel, urlString: "imdb:")
		setUpSwitch(Constants.prefsUseYoutubeApp, switcher: youtubeSwitch, label: youtubeLabel, urlString: "youtube:")
		setUpSwitch(Constants.prefsNotifications, switcher: notificationSwitch, label: nil, urlString: nil)
		
		// set up picker
		
		if let day = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsNotificationDay) as? Int,
		   let time = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsNotificationTime) as? Int
		{
			timePicker.selectRow(day + Constants.notificationDays - 1, inComponent: dayComponent, animated: false)
			timePicker.selectRow(time - Constants.notificationTimeMin, inComponent: timeComponent, animated: false)
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
			case sectionUseApps:
				return 2
			case sectionNotifications:
				let notificationsOn: Bool? = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsNotifications) as? Bool

				if let notificationsOn = notificationsOn , notificationsOn == true {
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
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
			case sectionUseApps: 		return NSLocalizedString("SettingsUseApps", comment: "")
			case sectionNotifications:	return NSLocalizedString("SettingsNotificationsHeader", comment: "")
			default: return nil
		}
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch section {
			case sectionUseApps: 		return NSLocalizedString("SettingsUseAppsFooter", comment: "")
			case sectionNotifications:	return NSLocalizedString("SettingsNotificationsFooter", comment: "")
			default: 					return nil
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if ((indexPath as NSIndexPath).section == sectionAbout) {
			if ((indexPath as NSIndexPath).item == itemRate) {
				guard let rateUrl = URL(string: "itms-apps://itunes.apple.com/app/id1043041023") else { return }
				UIApplication.shared.openURL(rateUrl)
			}
			else if ((indexPath as NSIndexPath).item == itemAbout) {
				if let storyboard = self.storyboard {
					if let aboutController: AboutViewController = storyboard.instantiateViewController(withIdentifier: "AboutViewController") as? AboutViewController {
						navigationController?.pushViewController(aboutController, animated: true)
					}
				}
			}
		}
	}
	
	
	// MARK: - UIPickerView 
 
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 2
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return notificationTimeArray[component].count
	}

	func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
		var label = UILabel(frame: CGRect(x: 0, y: 0, width: timePicker.rowSize(forComponent: component).width, height: timePicker.rowSize(forComponent: component).height))
		
		if let view = view as? UILabel {
			label = view
		}
		
		label.font = UIFont.systemFont(ofSize: 22)
		label.text = notificationTimeArray[component][row]

		return label
	}
	
	func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
		switch (component) {
			case dayComponent: return pickerView.frame.width * 0.66
			case timeComponent: return pickerView.frame.width * 0.33
			default: return 0.0
		}
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		saveNotificationTime()
		NotificationManager.updateFavoriteNotifications(favoriteMovies: movieTabBarController?.favoriteMovies)
	}
	

	// MARK: - Private helper functions

	
	@objc func imdbSwitchTapped() {
		UserDefaults(suiteName: Constants.movieStartsGroup)?.set(imdbSwitch.isOn, forKey: Constants.prefsUseImdbApp)
		UserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
	}
	
	@objc func youtubeSwitchTapped() {
		UserDefaults(suiteName: Constants.movieStartsGroup)?.set(youtubeSwitch.isOn, forKey: Constants.prefsUseYoutubeApp)
		UserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
	}
	
	@objc func notificationSwitchTapped() {
		if (notificationSwitch.isOn) {
			// notification switch was turned on: try to activate notifications
			UIApplication.shared.registerUserNotificationSettings(
				UIUserNotificationSettings(types: [UIUserNotificationType.alert, /*UIUserNotificationType.Badge,*/ UIUserNotificationType.sound], categories: nil))
			saveNotificationTime()
			
			// if registration was successfull, the AppDelegate calls "switchNotifications(true)"
		}
		else {
			// notification switch was turned off
			switchNotifications(false)
		}
	}

	func switchNotifications(_ on: Bool) {
		if (notificationSwitch != nil) {
			notificationSwitch.setOn(on, animated: false)
		}
		
		UserDefaults(suiteName: Constants.movieStartsGroup)?.set(on, forKey: Constants.prefsNotifications)
		UserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()

		if (on) {
			if (tableView != nil) {
				tableView.insertRows(at: [IndexPath(row: 1, section: sectionNotifications)], with: UITableViewRowAnimation.middle)
			}
			NotificationManager.updateFavoriteNotifications(favoriteMovies: movieTabBarController?.favoriteMovies)
		}
		else {
			let indexPathToDelete = IndexPath(row: 1, section: sectionNotifications)

			if ((tableView != nil) && (tableView.cellForRow(at: indexPathToDelete) != nil)) {
				// delete time-setting-row if it exists
				tableView.deleteRows(at: [indexPathToDelete], with: UITableViewRowAnimation.middle)
			}
			
			NotificationManager.removeAllFavoriteNotifications()
		}
	}
	
	fileprivate func saveNotificationTime() {
		let day = timePicker.selectedRow(inComponent: dayComponent) - Constants.notificationDays + 1
		let time = timePicker.selectedRow(inComponent: timeComponent) + Constants.notificationTimeMin
		
		UserDefaults(suiteName: Constants.movieStartsGroup)?.set(day, forKey: Constants.prefsNotificationDay)
		UserDefaults(suiteName: Constants.movieStartsGroup)?.set(time, forKey: Constants.prefsNotificationTime)
		UserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
	}
	
	fileprivate func setUpSwitch(_ prefKey: String, switcher: UISwitch, label: UILabel?, urlString: String?) {
		
		// set switch on or off
		let useApp: Bool? = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: prefKey) as? Bool
		
		if let useApp = useApp , useApp == true {
			switcher.isOn = true
		}
		else {
			switcher.isOn = false
		}
		
		if let label = label, let urlString = urlString {
			// set switch to enabled or not
			let url: URL? = URL(string: urlString)
		
			if let url = url {
				if UIApplication.shared.canOpenURL(url) {
					// app is installed
					switcher.isEnabled = true
					label.isEnabled = true
				}
				else {
					// app is *not* installed
					switcher.isEnabled = false
					label.isEnabled = false
				}
			}
			else {
				// this actually cannot happen. still:
				switcher.isEnabled = false
				label.isEnabled = false
			}
		}
	}
}
