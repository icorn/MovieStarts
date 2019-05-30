//
//  MovieListDelegate.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 23.10.16.
//  Copyright © 2016 Oliver Eichhorn. All rights reserved.
//

import Foundation
import UIKit


class MovieTableViewDelegate : NSObject, UITableViewDelegate {

    var movieTableViewDataSource    : MovieTableViewDataSource
    var favoriteIconManager         : FavoriteIconDelegate
    var tableView                   : UITableView
    var vcWithTable                 : UIViewController

    init(movieTableViewDataSource   : MovieTableViewDataSource,
         favoriteIconManager        : FavoriteIconDelegate,
         tableView                  : UITableView,
         vcWithTable                : UIViewController)
    {
        self.movieTableViewDataSource   = movieTableViewDataSource
        self.favoriteIconManager        = favoriteIconManager
        self.tableView                  = tableView
        self.vcWithTable                = vcWithTable
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let saveStoryboard = self.vcWithTable.storyboard {
            let movieController: MovieViewController? =
                saveStoryboard.instantiateViewController(withIdentifier: "MovieViewController") as? MovieViewController

            if let movieController = movieController {
                if movieTableViewDataSource.moviesInSections.count > 0 {
                    movieController.movie =
                        movieTableViewDataSource.moviesInSections[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                }
                else {
                    movieController.movie = movieTableViewDataSource.nowMovies[(indexPath as NSIndexPath).row]
                }

                vcWithTable.navigationController?.pushViewController(movieController, animated: true)
            }

        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 116
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var movieID: String!

        // find ID of edited movie

        if movieTableViewDataSource.moviesInSections.count > 0 {
            movieID = movieTableViewDataSource.moviesInSections[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row].id
        }
        else {
            movieID = movieTableViewDataSource.nowMovies[(indexPath as NSIndexPath).row].id
        }

        // set title and color of button

        var title: String!
        var backColor: UIColor!

        if (Favorites.IDs.contains(movieID)) {
            title = NSLocalizedString("RemoveFromFavoritesShort", comment: "")
            backColor = UIColor.red
        }
        else {
            title = NSLocalizedString("AddToFavoritesShort", comment: "")
            backColor = UIColor.blue
        }

        // define button-action

        let favAction: UITableViewRowAction = UITableViewRowAction(style: UITableViewRowAction.Style.default,
                                                                   title: title,
                                                                   handler:
            {
                [unowned self] (action: UITableViewRowAction, path: IndexPath) -> () in

                // find out movie id

                var movie: MovieRecord!
                if self.movieTableViewDataSource.moviesInSections.count > 0 {
                    movie = self.movieTableViewDataSource.moviesInSections[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                }
                else {
                    movie = self.movieTableViewDataSource.nowMovies[(indexPath as NSIndexPath).row]
                }

                // add or remove movie as favorite

                let currentCell: UITableViewCell? = self.tableView.cellForRow(at: indexPath)

                if (Favorites.IDs.contains(movie.id))
                {
                    // movie is favorite: remove it as favorite and remove favorite-icon
                    Favorites.removeMovie(movie, tabBarController: self.movieTableViewDataSource.tabBarController)
                    self.favoriteIconManager.removeFavoriteIconFromCell(currentCell as? MovieTableViewCell)
                }
                else
                {
                    // movie was no favorite: add as favorite and add favorite-icon
                    Favorites.addMovie(movie, tabBarController: self.movieTableViewDataSource.tabBarController)
                    self.favoriteIconManager.addFavoriteIconToCell(currentCell as? MovieTableViewCell)
                }
                
                self.tableView.setEditing(false, animated: true)
                
                if self.isKind(of: FavoriteViewController.self) {
                    // immediately refresh favorite-tableview
                    self.vcWithTable.viewDidLoad()
                }
            }
        )
        
        favAction.backgroundColor = backColor
        
        return [favAction]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Bug in iOS 8: This function is not called, but without it, swiping is not enabled
    }
/*
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
*/
}
