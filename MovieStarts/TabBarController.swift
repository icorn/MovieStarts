//
//  TabBarController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 24.02.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

	var movies: [MovieRecord]?
	
	@IBOutlet weak var movieTabBar: UITabBar!
	

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		if let saveItems = self.movieTabBar.items {
			if (saveItems.count == 3) {
				
				// set tab bar titles
				
				(saveItems[0] as! UITabBarItem).title = NSLocalizedString("NowPlaying", comment: "")
				(saveItems[1] as! UITabBarItem).title = NSLocalizedString("Upcoming", comment: "")
				(saveItems[2] as! UITabBarItem).title = NSLocalizedString("Settings", comment: "")
				
				// set tab bar images

				(saveItems[0] as! UITabBarItem).image = UIImage(named: "Video.png")
				(saveItems[1] as! UITabBarItem).image = UIImage(named: "Calendar.png")
				(saveItems[2] as! UITabBarItem).image = UIImage(named: "Settings.png")
			}
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	override func supportedInterfaceOrientations() -> Int {
		
		if let svc = selectedViewController {
			return svc.supportedInterfaceOrientations()
		}
		else {
			return Int(UIInterfaceOrientationMask.Portrait.rawValue)
		}
	}
	
/*
	override func shouldAutorotate() -> Bool {
		if let svc = selectedViewController {
			return svc.shouldAutorotate()
		}
		else {
			return false
		}
	}
*/
}
