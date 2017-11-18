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
    @IBOutlet weak var activateFilterSwitch: UISwitch!
    @IBOutlet weak var activateFilterLabel: UILabel!

    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var tapLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        Bundle.main.loadNibNamed("FilterView", owner: self, options: nil)
        self.addSubview(view)
        view.frame = self.bounds

        onlyGoodMoviesLabel.text = NSLocalizedString("OnlyGoodMovies", comment: "")
        onlyNewMoviesLabel.text = NSLocalizedString("OnlyNewMovies", comment: "")
        genresLabel.text = NSLocalizedString("Genres", comment: "") + ":"
        tapLabel.text = NSLocalizedString("TapGenreTag", comment: "")
        tapLabel.isHidden = true
        
        // colors
        let backColor = UIColor(white: 240.0/255.0, alpha: 1.0)
        let labelColor = UIColor.black
        
        topView.backgroundColor = backColor
        bottomView.backgroundColor = backColor
        onlyGoodMoviesLabel.textColor = labelColor
        onlyNewMoviesLabel.textColor = labelColor
        genresLabel.textColor = labelColor
        activateFilterLabel.textColor = labelColor
        tapLabel.textColor = UIColor(white: 100.0/255.0, alpha: 1.0)
        
        // config tag-list-view
        tagListView.textColor = UIColor.gray
        tagListView.selectedTextColor = UIColor.black

        tagListView.tagBackgroundColor = UIColor(white: 0.9, alpha: 1.0)
        tagListView.tagHighlightedBackgroundColor = UIColor.yellow
        tagListView.tagSelectedBackgroundColor = UIColor(white: 0.85, alpha: 1.0)

        tagListView.cornerRadius = 10.0
        tagListView.borderWidth = 0.5
        tagListView.borderColor = UIColor.darkGray
        tagListView.selectedBorderColor = UIColor.black

        tagListView.paddingX = 8.0
        tagListView.paddingY = 5.0
        tagListView.marginX = 4.0
        tagListView.marginY = 5.0
        tagListView.alignment = TagListView.Alignment.left
    }

    var realHeight: CGFloat {
        get {
            return topView.frame.size.height + tagListView.frame.minY +
                tagListView.intrinsicContentSize.height + onlyGoodMoviesSwitch.frame.size.height + 20.0
        }
    }
    
    @IBAction func activateFilterSwitchTapped(_ sender: Any) {
        let TAG_ID = 999
        
        if (activateFilterSwitch.isOn) {
            for subView in bottomView.subviews {
                if (subView.tag == TAG_ID) {
                    UIView.animate(withDuration: 0.3, animations: { 
                        subView.alpha = 0.0
                    }, completion: { (_) in
                        subView.removeFromSuperview()
                    })
                    break;
                }
            }
        }
        else {
            let invalidateView = UIView()
            invalidateView.backgroundColor = UIColor.black
            invalidateView.alpha = 0.0
            invalidateView.frame = bottomView.bounds
            invalidateView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            invalidateView.tag = TAG_ID
            bottomView.addSubview(invalidateView)
            
            UIView.animate(withDuration: 0.3, animations: {
                invalidateView.alpha = 0.5
            })
        }
    }
    
    @IBAction func onlyGoodMoviesTapped(_ sender: Any) {
    }
    
    @IBAction func onlyNewMoviesTapped(_ sender: Any) {
    }
}
