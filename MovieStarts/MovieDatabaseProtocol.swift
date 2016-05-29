//
//  DatabaseParent.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 20.09.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation
import CloudKit
import UIKit


protocol MovieDatabaseProtocol {
	
	init(recordType: String, viewForError: UIView?)
	
	func executeQueryOperation(queryOperation: CKQueryOperation, onOperationQueue operationQueue: NSOperationQueue)
	func queryOperationFinished(error: NSError?)
	func recordFetchedCallback(record: CKRecord)
}

