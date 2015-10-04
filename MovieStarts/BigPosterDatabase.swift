//
//  BigPosterDatabase.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 20.09.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation
import CloudKit


class BigPosterDatabase : DatabaseParent {
	
	var movie: MovieRecord?
	var finishCallback: ((error: NSError?) -> ())?
	
	
	/**
		Initiate the download of a big poster.
	
		- parameter movie:			The movie which the poster belongs to
		- parameter finishCallback:	The callback which is called after the finished download (or error)
	*/
	func downloadBigPoster(movie: MovieRecord, finishCallback: (error: NSError?) -> ()) {
		self.movie = movie
		self.finishCallback = finishCallback
		
		if let tmdbId = movie.tmdbId {
			let predicate = NSPredicate(format: "tmdbId == %i", tmdbId)
			let query = CKQuery(recordType: self.recordType, predicate: predicate)
			let queryOperation = CKQueryOperation(query: query)
			queryOperation.recordFetchedBlock = recordFetchedBigPosterCallback
			queryOperation.queryCompletionBlock = queryCompleteBigPosterCallback
			queryOperation.desiredKeys = [Constants.DB_ID_BIG_POSTER_ASSET, Constants.DB_ID_TMDB_ID]
			self.cloudKitDatabase.addOperation(queryOperation)
		}
	}
	
	
	private func recordFetchedBigPosterCallback(record: CKRecord!) {
		let tmdbIdToFind: Int = record.objectForKey(Constants.DB_ID_TMDB_ID) as! Int
		
		if let tmdbId = movie?.tmdbId where tmdbId == tmdbIdToFind {
			movie?.storePoster(record.objectForKey(Constants.DB_ID_BIG_POSTER_ASSET) as? CKAsset, thumbnail: false)
		}
	}

	
	private func queryCompleteBigPosterCallback(cursor: CKQueryCursor?, error: NSError?) {
		finishCallback?(error: error)
	}
	
}
