//
//  Utils.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 20.09.15.
//  Copyright (c) 2015 Oliver Eichhorn. All rights reserved.
//

import Foundation
import UIKit
import CloudKit


class NetworkChecker {
	
	/**
		Checks the availibility of CloudKit.
	
		- parameter viewForError:	The parent view for error windows
		- parameter database:		The database object to use
		- parameter okCallback:		The callback which is called on success
		- parameter errorCallback:	The optional callback which is called on failure (even before the user has clicked "close" in the error-window)
	*/
	class func checkCloudKit(viewForError: UIView, database: DatabaseParent, okCallback: @escaping () -> (), errorCallback: (() -> ())?) {

		database.checkCloudKit(handler: { (status: CKAccountStatus, error: Error?) -> () in
			
			var errorWindow: MessageWindow?
			
			switch status {
			case .available:
				okCallback()
				
			case .noAccount:
				NSLog("CloudKit error: no account")
				errorCallback?()
				DispatchQueue.main.async {
					errorWindow = MessageWindow(parent: viewForError, darkenBackground: true, titleStringId: "iCloudError", textStringId: "iCloudNoAccount", buttonStringIds: ["Close"],
						handler: { (buttonIndex) -> () in
							errorWindow?.close()
						}
					)
				}
				
			case .restricted:
				NSLog("CloudKit error: Restricted")
				errorCallback?()
				DispatchQueue.main.async {
					errorWindow = MessageWindow(parent: viewForError, darkenBackground: true, titleStringId: "iCloudError", textStringId: "iCloudRestricted", buttonStringIds: ["Close"],
						handler: { (buttonIndex) -> () in
							errorWindow?.close()
						}
					)
				}
				
			case .couldNotDetermine:
				NSLog("CloudKit error: CouldNotDetermine")
				
				if let error = error as NSError? {
					NSLog("CloudKit error description: \(error.localizedDescription)")
				}
				
				errorCallback?()
				DispatchQueue.main.async {
					errorWindow = MessageWindow(parent: viewForError, darkenBackground: true, titleStringId: "iCloudError", textStringId: "iCloudCouldNotDetermine", buttonStringIds: ["Close"],
						handler: { (buttonIndex) -> () in
							errorWindow?.close()
						}
					)
				}
            default:
                NSLog("CloudKit error: Unknown error")
                errorCallback?()
                
                DispatchQueue.main.async {
                    errorWindow = MessageWindow(parent: viewForError, darkenBackground: true, titleStringId: "iCloudError", textStringId: "iCloudCouldNotDetermine", buttonStringIds: ["Close"],
                                                handler: { (buttonIndex) -> () in
                                                    errorWindow?.close()
                    }
                    )
                }
            }
		})
		
	}
	
}
