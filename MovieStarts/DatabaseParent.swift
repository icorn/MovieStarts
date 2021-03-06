//
//  DatabaseParent.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 20.09.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation
import CloudKit


class DatabaseParent {
	
	var cloudKitContainer: CKContainer
	var cloudKitDatabase: CKDatabase
	var recordType: String

	
	init(recordType: String) {
		self.recordType = recordType
		
		cloudKitContainer = CKContainer(identifier: Constants.cloudkitContainerId)
		cloudKitDatabase = cloudKitContainer.publicCloudDatabase
	}

    func checkCloudKit(handler: @escaping (CKAccountStatus, Error?) -> ()) {
		cloudKitContainer.accountStatus(completionHandler: handler)
	}
	
}
