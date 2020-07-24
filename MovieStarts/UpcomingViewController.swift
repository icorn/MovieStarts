//
//  UpcomingViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 23.10.16.
//  Copyright © 2016 Oliver Eichhorn. All rights reserved.
//

import UIKit

class UpcomingViewController: MovieListViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        (self.tableView.dataSource as? MovieTableViewDataSource)?.currentTab = MovieTab.upcoming
        navigationItem.title = NSLocalizedString("UpcomingLong", comment: "")
    }

    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        AnalyticsClient.trackScreenName("Upcoming Screen")
    }

    override var tableViewOutlet: UITableView! {
        get {
            return self.tableView
        }
        set {
        }
    }

    func addMovie(_ newMovie: MovieRecord) {
        tableView.beginUpdates()
        addMoviePrivate(newMovie)
        tableView.endUpdates()
    }


    fileprivate func addMoviePrivate(_ newMovie: MovieRecord) {
        // search apropriate section for the new movie
        let sectionToSearchFor = newMovie.releaseDateStringLong
        var foundSectionIndex: Int?

        if let movieListDataSource = self.movieTableViewDataSource {
            for sectionIndex in 0 ..< movieListDataSource.sectionTitles.count {
                if (movieListDataSource.sectionTitles[sectionIndex] == sectionToSearchFor) {
                    foundSectionIndex = sectionIndex
                    break
                }
            }
        }
        
        if let foundSectionIndex = foundSectionIndex {
            // the section for the new movie already exists
            addMovieToExistingSection(foundSectionIndex: foundSectionIndex, newMovie: newMovie)
        }
        else {
            // the section doesn't exist yet
            addMovieToNewSection(sectionName: sectionToSearchFor, newMovie: newMovie)
        }
    }


    func removeMovie(_ movieToRemove: MovieRecord) {
        guard let movieListDataSource = self.movieTableViewDataSource else { return }

        tableView.beginUpdates()

        var indexPathForExistingMovie: IndexPath?

        for (sectionIndex, section) in movieListDataSource.moviesInSections.enumerated() {
            for (movieIndex, movie) in section.enumerated() {
                if (movie.id == movieToRemove.id) {
                    indexPathForExistingMovie = IndexPath(row: movieIndex, section: sectionIndex)
                    break
                }
            }
        }

        if let indexPathForExistingMovie = indexPathForExistingMovie {
            movieListDataSource.moviesInSections[(indexPathForExistingMovie as NSIndexPath).section].remove(at: (indexPathForExistingMovie as NSIndexPath).row)

            // if the section is now empty: remove it also
            if movieListDataSource.moviesInSections[(indexPathForExistingMovie as NSIndexPath).section].isEmpty {
                // remove section from datasource
                movieListDataSource.moviesInSections.remove(at: (indexPathForExistingMovie as NSIndexPath).section)
                movieListDataSource.sectionTitles.remove(at: (indexPathForExistingMovie as NSIndexPath).section)

                // remove section from table
                let indexSet: IndexSet = IndexSet(integer: (indexPathForExistingMovie as NSIndexPath).section)
                tableView.deleteSections(indexSet, with: UITableView.RowAnimation.automatic)
            }

            tableView.deleteRows(at: [indexPathForExistingMovie], with: UITableView.RowAnimation.automatic)
        }

        tableView.endUpdates()
    }


    func updateMovie(_ updatedMovie: MovieRecord) {
        guard let movieListDataSource = self.movieTableViewDataSource else { return }

        tableView.beginUpdates()

        // find the index of the existing movie in the table

        var indexPathForExistingMovie: IndexPath?

        for (sectionIndex, section) in movieListDataSource.moviesInSections.enumerated() {
            for (movieIndex, movie) in section.enumerated() {
                if (movie.id == updatedMovie.id) {
                    indexPathForExistingMovie = IndexPath(row: movieIndex, section: sectionIndex)
                    break
                }
            }
        }

        // check for changes

        if let indexPathForExistingMovie = indexPathForExistingMovie {
            if ((movieListDataSource.moviesInSections[(indexPathForExistingMovie as NSIndexPath).section][(indexPathForExistingMovie as NSIndexPath).row].title != updatedMovie.title) ||
                (movieListDataSource.moviesInSections[(indexPathForExistingMovie as NSIndexPath).section][(indexPathForExistingMovie as NSIndexPath).row].releaseDate != updatedMovie.releaseDate))
            {
                // the title or the date has changed. we have to move the table cell to a new position.

                // remove movie from old position
                movieListDataSource.moviesInSections[(indexPathForExistingMovie as NSIndexPath).section].remove(at: (indexPathForExistingMovie as NSIndexPath).row)
                tableView.deleteRows(at: [indexPathForExistingMovie], with: UITableView.RowAnimation.automatic)

                // add it at new position
                addMoviePrivate(updatedMovie)
            }
            else if (movieListDataSource.moviesInSections[(indexPathForExistingMovie as NSIndexPath).section][(indexPathForExistingMovie as NSIndexPath).row].hasVisibleChanges(updatedMovie: updatedMovie)) {
                // some data has changed which is shown in the table cell -> change the cell with an animation
                movieListDataSource.moviesInSections[(indexPathForExistingMovie as NSIndexPath).section][(indexPathForExistingMovie as NSIndexPath).row] = updatedMovie
                tableView.reloadRows(at: [indexPathForExistingMovie], with: UITableView.RowAnimation.automatic)
            }
            else {
                // some data has changed which is now visible in the table cell -> change the cell, no animation
                movieListDataSource.moviesInSections[(indexPathForExistingMovie as NSIndexPath).section][(indexPathForExistingMovie as NSIndexPath).row] = updatedMovie
                tableView.reloadRows(at: [indexPathForExistingMovie], with: UITableView.RowAnimation.none)
            }
        }
        
        tableView.endUpdates()
    }

}
