//
//  NotificationTimeViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 10.02.18.
//  Copyright © 2018 Oliver Eichhorn. All rights reserved.
//

import UIKit

class NotificationTimeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    @IBOutlet weak var timePicker: UIPickerView!
    
    let dayComponent    = 0
    let timeComponent   = 1

    var notificationTimeArray = [
        [
            NSLocalizedString("5daysBefore", comment: ""), NSLocalizedString("4daysBefore", comment: ""), NSLocalizedString("3daysBefore", comment: ""),
            NSLocalizedString("2daysBefore", comment: ""), NSLocalizedString("1daysBefore", comment: ""), NSLocalizedString("0daysBefore", comment: "")
        ],
        []
    ]

    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("SettingsNotificationTime", comment: "")

        for hour in Constants.notificationTimeMin...Constants.notificationTimeMax
        {
            notificationTimeArray[timeComponent].append(DateFormatter.localizedString(from: Date().setHour(hour), dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.short))
        }

        timePicker.delegate = self
        timePicker.dataSource = self

        if let day = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsNotificationDay) as? Int,
           let time = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsNotificationTime) as? Int
        {
            timePicker.selectRow(day + Constants.notificationDays - 1, inComponent: dayComponent, animated: false)
            timePicker.selectRow(time - Constants.notificationTimeMin, inComponent: timeComponent, animated: false)
        }
        else
        {
            timePicker.selectRow(notificationTimeArray[dayComponent].count - 1, inComponent: dayComponent, animated: false)
            timePicker.selectRow(5, inComponent: timeComponent, animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParentViewController
        {
            // save the time
            saveNotificationTime()
            NotificationManager.updateFavoriteNotifications(favoriteMovies: (navigationController?.parent as? TabBarController)?.favoriteMovies)
        }
    }
    
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return notificationTimeArray[component].count
    }
    
    // MARK: - UIPickerViewDelegate

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        var label = UILabel(frame: CGRect(x: 0, y: 0, width: timePicker.rowSize(forComponent: component).width, height: timePicker.rowSize(forComponent: component).height))
        
        if let view = view as? UILabel
        {
            label = view
        }
        
        label.font = UIFont.systemFont(ofSize: 22)
        label.text = notificationTimeArray[component][row]
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat
    {
        switch (component)
        {
            case dayComponent:
                return pickerView.frame.width * 0.66
            case timeComponent:
                return pickerView.frame.width * 0.33
            default:
                return 0.0
        }
    }
    
    
    // MARK: - Private stuff
    
    fileprivate func saveNotificationTime()
    {
        let day = timePicker.selectedRow(inComponent: dayComponent) - Constants.notificationDays + 1
        let time = timePicker.selectedRow(inComponent: timeComponent) + Constants.notificationTimeMin
        
        UserDefaults(suiteName: Constants.movieStartsGroup)?.set(day, forKey: Constants.prefsNotificationDay)
        UserDefaults(suiteName: Constants.movieStartsGroup)?.set(time, forKey: Constants.prefsNotificationTime)
        UserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
    }

}
