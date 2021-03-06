//
//  MovieListViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 23.10.16.
//  Copyright © 2016 Oliver Eichhorn. All rights reserved.
//

import UIKit
import UserNotifications


class MovieListViewController: UIViewController, FavoriteIconDelegate
{
    var movieTableViewDataSource: MovieTableViewDataSource?
    var movieTableViewDelegate: MovieTableViewDelegate?

    var tableViewOutlet: UITableView!
    var refreshControl: UIRefreshControl?

    override func viewDidLoad()
    {
        super.viewDidLoad()

        tableViewOutlet.register(UINib(nibName: "MovieTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieTableViewCell")

        // set up data source
        self.movieTableViewDataSource =
            MovieTableViewDataSource(tabBarController: (navigationController?.parent as? TabBarController)!,
                                     favoriteIconManager: self)
        self.tableViewOutlet.dataSource = self.movieTableViewDataSource

        // set up delegate
        self.movieTableViewDelegate = MovieTableViewDelegate(movieTableViewDataSource: self.movieTableViewDataSource!,
                                                             favoriteIconManager: self,
                                                             tableView: self.tableViewOutlet,
                                                             vcWithTable: self)
        self.tableViewOutlet.delegate = movieTableViewDelegate
        self.refreshControl = UIRefreshControl()
        
        if let refreshControl = self.refreshControl
        {
            refreshControl.addTarget(self, action: #selector(MovieListViewController.refreshControlActivated(refreshControl:)), for: UIControl.Event.valueChanged)
            self.tableViewOutlet.refreshControl = refreshControl
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(movieUpdateFinished(notification:)),
                                               name: NSNotification.Name(MovieDatabaseUpdater.MovieUpdateFinishNotification),
                                               object: nil)
    }

    @objc func refreshControlActivated(refreshControl: UIRefreshControl)
    {
        if (MovieDatabaseUpdater.sharedInstance.inProgress)
        {
            refreshControl.attributedTitle = NSMutableAttributedString(string: NSLocalizedString("RefreshInProgress", comment: ""))
            refreshControl.endRefreshing()
        }
        else
        {
            refreshControl.attributedTitle = NSMutableAttributedString(string: "")
            self.updateDatabase(onlyIfUpdateIsTooOld: false)
        }
    }
    
    // sets the refresh-control to "endRefreshing"
    @objc func movieUpdateFinished(notification: NSNotification)
    {
        DispatchQueue.main.async
        {
            if let refreshControl = self.refreshControl, refreshControl.isRefreshing == true
            {
                self.refreshControl?.endRefreshing()
            }
        }
    }

    var settingsTableViewController: SettingsTableViewController? {
        var stvc: SettingsTableViewController?

        guard let movieListDataSource = self.movieTableViewDataSource else { return nil }

        if let viewControllersOfRoot = movieListDataSource.tabBarController.viewControllers {
            for viewControllerOfRoot in viewControllersOfRoot where viewControllerOfRoot is UINavigationController {
                if let viewControllersOfNav = (viewControllerOfRoot as? UINavigationController)?.viewControllers {
                    for viewControllerOfNav in viewControllersOfNav where viewControllerOfNav is SettingsTableViewController {
                        stvc = viewControllerOfNav as? SettingsTableViewController
                        break
                    }
                }
            }
        }
        return stvc
    }

    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)

        // reload to update favorite-icon if we come back from detail view.
        tableViewOutlet.reloadData()

        // check what's "now playing" and what not. this changes after midnight.
        checkNowPlayingStatus()

        if (migrateDatabaseIfNeeded() == false)
        {
            // no database migration needed: if last update is long enough ago: check CloudKit for update
            updateDatabase(onlyIfUpdateIsTooOld: true)
        }

        // check if we had notifications turned on in the app, but turned off in the system
        let notificationsTurnedOnInSettings: Bool? = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsNotifications) as? Bool

        if let notificationsTurnedOnInSettings = notificationsTurnedOnInSettings, notificationsTurnedOnInSettings == true
        {
            let center = UNUserNotificationCenter.current()
            
            center.getNotificationSettings
            { [weak self] (settings) in
                if settings.authorizationStatus != .authorized
                {
                    // tell the user, the notifications are no longer working - and it's all his fault ;-)
                    DispatchQueue.main.async
                    {
                        guard let errorView = self?.movieTableViewDataSource?.tabBarController.view else { return }
                        var errorWindow: MessageWindow?
                        errorWindow = MessageWindow(parent: errorView,
                                                    darkenBackground: true,
                                                    titleStringId: "NotificationWarnTitle",
                                                    textStringId: "NotificationWarnText2",
                                                    buttonStringIds: ["Close"],
                                                    handler:
                                                    { (buttonIndex) -> () in
                                                        errorWindow?.close()
                                                    })
                    }
                    
                    // also, turn notifications off
                    if let settings = self?.settingsTableViewController
                    {
                        settings.switchNotifications(false)
                    }
                    else
                    {
                        NSLog("Settings dialog not available. This should never happen.")
                        UserDefaults(suiteName: Constants.movieStartsGroup)?.set(false, forKey: Constants.prefsNotifications)
                        UserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
                        NotificationManager.removeAllFavoriteNotifications()
                    }
                }
            }
        }
    }

    fileprivate func updateDatabase(onlyIfUpdateIsTooOld: Bool)
    {
        MovieDatabaseUpdater.sharedInstance.viewForError = self.view
        
        if let allMovies = MovieDatabaseUpdater.sharedInstance.readDatabaseFromFile()
        {
            movieTableViewDataSource?.tabBarController.updateMovies(allMovies, onlyIfUpdateIsTooOld: onlyIfUpdateIsTooOld)
        }
    }
    
    
    // MARK: - Private helper functions

    fileprivate func checkNowPlayingStatus() {
        var moviesToDeleteFromUpcomingList: [MovieRecord] = []

        // check upcoming-list and move all now-playing movies to now-playing-list
        if let movieListDataSource = self.movieTableViewDataSource {
            for upcomingSection in movieListDataSource.tabBarController.upcomingMovies {
                for upcomingMovie in upcomingSection {
                    if (upcomingMovie.isNowPlaying()) {
                        // this upcoming movie is no longer upcoming - it's now playing.
                        // add movie to "now playing"-list and collect the ID for later deleting
                        movieListDataSource.tabBarController.nowPlayingController?.addMovie(upcomingMovie)
                        moviesToDeleteFromUpcomingList.append(upcomingMovie)
                    }
                }
            }
        }

        for movieToDelete in moviesToDeleteFromUpcomingList {
            self.movieTableViewDataSource?.tabBarController.upcomingController?.removeMovie(movieToDelete)
        }

        // check favorite-list and move all now-playing movies to the correct section
        if let movieListDataSource = self.movieTableViewDataSource {
            for (sectionIndex, favoriteSection) in (movieListDataSource.tabBarController.favoriteMovies).enumerated() {
                for favoriteMovie in favoriteSection {
                    if (favoriteMovie.isNowPlaying()) {
                        // this favorite movie is now playing. We check if it's already in the now-playing-section inside the favorites-list.
                        if (movieListDataSource.tabBarController.favoriteSectionTitles[sectionIndex] != NSLocalizedString("NowPlayingLong", comment: "")) {
                            // movie is now-playing, but not in the now-playing-section inside the favorites list: move it!
                            movieListDataSource.tabBarController.favoriteController?.removeFavorite(favoriteMovie.id)
                            movieListDataSource.tabBarController.favoriteController?.addFavorite(favoriteMovie)
                        }
                    }
                }
            }
        }
    }


    /**
     Checks if we have a new version of the app, which needs to migrate the database (or show some information to the user).
     - returns: TRUE if a database migration will be performed, FALSE otherwise
     */
    fileprivate func migrateDatabaseIfNeeded() -> Bool {
        var retval = false

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else
        {
            return retval;
        }

        if (movieTableViewDataSource?.tabBarController.migrationHasFailedInThisSession == true)
        {
            return retval;
        }

        let migrateFromVersion = UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsMigrateFromVersion) as? Int

        if let migrateFromVersion = migrateFromVersion , migrateFromVersion < Constants.version1_3
        {
            // we have to migrate the database from an older version to version 1.3: Get new database fields for all records

            appDelegate.versionOfPreviousLaunch = Constants.version1_3
            retval = true
            var updateWindow: MessageWindow?
            var updateCounter = 0

            if let movieListDataSource = self.movieTableViewDataSource {
                DispatchQueue.main.async {
                    updateWindow = MessageWindow(parent: movieListDataSource.tabBarController.view,
                                                 darkenBackground: true,
                                                 titleStringId: "UpdateDatabaseTitle",
                                                 textStringId: "UpdateDatabaseText",
                                                 buttonStringIds: [],
                                                 handler: { (buttonIndex) -> () in } )

                    updateWindow?.showProgressIndicator(NSLocalizedString("RatingUpdateStart", comment: ""))

                    let prefsCountryString = (UserDefaults(suiteName: Constants.movieStartsGroup)?.object(forKey: Constants.prefsCountry) as? String) ?? MovieCountry.USA.rawValue
                    guard let country = MovieCountry(rawValue: prefsCountryString) else {
                        NSLog("ERROR getting country from preferences")
                        return
                    }

                    MovieDatabaseMigrator.sharedInstance.viewForError = self.view

                    MovieDatabaseMigrator.sharedInstance.getMigrationMovies(
                        country: country,
                        updateMovieHandler: { (movie: MovieRecord) in

                            // update the just received movie
                            updateCounter += 1
                            var updated = false

                            for (nowIndex, nowMovie) in movieListDataSource.nowMovies.enumerated() {
                                if (nowMovie.tmdbId == movie.tmdbId) {
                                    movieListDataSource.nowMovies[nowIndex].migrate(updateRecord: movie,
                                                                                    updateKeys: MovieDatabaseMigrator.sharedInstance.queryKeys)
                                    updated = true
                                    break
                                }
                            }

                            if (updated == false) {
                                for (upcomingSectionIndex, upcomingMovieSection) in
                                    movieListDataSource.tabBarController.upcomingMovies.enumerated()
                                {
                                    for (upcomingMovieIndex, upcomingMovie) in upcomingMovieSection.enumerated() {
                                        if (upcomingMovie.tmdbId == movie.tmdbId) {
                                            movieListDataSource.tabBarController.upcomingMovies[upcomingSectionIndex][upcomingMovieIndex].migrate(updateRecord: movie, updateKeys: MovieDatabaseMigrator.sharedInstance.queryKeys)
                                            break
                                        }
                                    }
                                }
                            }

                            for (favoriteSectionIndex, favoriteMovieSection) in
                                movieListDataSource.tabBarController.favoriteMovies.enumerated()
                            {
                                for (favoriteMovieIndex, favoriteMovie) in favoriteMovieSection.enumerated() {
                                    if (favoriteMovie.tmdbId == movie.tmdbId) {
                                        movieListDataSource.tabBarController.favoriteMovies[favoriteSectionIndex][favoriteMovieIndex].migrate(updateRecord: movie, updateKeys: MovieDatabaseMigrator.sharedInstance.queryKeys)
                                        break
                                    }
                                }
                            }

                            updateWindow?.updateProgressIndicator("\(updateCounter) " +
                                NSLocalizedString("RatingUpdateProgress", comment: ""))
                        },

                        completionHandler: { [weak self] (movies: [MovieRecord]?) in
                            DispatchQueue.main.async
                            {
                                updateWindow?.close()
                            }

                            // Don't forget to remove the migrate-flag from the prefs
                            UserDefaults(suiteName: Constants.movieStartsGroup)?.removeObject(forKey: Constants.prefsMigrateFromVersion)
                            UserDefaults(suiteName: Constants.movieStartsGroup)?.synchronize()
                            
                            // After migration: Do the update
                            self?.updateDatabase(onlyIfUpdateIsTooOld: true)
                        },

                        errorHandler: { [weak self] (errorMessage: String) in
                            DispatchQueue.main.async
                            {
                                // error in migration
                                updateWindow?.close()
                                movieListDataSource.tabBarController.migrationHasFailedInThisSession = true

                                // tell user about the error
                                var infoWindow: MessageWindow?

                                DispatchQueue.main.async {
                                    infoWindow = MessageWindow(parent: movieListDataSource.tabBarController.view,
                                                               darkenBackground: true,
                                                               titleStringId: "UpdateFailedHeadline",
                                                               textStringId: "UpdateFailedText",
                                                               buttonStringIds: ["Close"],
                                                               handler: { (buttonIndex) -> () in
                                                                   infoWindow?.close()
                                                               }
                                    )
                                }
                                
                                // After migration: Do the update
                                self?.updateDatabase(onlyIfUpdateIsTooOld: true)
                            }

                            NSLog(errorMessage)
                        }
                    )
                }
            }
        }

        return retval
    }


    // MARK: - Helper functions for the children classes (TabViewControllers)


    func addMovieToExistingSection(foundSectionIndex: Int, newMovie: MovieRecord) {
        guard let movieListDataSource = self.movieTableViewDataSource else { return }

        // add new movie to the section, then sort it
        movieListDataSource.moviesInSections[foundSectionIndex].append(newMovie)
        movieListDataSource.moviesInSections[foundSectionIndex].sort {
            let otherTitle = $1.sortTitle[$1.currentCountry.languageArrayIndex]

            if (otherTitle.count > 0) {
                return $0.sortTitle[$0.currentCountry.languageArrayIndex].localizedCaseInsensitiveCompare(otherTitle) == ComparisonResult.orderedAscending
            }
            return true
        }

        // get position of new movie after sorting so we can insert it
        for movieIndex in 0 ..< movieListDataSource.moviesInSections[foundSectionIndex].count {
            if (movieListDataSource.moviesInSections[foundSectionIndex][movieIndex].id == newMovie.id) {
                tableViewOutlet.insertRows(at: [IndexPath(row: movieIndex,
                                                          section: foundSectionIndex)], with: UITableView.RowAnimation.automatic)
                break
            }
        }
    }

    func addMovieToNewSection(sectionName: String, newMovie: MovieRecord) {

        if newMovie.isNowPlaying() {
            // special case: insert the "now playing" section (which is always first) with the movie
            movieTableViewDataSource?.sectionTitles.insert(sectionName, at: 0)
            movieTableViewDataSource?.moviesInSections.insert([newMovie], at: 0)
            tableViewOutlet.insertSections(IndexSet(integer: 0), with: UITableView.RowAnimation.automatic)
            tableViewOutlet.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableView.RowAnimation.automatic)
        }
        else {
            // normal case: insert a section for the release date with the movie
            // but first check out, at which position the new section should be inserted
            
            var newSectionIndex: Int?

            if let movieListDataSource = self.movieTableViewDataSource {
                for sectionIndex in 0 ..< movieListDataSource.moviesInSections.count {
                    // from every section, get the first movie an compare releasedates
                    if (movieListDataSource.moviesInSections[sectionIndex].count > 0) {
                        let existingDate = movieListDataSource.moviesInSections[sectionIndex][0].releaseDate[movieListDataSource.moviesInSections[sectionIndex][0].currentCountry.countryArrayIndex]
                        let newFavoriteDate = newMovie.releaseDate[newMovie.currentCountry.countryArrayIndex]
                        
                        if (existingDate.compare(newFavoriteDate as Date) == ComparisonResult.orderedDescending) {
                            // insert the new section here
                            newSectionIndex = sectionIndex
                            break
                        }
                    }
                }

                if let newSectionIndex = newSectionIndex {
                    // insert new section
                    movieListDataSource.sectionTitles.insert(sectionName, at: newSectionIndex)
                    movieListDataSource.moviesInSections.insert([newMovie], at: newSectionIndex)
                    tableViewOutlet.insertSections(IndexSet(integer: newSectionIndex), with: UITableView.RowAnimation.automatic)
                    tableViewOutlet.insertRows(at: [IndexPath(row: 0, section: newSectionIndex)], with: UITableView.RowAnimation.automatic)
                }
                else {
                    // append new section at the end
                    movieListDataSource.sectionTitles.append(sectionName)
                    movieListDataSource.moviesInSections.append([newMovie])
                    tableViewOutlet.insertSections(IndexSet(integer: movieListDataSource.sectionTitles.count-1), with: UITableView.RowAnimation.automatic)
                    tableViewOutlet.insertRows(at: [IndexPath(row: 0, section: movieListDataSource.sectionTitles.count-1)], with: UITableView.RowAnimation.automatic)
                }
            }
        }
    }
    
    func updateThumbnail(tmdbId: Int) -> Bool {
        guard let movieListDataSource = self.movieTableViewDataSource else { return false }

        var updated = false
        
        for (sectionIndex, section) in movieListDataSource.moviesInSections.enumerated() {
            for (movieIndex, movie) in section.enumerated() {
                if (movie.tmdbId == tmdbId) {
                    tableViewOutlet.beginUpdates()
                    tableViewOutlet.reloadRows(at: [IndexPath(row: movieIndex, section: sectionIndex)], with: UITableView.RowAnimation.none)
                    tableViewOutlet.endUpdates()
                    updated = true
                    break
                }
            }
        }
        
        return updated
    }


    // MARK: - FavoriteIconDelegate

    func addFavoriteIconToCell(_ cell: MovieTableViewCell?) {
        if let cell = cell {
            cell.favoriteCorner.isHidden = false
        }
    }

    func removeFavoriteIconFromCell(_ cell: MovieTableViewCell?) {
        cell?.favoriteCorner.isHidden = true
    }
}
