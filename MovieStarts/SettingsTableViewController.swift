//
//  SettingsTableViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 08.09.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit
import UserNotifications

class SettingsTableViewController: UITableViewController
{

	@IBOutlet weak var imdbLabel: UILabel!
	@IBOutlet weak var youtubeLabel: UILabel!
	@IBOutlet weak var imdbSwitch: UISwitch!
	@IBOutlet weak var youtubeSwitch: UISwitch!
	@IBOutlet weak var aboutLabel: UILabel!
	@IBOutlet weak var rateLabel: UILabel!
	@IBOutlet weak var notificationLabel: UILabel!
	@IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var notificationTimeTitleLabel: UILabel!
    @IBOutlet weak var notificationTimeSubtitleLabel: UILabel!

    let sectionUseApps			= 0
	let sectionNotifications	= 1
	let sectionAbout			= 2
	
	let itemRate  = 0
	let itemAbout = 1

    let itemTime  = 1

	var movieTabBarController: TabBarController?
    {
		get
        {
			return navigationController?.parent as? TabBarController
		}
	}

	
    override func viewDidLoad()
    {
        super.viewDidLoad()

		// fill titles and strings
		navigationItem.title = NSLocalizedString("SettingsLong", comment: "")
		imdbLabel.text = NSLocalizedString("SettingsUseImdb", comment: "")
		youtubeLabel.text = NSLocalizedString("SettingsUseYoutube", comment: "")
		aboutLabel.text = NSLocalizedString("SettingsAbout", comment: "")
		rateLabel.text = NSLocalizedString("SettingsRateTheApp", comment: "")
		notificationLabel.text = NSLocalizedString("SettingsNotifications", comment: "")
        notificationTimeTitleLabel.text = NSLocalizedString("SettingsNotificationTime", comment: "")
        
        imdbSwitch.addTarget(self, action: #selector(SettingsTableViewController.imdbSwitchTapped), for: UIControl.Event.touchUpInside)
		youtubeSwitch.addTarget(self, action: #selector(SettingsTableViewController.youtubeSwitchTapped), for: UIControl.Event.touchUpInside)
		notificationSwitch.addTarget(self, action: #selector(SettingsTableViewController.notificationSwitchTapped), for: UIControl.Event.touchUpInside)
    }
	
	override func viewDidAppear(_ animated: Bool)
    {
		super.viewDidAppear(animated)

        AnalyticsClient.trackScreenName("Settings Screen")

        updateTimeSubtitle()
		
		// set up the switches
		setUpSwitch(Constants.prefsUseImdbApp, switcher: imdbSwitch, label: imdbLabel, urlString: "imdb:")
		setUpSwitch(Constants.prefsUseYoutubeApp, switcher: youtubeSwitch, label: youtubeLabel, urlString: "youtube:")
		setUpSwitch(Constants.prefsNotifications, switcher: notificationSwitch, label: nil, urlString: nil)
	}

	
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
		switch section
        {
			case sectionUseApps:
				return 2
			case sectionNotifications:
				let notificationsOn: Bool? = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsNotifications) as? Bool

				if let notificationsOn = notificationsOn, notificationsOn == true
                {
					return 2
				}
				else
                {
					return 1
				}
			case sectionAbout:
				return 2
			default:
				return 0
		}
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
		switch section
        {
			case sectionUseApps: 		return NSLocalizedString("SettingsUseApps", comment: "")
			case sectionNotifications:	return NSLocalizedString("SettingsNotificationsHeader", comment: "")
			default: return nil
		}
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String?
    {
		switch section
        {
			case sectionUseApps: 		return NSLocalizedString("SettingsUseAppsFooter", comment: "")
			case sectionNotifications:	return NSLocalizedString("SettingsNotificationsFooter", comment: "")
			default: 					return nil
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch ((indexPath as NSIndexPath).section)
        {
            case sectionAbout:
                if ((indexPath as NSIndexPath).item == itemRate)
                {
                    guard let rateUrl = URL(string: "itms-apps://itunes.apple.com/app/id1043041023?action=write-review") else { return }
                    UIApplication.shared.open(rateUrl, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler:
                        { (Bool) in
                            tableView.deselectRow(at: indexPath, animated: false)
                        }
                    )
                }
                else if ((indexPath as NSIndexPath).item == itemAbout)
                {
                    guard let aboutController = self.storyboard?.instantiateViewController(withIdentifier: "AboutViewController") as? AboutViewController else { return }
                    navigationController?.pushViewController(aboutController, animated: true)
                }
            
            case sectionNotifications:
                if ((indexPath as NSIndexPath).item == itemTime)
                {
                    guard let notificationTimeController = self.storyboard?.instantiateViewController(withIdentifier: "NotificationTimeViewController") as? NotificationTimeViewController else { return }
                    navigationController?.pushViewController(notificationTimeController, animated: true)
                }

            default:
                ()
        }
	}
	
	
	// MARK: - Private helper functions

	@objc func imdbSwitchTapped()
    {
		UserDefaults(suiteName: Constants.movieStartsGroup)?.set(imdbSwitch.isOn, forKey: Constants.prefsUseImdbApp)
		UserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
        AnalyticsClient.setPropertyUseImdbApp(to: imdbSwitch.isOn ? "1" : "0")
	}
	
	@objc func youtubeSwitchTapped()
    {
		UserDefaults(suiteName: Constants.movieStartsGroup)?.set(youtubeSwitch.isOn, forKey: Constants.prefsUseYoutubeApp)
		UserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
        AnalyticsClient.setPropertyUseYouTubeApp(to: youtubeSwitch.isOn ? "1" : "0")
	}
	
	@objc func notificationSwitchTapped()
    {
		if (notificationSwitch.isOn)
        {
			// notification switch was turned on: try to activate notifications
            let center = UNUserNotificationCenter.current()
            let options: UNAuthorizationOptions = [.alert, .sound]

            center.requestAuthorization(options: options)
            { [unowned self] (granted, error) in
                self.userDidGrantNotifications(granted, withError: error)
            }
		}
		else
        {
			// notification switch was turned off
			switchNotifications(false)
		}
        
        NotificationManager.setUserPropertyForNotifications()
	}


    func userDidGrantNotifications(_ grant: Bool, withError error: Error?)
    {
        if (grant && (error == nil))
        {
            // user has allowed notifications
            switchNotifications(true)
        }
        else
        {
            // user has *not* allowed notifications
            switchNotifications(false)

            // warn user
            DispatchQueue.main.async {
                var messageWindow: MessageWindow?

                if let viewForMessage = self.view?.window
                {
                    messageWindow = MessageWindow(parent: viewForMessage,
                                                  darkenBackground: true,
                                                  titleStringId: "NotificationWarnTitle",
                                                  textStringId: "NotificationWarnText",
                                                  buttonStringIds: ["Close"],
                                                  handler:
                        { (buttonIndex) -> () in
                            messageWindow?.close()
                        }
                    )
                }
            }
        }
        
        saveNotificationTimeIfNeeded()
        NotificationManager.setUserPropertyForNotifications()
    }

    
    // Also called by the AppDelegate!
	func switchNotifications(_ on: Bool)
    {
		if (self.notificationSwitch != nil)
        {
            DispatchQueue.main.async {
                self.notificationSwitch.setOn(on, animated: false)
            }
		}
		
		UserDefaults(suiteName: Constants.movieStartsGroup)?.set(on, forKey: Constants.prefsNotifications)
		UserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()

		if (on)
        {
			if (self.tableView != nil)
            {
                DispatchQueue.main.async {
                    self.tableView.insertRows(at: [IndexPath(row: 1, section: self.sectionNotifications)], with: UITableView.RowAnimation.middle)
                }
			}
			NotificationManager.updateFavoriteNotifications(favoriteMovies: self.movieTabBarController?.favoriteMovies)
		}
		else
        {
            DispatchQueue.main.async {
                let indexPathToDelete = IndexPath(row: 1, section: self.sectionNotifications)

                if ((self.tableView != nil) && (self.tableView.cellForRow(at: indexPathToDelete) != nil))
                {
                    // delete time-setting-row if it exists
                    self.tableView.deleteRows(at: [indexPathToDelete], with: UITableView.RowAnimation.middle)
                }
			
                NotificationManager.removeAllFavoriteNotifications()
            }
		}
	}
	
	fileprivate func saveNotificationTimeIfNeeded()
    {
        if let _ = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsNotificationDay) as? Int,
           let _ = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsNotificationTime) as? Int
        {
            // Both day and time are already present in UserDefaults. No need to write again
        }
        else
        {
            // No notification time saved: Save default.
            UserDefaults(suiteName: Constants.movieStartsGroup)?.set(0, forKey: Constants.prefsNotificationDay)
            UserDefaults(suiteName: Constants.movieStartsGroup)?.set(13, forKey: Constants.prefsNotificationTime)
            UserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
        }
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
    
    private func updateTimeSubtitle()
    {
        // code duplication from NotificationTimeViewController!
        var notificationTimeArray = [
            [
                NSLocalizedString("5daysBefore", comment: ""), NSLocalizedString("4daysBefore", comment: ""), NSLocalizedString("3daysBefore", comment: ""),
                NSLocalizedString("2daysBefore", comment: ""), NSLocalizedString("1daysBefore", comment: ""), NSLocalizedString("0daysBefore", comment: "")
            ],
            []
        ]

        for hour in Constants.notificationTimeMin...Constants.notificationTimeMax
        {
            notificationTimeArray[1].append(DateFormatter.localizedString(from: Date().setHour(hour), dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.short))
        }

        var dayString = notificationTimeArray[0][5]
        var timeString = notificationTimeArray[1][5]

        // read user settings
        if let day = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsNotificationDay) as? Int,
           let time = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsNotificationTime) as? Int
        {
            dayString = notificationTimeArray[0][day + Constants.notificationDays - 1]
            timeString = notificationTimeArray[1][time - Constants.notificationTimeMin]
        }

        // update the subtitle
        notificationTimeSubtitleLabel.text = "\(dayString) \(NSLocalizedString("SettingsNotificationTimeAt", comment: "")) \(timeString) \(NSLocalizedString("SettingsNotificationTimeOclock", comment: ""))"
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
