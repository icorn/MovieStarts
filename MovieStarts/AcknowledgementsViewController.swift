//
//  AcknowledgementsViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 10.02.18.
//  Copyright © 2018 Oliver Eichhorn. All rights reserved.
//

import UIKit


enum AcknowledgementsCellType: Int
{
    case AppzGear     = 0
    case FTLinear     = 1
    
    static let allValues = [AppzGear, FTLinear]
    
    var title: String
    {
        switch self
        {
        case .AppzGear:     return "Appzgear.com"
        case .FTLinear:     return "FTLinearActivityIndicator"
        }
    }

    var content: String
    {
        switch self
        {
        case .AppzGear:     return "http://appzgear.com"
        case .FTLinear:     return "Copyright (c) 2018 Ortwin Gentz, FutureTap GmbH\n\nThis work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA."
        }
    }
}


class AcknowledgementsViewController: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Acknowledgements", comment: "")
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return AcknowledgementsCellType.allValues.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "acknowledgmentCell", for: indexPath)
        let ackCellType = AcknowledgementsCellType(rawValue: indexPath.row)
        cell.textLabel?.text = ackCellType?.title
        
        return cell
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let ackCellType = AcknowledgementsCellType(rawValue: indexPath.row)
        {
            switch (ackCellType)
            {
                case .AppzGear:
                    let url = URL(string: ackCellType.content)
            
                    if let url = url, UIApplication.shared.canOpenURL(url)
                    {
                        UIApplication.shared.open(url, options: [:], completionHandler: { (Bool) in })
                    }

                case .FTLinear:
                    if let bigLabelController = storyboard?.instantiateViewController(withIdentifier: "BigLabelViewController") as? BigLabelViewController
                    {
                        bigLabelController.navigationItem.title = ackCellType.title
                        bigLabelController.contentText = ackCellType.content
                        navigationController?.pushViewController(bigLabelController, animated: true)
                    }
            }
        }
    }
}
