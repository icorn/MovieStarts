//
//  RotatableSafariViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 18.11.17.
//  Copyright © 2017 Oliver Eichhorn. All rights reserved.
//

import UIKit
import SafariServices


enum SafariCategory: String
{
    case RottenTomatoes    = "Rotten Tomatoes WebView"
    case TMDb              = "TMDb WebView"
    case IMDb              = "IMDb WebView"
    case Trailer           = "Trailer/YouTube WebView"
}

class RotatableSafariViewController: SFSafariViewController, Rotatable
{
    public var category: SafariCategory?
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        resetToPortrait()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if let category = category
        {
            AnalyticsClient.trackScreenName(category.rawValue)
        }
    }
}
