//
//  MovieRecordTests.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 24.07.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit
import XCTest
import MovieStarts


class MovieRecordTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testToDictionary() {
		let tmdbTestId = 12345
		let imdbTestId = "imdb"
		let titleTest  = "testtitle"
		
		let record = MovieRecord(dict: [Constants.DB_ID_TMDB_ID : tmdbTestId, Constants.DB_ID_IMDB_ID : imdbTestId, Constants.DB_ID_TITLE : titleTest])
		let dict = record.toDictionary()
		
		XCTAssertNotNil(record.title,  "Title is nil")
		XCTAssertNotNil(record.tmdbId, "tmdb-id is nil")
		XCTAssertNotNil(record.imdbId, "imdb-id is nil")
		
		XCTAssert(record.title == titleTest, "Record has wrong title")
		XCTAssert(record.imdbId == imdbTestId, "Record has wrong imdb-id")
		XCTAssert(record.tmdbId == tmdbTestId, "Record has wrong tmdb-id")
	}

	func testGenreString() {
		let genres = ["genre1", "genre2", "genre3"]
		let record = MovieRecord(dict: [Constants.DB_ID_TMDB_ID : 12345, Constants.DB_ID_IMDB_ID : "67890", Constants.DB_ID_GENRES : genres])

		XCTAssertNotNil(record.genreString, "genrestring is nil")
		XCTAssert(record.genreString == "genre1, genre2, genre3", "genrestring is wrong")
	}

	func testSubtitleArray1() {
		let record = MovieRecord(dict: [Constants.DB_ID_TITLE : "title", Constants.DB_ID_ORIG_TITLE : "orig"])
		let subtitles = record.subtitleArray
		
		XCTAssert(subtitles.count == 1, "Record should have 1 subtitle")
	}
	
	func testSubtitleArray2() {
		let record = MovieRecord(dict: [Constants.DB_ID_TITLE : "title", Constants.DB_ID_ORIG_TITLE : "orig", Constants.DB_ID_RUNTIME : 90])
		let subtitles = record.subtitleArray
		
		XCTAssert(subtitles.count == 2, "Record should have 2 subtitles")
	}

	func testSubtitleArray3() {
		let record = MovieRecord(dict: [Constants.DB_ID_TITLE : "title", Constants.DB_ID_ORIG_TITLE : "orig", Constants.DB_ID_RUNTIME : 90, Constants.DB_ID_GENRES : ["Comedy"]])
		let subtitles = record.subtitleArray
		
		XCTAssert(subtitles.count == 3, "Record should have 3 subtitles")
	}
	
}
