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
	

	override func viewDidLoad() {
        super.viewDidLoad()
		
		if let saveItems = self.movieTabBar.items {
			if (saveItems.count == 3) {
				(saveItems[0] as! UITabBarItem).title = NSLocalizedString("NowPlaying", comment: "")
				(saveItems[1] as! UITabBarItem).title = NSLocalizedString("Upcoming", comment: "")
				(saveItems[2] as! UITabBarItem).title = NSLocalizedString("Settings", comment: "")
			}
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
