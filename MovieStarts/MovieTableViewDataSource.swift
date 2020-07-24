//
//  MovieListDatasourceController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 23.10.16.
//  Copyright © 2016 Oliver Eichhorn. All rights reserved.
//

import Foundation
import UIKit

protocol FavoriteIconDelegate {
    func addFavoriteIconToCell(_ cell: MovieTableViewCell?)
    func removeFavoriteIconFromCell(_ cell: MovieTableViewCell?)
}


class MovieTableViewDataSource : NSObject, UITableViewDataSource {

    var tabBarController: TabBarController
    var favoriteIconManager: FavoriteIconDelegate
    var currentTab: MovieTab?

    init(tabBarController: TabBarController, favoriteIconManager: FavoriteIconDelegate) {
        self.tabBarController = tabBarController
        self.favoriteIconManager = favoriteIconManager
    }

    var moviesInSections: [[MovieRecord]] {
        get {
            if (currentTab == MovieTab.upcoming) {
                return tabBarController.upcomingMovies
            }
            else if (currentTab == MovieTab.favorites) {
                return tabBarController.favoriteMovies
            }

            return []
        }

        set {
            if (currentTab == MovieTab.upcoming) {
                tabBarController.upcomingMovies = newValue
            }
            else if (currentTab == MovieTab.favorites) {
                tabBarController.favoriteMovies = newValue
            }
        }
    }


    var nowMovies: [MovieRecord] {
        get {
            return tabBarController.nowMovies
        }
        set {
            tabBarController.nowMovies = newValue
        }
    }

    var sectionTitles: [String] {
        get {
            if (currentTab == MovieTab.upcoming) {
                return tabBarController.upcomingSectionTitles
            }
            else if (currentTab == MovieTab.favorites) {
                return tabBarController.favoriteSectionTitles
            }

            return []
        }
        
        set {
            if (currentTab == MovieTab.upcoming) {
                tabBarController.upcomingSectionTitles = newValue
            }
            else if (currentTab == MovieTab.favorites) {
                tabBarController.favoriteSectionTitles = newValue
            }
        }
    }


    var genreDict: [Int: String] {
        return tabBarController.genreDict
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell", for: indexPath) as? MovieTableViewCell

        var movie: MovieRecord?

        if moviesInSections.count > 0 {
            movie = moviesInSections[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        }
        else {
            movie = nowMovies[(indexPath as NSIndexPath).row]
        }

        if let movie = movie, let cell = cell {
            cell.posterImage.image = movie.thumbnailImage.0
            cell.titleText.text = movie.title[movie.currentCountry.languageArrayIndex]
            cell.tag = Constants.tagTableCell

            // show labels with subtitles

            let subtitleLabels = [cell.subtitleText1, cell.subtitleText2, cell.subtitleText3]

            for (index, subtitle) in movie.getSubtitleArray(genreDict: genreDict).enumerated() {
                subtitleLabels[index]?.isHidden = false
                subtitleLabels[index]?.text = subtitle
            }

            // hide unused labels

            for index in movie.getSubtitleArray(genreDict: genreDict).count ..< subtitleLabels.count {
                subtitleLabels[index]?.isHidden = true
            }

            // vertically "center" the labels
            let moveY = (subtitleLabels.count - movie.getSubtitleArray(genreDict: genreDict).count) * 19
            cell.titleTextTopSpaceConstraint.constant = CGFloat(moveY / 2) - 4

            // add favorite-icon
            self.favoriteIconManager.removeFavoriteIconFromCell(cell)

            if Favorites.IDs.contains(movie.id) {
                self.favoriteIconManager.addFavoriteIconToCell(cell)
            }

            return cell
        }
        else {
            // this should never happen
            NSLog("*** Error: movie or cell is nil!")
            return UITableViewCell()
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if (currentTab == MovieTab.nowPlaying) {
            return 1
        }
        else {
            return sectionTitles.count
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (moviesInSections.count > section) {
            return moviesInSections[section].count
        }
        else {
            return nowMovies.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (sectionTitles.count > section) {
            return sectionTitles[section]
        }
        else {
            return nil
        }
    }
}

