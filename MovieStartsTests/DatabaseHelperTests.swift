//
//  DatabaseHelperTests.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 24.07.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import UIKit
import XCTest
//import MovieStarts


class DatabaseHelperTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
/*
	func testRecordsToDictFull() {
		let tmdbTestId0 = 12345
		let imdbTestId1 = "imdb1"
		let titleTest1  = "test1"
		
		let record0 = MovieRecord(dict: [Constants.DB_ID_TMDB_ID : tmdbTestId0, Constants.DB_ID_IMDB_ID : "imdb0", Constants.DB_ID_TITLE : "test0"])
		let record1 = MovieRecord(dict: [Constants.DB_ID_TMDB_ID : 67890, Constants.DB_ID_IMDB_ID : imdbTestId1, Constants.DB_ID_TITLE : titleTest1])

		let dictArray:[NSDictionary] = DatabaseHelper.movieRecordArrayToDictArray([record0, record1])
		
		XCTAssert(dictArray.count == 2, "Dictionary-array-size is wrong.")
		
		XCTAssertNotNil(dictArray[0].objectForKey(Constants.DB_ID_TMDB_ID),	"First tmdb-id is nil")
		XCTAssertNotNil(dictArray[1].objectForKey(Constants.DB_ID_TMDB_ID),	"Second tmdb-id is nil")
		XCTAssertNotNil(dictArray[0].objectForKey(Constants.DB_ID_IMDB_ID),	"First imdb-id is nil")
		XCTAssertNotNil(dictArray[1].objectForKey(Constants.DB_ID_IMDB_ID),	"Second imdb-id is nil")
		XCTAssertNotNil(dictArray[0].objectForKey(Constants.DB_ID_TITLE), 	"First title is nil")
		XCTAssertNotNil(dictArray[1].objectForKey(Constants.DB_ID_TITLE), 	"Second title is nil")

		XCTAssert(dictArray[0].objectForKey(Constants.DB_ID_TMDB_ID) as? Int == tmdbTestId0, "First tmdb-id is wrong")
		XCTAssert(dictArray[1].objectForKey(Constants.DB_ID_IMDB_ID) as? String == imdbTestId1, "Second imdb-id is wrong")
		XCTAssert(dictArray[1].objectForKey(Constants.DB_ID_TITLE) as? String == titleTest1, "Second title is wrong")
	}
	
	func testRecordsToDictEmpty() {
		let dictArray = DatabaseHelper.movieRecordArrayToDictArray([])
		XCTAssert(dictArray.count == 0, "Dictionary-array is not empty.")
	}
	
	func testDictToRecordsFull() {
		let tmdbTestId0 = 12345
		let imdbTestId1 = "imdb1"
		let titleTest1  = "test1"
		
		let dict0 = [Constants.DB_ID_TMDB_ID : tmdbTestId0, Constants.DB_ID_IMDB_ID : "imdb0", Constants.DB_ID_TITLE : "test0"]
		let dict1 = [Constants.DB_ID_TMDB_ID : 67890, Constants.DB_ID_IMDB_ID : imdbTestId1, Constants.DB_ID_TITLE : titleTest1]

		let recordArray:[MovieRecord] = DatabaseHelper.dictArrayToMovieRecordArray([dict0, dict1])
		
		XCTAssert(recordArray.count == 2, "Dictionary-array-size is wrong.")
		
		XCTAssertNotNil(recordArray[0].tmdbId, "First tmdb-id is nil")
		XCTAssertNotNil(recordArray[1].tmdbId, "Second tmdb-id is nil")
		XCTAssertNotNil(recordArray[0].imdbId, "First imdb-id is nil")
		XCTAssertNotNil(recordArray[1].imdbId, "Second imdb-id is nil")
		XCTAssertNotNil(recordArray[0].title,  "First title is nil")
		XCTAssertNotNil(recordArray[1].title,  "Second title is nil")

		XCTAssert(recordArray[0].tmdbId == tmdbTestId0, "First tmdb-id is wrong")
		XCTAssert(recordArray[1].imdbId == imdbTestId1, "Second imdb-id is wrong")
		XCTAssert(recordArray[1].title  == titleTest1, "Second title is wrong")
	}

	func testDictToRecordsEmpty() {
		let recordArray:[MovieRecord] = DatabaseHelper.dictArrayToMovieRecordArray([])
		XCTAssert(recordArray.count == 0, "Array is not empty.")
	}
	
	func testJoinMovieRecordArray() {
		let tmdbTestId0 = 12345
		let imdbTestId1 = "imdb1"
		let titleTest2  = "test2"
		let titleTest3  = "test3"
		
		let record0 = MovieRecord(dict: [Constants.DB_ID_TMDB_ID : tmdbTestId0,	Constants.DB_ID_IMDB_ID : "imdb0", 		Constants.DB_ID_TITLE : "test0"])
		let record1 = MovieRecord(dict: [Constants.DB_ID_TMDB_ID : 67890, 		Constants.DB_ID_IMDB_ID : imdbTestId1, 	Constants.DB_ID_TITLE : "test1"])
		let record2 = MovieRecord(dict: [Constants.DB_ID_TMDB_ID : 34567, 		Constants.DB_ID_IMDB_ID : "imdb2", 		Constants.DB_ID_TITLE : titleTest2])
		
		// record3 has duplicate tmdb-id of record0 -> joined array should have 3 elements (record3 overwrites record0)
		let record3 = MovieRecord(dict: [Constants.DB_ID_TMDB_ID : tmdbTestId0, Constants.DB_ID_IMDB_ID : "imdb3", 		Constants.DB_ID_TITLE : titleTest3])

		var recordArray:[MovieRecord] = [record0, record1]
		
		DatabaseHelper.joinMovieRecordArrays(&recordArray, updatedMovies: [record2, record3])
		
		XCTAssert(recordArray.count == 3, "Record array has wrong size")
		
		XCTAssert(recordArray[0].tmdbId == tmdbTestId0, "Record 0 has wrong tmdb-id")
		XCTAssert(recordArray[0].title == titleTest3, "Record 0 has wrong title")
		XCTAssert(recordArray[1].imdbId == imdbTestId1, "Record 1 has wrong imdb-id")
		XCTAssert(recordArray[2].title == titleTest2, "Record 2 has wrong title")
	}
	
	func testFindArrayIndexOfMovie() {
		let record0 = MovieRecord(dict: [Constants.DB_ID_TMDB_ID : 12345, Constants.DB_ID_IMDB_ID : "imdb0", Constants.DB_ID_TITLE : "test0"])
		let record1 = MovieRecord(dict: [Constants.DB_ID_TMDB_ID : 67890, Constants.DB_ID_IMDB_ID : "imdb1", Constants.DB_ID_TITLE : "test1"])
		let record2 = MovieRecord(dict: [Constants.DB_ID_TMDB_ID : 34567, Constants.DB_ID_IMDB_ID : "imdb2", Constants.DB_ID_TITLE : "test2"])

		let index = DatabaseHelper.findArrayIndexOfMovie(record2, array: [record0, record1, record2])
		
		XCTAssert(index == 2, "Found index is wrong.")
	}
	
	func testFindArrayIndexOfMovieNil() {
		let record0 = MovieRecord(dict: [Constants.DB_ID_TMDB_ID : 12345, Constants.DB_ID_IMDB_ID : "imdb0", Constants.DB_ID_TITLE : "test0"])
		let record1 = MovieRecord(dict: [Constants.DB_ID_TMDB_ID : 67890, Constants.DB_ID_IMDB_ID : "imdb1", Constants.DB_ID_TITLE : "test1"])
		let record2 = MovieRecord(dict: [Constants.DB_ID_TMDB_ID : 34567, Constants.DB_ID_IMDB_ID : "imdb2", Constants.DB_ID_TITLE : "test2"])
		
		let index = DatabaseHelper.findArrayIndexOfMovie(record2, array: [record0, record1])
		
		XCTAssert(index == nil, "Found should be nil, but isn't.")
	}
*/
	
}

