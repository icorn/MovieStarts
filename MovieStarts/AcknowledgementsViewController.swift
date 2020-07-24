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
    case Minicons     = 1
    
    static let allValues = [AppzGear, Minicons]
    
    var title: String
    {
        switch self
        {
        case .AppzGear:     return "Appzgear.com"
        case .Minicons:     return "Minicons Free Vector Icons Pack"
        }
    }

    var content: String
    {
        switch self
        {
        case .AppzGear:     return "http://appzgear.com"
        case .Minicons:     return "Minicons Free Vector Icons Pack by Webalys is licensed under a Creative Commons Attribution 3.0 Unported License: http://creativecommons.org/licenses/by/3.0/deed.en_US \n\nThis Pack is published under a Creative Commons Attribution license and Free for both personal and commercial use. You can copy, adapt, remix, distribute or transmit it.\n\nUnder this condition: provide a mention of this \"Minicons Free Vector Icons Pack\" and a link back to this page: http://www.webalys.com/minicons"
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
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        AnalyticsClient.trackScreenName("Acknowledgements Screen")
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
                        UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: { (Bool) in })
                    }

                case .Minicons:
                    if let bigLabelController = storyboard?.instantiateViewController(withIdentifier: "BigLabelViewController") as? BigLabelViewController
                    {
                        bigLabelController.navigationItem.title = ackCellType.title
                        bigLabelController.createAttributedStringForText(ackCellType.content, withLinks: ["http://creativecommons.org/licenses/by-sa/4.0/",
                                                                                                          "http://creativecommons.org/licenses/by/3.0/deed.en_US",
                                                                                                          "http://www.webalys.com/minicons"])
                        navigationController?.pushViewController(bigLabelController, animated: true)
                    }
            }
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
