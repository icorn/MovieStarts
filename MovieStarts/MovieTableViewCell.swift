//
//  MovieTableViewCell.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 01.07.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

	@IBOutlet weak var posterImage: UIImageView!
	@IBOutlet weak var titleText: UILabel!
	@IBOutlet weak var subtitleText1: UILabel!
	@IBOutlet weak var subtitleText2: UILabel!
	@IBOutlet weak var subtitleText3: UILabel!
	@IBOutlet weak var titleTextTopSpaceConstraint: NSLayoutConstraint!
	@IBOutlet weak var favoriteCorner: UIImageView!
	@IBOutlet weak var favoriteCornerHorizontalSpace: NSLayoutConstraint!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
