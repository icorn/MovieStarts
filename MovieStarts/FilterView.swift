//
//  FilterView.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 31.10.16.
//  Copyright © 2016 Oliver Eichhorn. All rights reserved.
//

import UIKit

class FilterView: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet weak var onlyGoodMoviesSwitch: UISwitch!
    @IBOutlet weak var onlyGoodMoviesLabel: UILabel!
    @IBOutlet weak var onlyNewMoviesSwitch: UISwitch!
    @IBOutlet weak var onlyNewMoviesLabel: UILabel!

    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var tapLabel: UILabel!
    @IBOutlet weak var topView: UIView!


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        Bundle.main.loadNibNamed("FilterView", owner: self, options: nil)
        self.addSubview(view)
        view.frame = self.bounds

        onlyGoodMoviesLabel.text = NSLocalizedString("OnlyGoodMovies", comment: "")
        onlyNewMoviesLabel.text = NSLocalizedString("OnlyNewMovies", comment: "")
        genresLabel.text = NSLocalizedString("Genres", comment: "") + ":"
        tapLabel.text = NSLocalizedString("TapGenreTag", comment: "")
    }

    var realHeight: CGFloat {
        get {
            return topView.frame.size.height + tagListView.frame.minY +
                tagListView.intrinsicContentSize.height + 8.0
        }
    }
}
