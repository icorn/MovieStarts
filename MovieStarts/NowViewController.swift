//
//  NowViewController.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 23.10.16.
//  Copyright © 2016 Oliver Eichhorn. All rights reserved.
//

import UIKit

class NowViewController: MovieListViewController {

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        (self.tableView.dataSource as? MovieTableViewDataSource)?.currentTab = MovieTab.nowPlaying
        navigationItem.title = NSLocalizedString("NowPlayingLong", comment: "")
    }

    override var tableViewOutlet: UITableView! {
        get {
            return self.tableView
        }
        set {
        }
    }

    func addMovie(_ newMovie: MovieRecord) {
        guard let movieListDataSource = self.movieTableViewDataSource else { return }
        tableView.beginUpdates()

        var indexForInsert: Int?

        for (index, movie) in movieListDataSource.nowMovies.enumerated() {
            let titleFromArray = movie.sortTitle[movie.currentCountry.languageArrayIndex], newMovieTitle = newMovie.sortTitle[movie.currentCountry.languageArrayIndex]

            if newMovieTitle.localizedCaseInsensitiveCompare(titleFromArray) == ComparisonResult.orderedAscending {
                // we found the right index for the new movie
                indexForInsert = index
                break
            }
        }

        if let indexForInsert = indexForInsert {
            // insert new movie
            movieListDataSource.nowMovies.insert(newMovie, at: indexForInsert)
            tableView.insertRows(at: [IndexPath(row: indexForInsert, section: 0)], with: UITableViewRowAnimation.automatic)
        }
        else {
            movieListDataSource.nowMovies.append(newMovie)
            tableView.insertRows(at: [IndexPath(row: movieListDataSource.nowMovies.count-1, section: 0)], with: UITableViewRowAnimation.automatic)
        }

        tableView.endUpdates()
    }


    func removeMovie(_ movieToRemove: MovieRecord) {
        guard let movieListDataSource = self.movieTableViewDataSource else { return }
        tableView.beginUpdates()

        // find the index of the existing movie in the table

        var indexForExistingMovie: Int?

        for (index, movie) in movieListDataSource.nowMovies.enumerated() {
            if (movie.id == movieToRemove.id) {
                indexForExistingMovie = index
                break
            }
        }

        if let indexForExistingMovie = indexForExistingMovie {
            movieListDataSource.nowMovies.remove(at: indexForExistingMovie)
            tableView.deleteRows(at: [IndexPath(row: indexForExistingMovie, section: 0)], with: UITableViewRowAnimation.automatic)
        }

        tableView.endUpdates()
    }


    func updateMovie(_ updatedMovie: MovieRecord) {
        guard let movieListDataSource = self.movieTableViewDataSource else { return }
        tableView.beginUpdates()

        // find the index of the existing movie in the table

        var indexForExistingMovie: Int?

        for (index, movie) in movieListDataSource.nowMovies.enumerated() {
            if (movie.id == updatedMovie.id) {
                indexForExistingMovie = index
                break
            }
        }

        // check for changes

        if let indexForExistingMovie = indexForExistingMovie {
            if (movieListDataSource.nowMovies[indexForExistingMovie].title != updatedMovie.title) {
                // the title has changed. we have to move and update the table cell to a new position.

                // remove movie from old position
                movieListDataSource.nowMovies.remove(at: indexForExistingMovie)

                // find the new position of the movie

                var indexForUpdatedMovie: Int?

                for (index, movie) in movieListDataSource.nowMovies.enumerated() {
                    let movieTitle = movie.sortTitle[movie.currentCountry.languageArrayIndex]

                    if updatedMovie.sortTitle[updatedMovie.currentCountry.languageArrayIndex].localizedCaseInsensitiveCompare(movieTitle) == ComparisonResult.orderedAscending {
                        // we found the right index for the new movie
                        indexForUpdatedMovie = index
                        break
                    }
                }

                if let indexForUpdatedMovie = indexForUpdatedMovie {
                    // move movie to new position. this is two separate actions, hence the endUpdate and beginUpdate.
                    movieListDataSource.nowMovies.insert(updatedMovie, at: indexForUpdatedMovie)
                    tableView.moveRow(at: IndexPath(row: indexForExistingMovie, section: 0), to: IndexPath(row: indexForUpdatedMovie, section: 0))
                    tableView.endUpdates()

                    tableView.beginUpdates()
                    tableView.reloadRows(at: [IndexPath(row: indexForUpdatedMovie, section: 0)], with: UITableViewRowAnimation.none)
                }
                else {

                    // move movie to the end. this is two separate actions, hence the endUpdate and beginUpdate.
                    movieListDataSource.nowMovies.append(updatedMovie)
                    tableView.moveRow(at: IndexPath(row: indexForExistingMovie, section: 0), to: IndexPath(row: movieListDataSource.nowMovies.count-1, section: 0))
                    tableView.endUpdates()

                    tableView.beginUpdates()
                    tableView.reloadRows(at: [IndexPath(row: movieListDataSource.nowMovies.count-1, section: 0)], with: UITableViewRowAnimation.automatic)
                }
            }
            else if (movieListDataSource.nowMovies[indexForExistingMovie].hasVisibleChanges(updatedMovie: updatedMovie)) {
                // some data has changed which is shown in the table cell -> change the cell with an animation
                movieListDataSource.nowMovies[indexForExistingMovie] = updatedMovie
                tableView.reloadRows(at: [IndexPath(row: indexForExistingMovie, section: 0)], with: UITableViewRowAnimation.automatic)
            }
            else {
                // some data has changed which is now visible in the table cell -> change the cell, no animation
                movieListDataSource.nowMovies[indexForExistingMovie] = updatedMovie
                tableView.reloadRows(at: [IndexPath(row: indexForExistingMovie, section: 0)], with: UITableViewRowAnimation.none)
            }
        }
        
        tableView.endUpdates()
    }
    
    
    override func updateThumbnail(tmdbId: Int) -> Bool {
        guard let movieListDataSource = self.movieTableViewDataSource else { return false }
        var updated = false
        
        for (index, movie) in movieListDataSource.nowMovies.enumerated() {
            if (movie.tmdbId == tmdbId) {
                tableView.beginUpdates()
                tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.none)
                tableView.endUpdates()
                updated = true
                break
            }
        }
        
        return updated
    }
    

}
