//
//  RotatableSafariViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 18.11.17.
//  Copyright © 2017 Oliver Eichhorn. All rights reserved.
//

import UIKit
import SafariServices

class RotatableSafariViewController: SFSafariViewController, Rotatable
{
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)

//        if isMovingFromParentViewController
//        {
            resetToPortrait()
//        }
    }
}
