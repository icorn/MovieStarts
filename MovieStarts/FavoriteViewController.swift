//
//  FavoriteViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 23.10.16.
//  Copyright © 2016 Oliver Eichhorn. All rights reserved.
//

import UIKit

class FavoriteViewController: MovieListViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        (self.tableView.dataSource as? MovieTableViewDataSource)?.currentTab = MovieTab.favorites
        navigationItem.title = NSLocalizedString("FavoritesLong", comment: "")
        checkForEmptyList()
    }

    override var tableViewOutlet: UITableView! {
        get {
            return self.tableView
        }
        set {
        }
    }

    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        AnalyticsClient.trackScreenName("Watchlist Screen")
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        checkForEmptyList()
    }

    fileprivate func checkForEmptyList() {
        if (movieTableViewDataSource?.moviesInSections.count == 0) {
            // there are no favorites: show message in background view and hide separators

            let noEntriesBackView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.height))
            let headlineHeight: CGFloat = 40
            let textInset: CGFloat = 20

            let headlineLabel = UILabel(frame: CGRect(x: 0,
                                                      y: view.frame.height / 4,
                                                      width: view.frame.width,
                                                      height: headlineHeight))
            headlineLabel.textColor = UIColor.gray
            headlineLabel.font = UIFont.boldSystemFont(ofSize: 30)
            headlineLabel.text = NSLocalizedString("NoFavorites", comment: "")
            headlineLabel.textAlignment = NSTextAlignment.center
            noEntriesBackView.addSubview(headlineLabel)

            let textLabel = UILabel(frame: CGRect(x: textInset,
                                                  y: view.frame.height / 4 + headlineHeight + 20,
                                                  width: view.frame.width - 2 * textInset,
                                                  height: 0))
            textLabel.textColor = UIColor.gray
            textLabel.font = UIFont.boldSystemFont(ofSize: 18)
            textLabel.textAlignment = NSTextAlignment.center
            textLabel.numberOfLines = 0

            // set text with line-spacing
            let stringValue = NSLocalizedString("HowToAddFavorites", comment: "")
            let attrString = NSMutableAttributedString(string: stringValue)
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 8
            attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSRange(location: 0, length: stringValue.count))
            textLabel.attributedText = attrString
            
            textLabel.sizeToFit()
            noEntriesBackView.addSubview(textLabel)
            
            tableView.separatorStyle =  UITableViewCell.SeparatorStyle.none
            tableView.backgroundView = noEntriesBackView
        }
        else {
            // there are favorites: no background view and normal separators

            tableView.backgroundView = nil
            tableView.separatorStyle =  UITableViewCell.SeparatorStyle.singleLine
        }
    }


    func addFavorite(_ newFavorite: MovieRecord) {
        tableView.beginUpdates()
        addFavoritePrivate(newFavorite)
        tableView.endUpdates()

        if let movieTableViewDataSource = self.movieTableViewDataSource {
            NotificationManager.updateFavoriteNotifications(favoriteMovies: movieTableViewDataSource.tabBarController.favoriteMovies)
        }
    }

    fileprivate func addFavoritePrivate(_ newFavorite: MovieRecord) {
        // search apropriate section for the new favorite
        var sectionToSearchFor: String!

        if newFavorite.isNowPlaying() {
            sectionToSearchFor = NSLocalizedString("NowPlayingLong", comment: "")
        }
        else {
            sectionToSearchFor = newFavorite.releaseDateStringLong
        }

        var foundSectionIndex: Int?

        if let movieTableViewDataSource = self.movieTableViewDataSource {
            for sectionIndex in 0 ..< movieTableViewDataSource.sectionTitles.count {
                if (movieTableViewDataSource.sectionTitles[sectionIndex] == sectionToSearchFor) {
                    foundSectionIndex = sectionIndex
                    break
                }
            }
        }

        if let foundSectionIndex = foundSectionIndex {
            // the section for the new favorite already exists
            addMovieToExistingSection(foundSectionIndex: foundSectionIndex, newMovie: newFavorite)
        }
        else {
            // the section doesn't exist yet
            addMovieToNewSection(sectionName: sectionToSearchFor, newMovie: newFavorite)
        }
    }


    func removeFavorite(_ removedFavoriteId: String) {
        tableView.beginUpdates()
        removeFavoritePrivate(removedFavoriteId)
        tableView.endUpdates()

        if let movieTableViewDataSource = self.movieTableViewDataSource {
            NotificationManager.updateFavoriteNotifications(favoriteMovies: movieTableViewDataSource.tabBarController.favoriteMovies)
        }
    }


    fileprivate func removeFavoritePrivate(_ removedFavoriteId: String) {
        guard let movieTableViewDataSource = self.movieTableViewDataSource else { return }

        var rowId: Int?
        var sectionId: Int?

        // search favorite
        for sectionIndex: Int in 0 ..< movieTableViewDataSource.moviesInSections.count {
            for movieIndex: Int in 0 ..< movieTableViewDataSource.moviesInSections[sectionIndex].count {
                if (movieTableViewDataSource.moviesInSections[sectionIndex][movieIndex].id == removedFavoriteId) {
                    rowId = movieIndex
                    sectionId = sectionIndex
                    break
                }
            }
        }

        if let rowId = rowId, let sectionId = sectionId {
            // remove cell
            let indexPath: IndexPath = IndexPath(row: rowId, section: sectionId)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)

            // remove movie from datasource
            movieTableViewDataSource.moviesInSections[sectionId].remove(at: rowId)

            // if the section is now empty: remove it also
            if movieTableViewDataSource.moviesInSections[sectionId].isEmpty {
                // remove section from datasource
                movieTableViewDataSource.moviesInSections.remove(at: sectionId)
                movieTableViewDataSource.sectionTitles.remove(at: sectionId)

                // remove section from table
                let indexSet: IndexSet = IndexSet(integer: sectionId)
                tableView.deleteSections(indexSet, with: UITableView.RowAnimation.automatic)
            }
        }
    }


    func updateFavorite(_ updatedMovie: MovieRecord) {
        guard let movieTableViewDataSource = self.movieTableViewDataSource else { return }

        tableView.beginUpdates()

        // find the index of the existing movie in the table

        var indexPathForUpdateMovie: IndexPath?

        for (sectionIndex, section) in movieTableViewDataSource.moviesInSections.enumerated() {
            for (movieIndex, movie) in section.enumerated() {
                if (movie.id == updatedMovie.id) {
                    indexPathForUpdateMovie = IndexPath(row: movieIndex, section: sectionIndex)
                    break
                }
            }
        }

        // check for changes

        if let indexPathForUpdateMovie = indexPathForUpdateMovie {
            if ((movieTableViewDataSource.moviesInSections[(indexPathForUpdateMovie as NSIndexPath).section][(indexPathForUpdateMovie as NSIndexPath).row].title != updatedMovie.title) ||
                (movieTableViewDataSource.moviesInSections[(indexPathForUpdateMovie as NSIndexPath).section][(indexPathForUpdateMovie as NSIndexPath).row].releaseDate != updatedMovie.releaseDate))
            {
                // the title or the date has changed. we have to move the table cell to a new position.
                removeFavoritePrivate(updatedMovie.id)
                addFavoritePrivate(updatedMovie)

                // update notifications for favorites
                NotificationManager.updateFavoriteNotifications(favoriteMovies: movieTableViewDataSource.tabBarController.favoriteMovies)
            }
            else if (movieTableViewDataSource.moviesInSections[(indexPathForUpdateMovie as NSIndexPath).section][(indexPathForUpdateMovie as NSIndexPath).row].hasVisibleChanges(updatedMovie: updatedMovie)) {
                // some data has changed which is shown in the table cell -> change the cell with an animation
                movieTableViewDataSource.moviesInSections[(indexPathForUpdateMovie as NSIndexPath).section][(indexPathForUpdateMovie as NSIndexPath).row] = updatedMovie
                tableView.reloadRows(at: [indexPathForUpdateMovie], with: UITableView.RowAnimation.automatic)
            }
            else {
                // some data has changed which is now visible in the table cell -> change the cell, no animation
                movieTableViewDataSource.moviesInSections[(indexPathForUpdateMovie as NSIndexPath).section][(indexPathForUpdateMovie as NSIndexPath).row] = updatedMovie
                tableView.reloadRows(at: [indexPathForUpdateMovie], with: UITableView.RowAnimation.none)
            }
        }
        
        tableView.endUpdates()
        WatchSessionManager.sharedManager.updateFavoritesOnWatch()
    }
    
    
    func showFavoriteMovie(_ movieID: String) {
        // we use the array from the tab-controller, because the local one might not be initialized yet
        if let movieTableViewDataSource = self.movieTableViewDataSource {
            for (sectionIndex, section) in movieTableViewDataSource.moviesInSections.enumerated() {
                for (movieIndex, movie) in section.enumerated() {
                    if (movie.id == movieID) {
                        // we found the movie to show: select the row and show it
                        let indexPath = IndexPath(row: movieIndex, section: sectionIndex)
                        self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
                        self.movieTableViewDelegate?.tableView(self.tableView, didSelectRowAt: indexPath)
                        tabBarController?.tabBar.isHidden = false
                        return
                    }
                }
            }
        }
    }

}
