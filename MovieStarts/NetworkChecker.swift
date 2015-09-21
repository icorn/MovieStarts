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
		Checks the reachability of the network.
	
		:param: viewForError	The parent view for error windows
	
		:returns: TRUE if the network is available, FALSE otherwise
	*/
	class func checkReachability(viewForError: UIView) -> Bool {
		
		if IJReachability.isConnectedToNetwork() == false {
			NSLog("No network")
			var errorWindow: MessageWindow?
			
			dispatch_async(dispatch_get_main_queue()) {
				errorWindow = MessageWindow(parent: viewForError, darkenBackground: true, titleStringId: "NoNetworkTitle", textStringId: "NoNetworkText", buttonStringId: "Close", handler: {
					errorWindow?.close()
				})
			}
			
			return false
		}
		
		return true
	}

	
	/**
		Checks the availibility of CloudKit.
	
		:param: viewForError	The parent view for error windows
		:param: database		The database object to use
		:param: okCallback		The callback which is called on success
		:param: errorCallback	The optional callback which is called on failure (even before the user has clicked "close" in the error-window)
	*/
	class func checkCloudKit(viewForError: UIView, database: DatabaseParent, okCallback: () -> (), errorCallback: (() -> ())?) {

		database.checkCloudKit({ (status: CKAccountStatus, error: NSError!) -> () in
			
			var errorWindow: MessageWindow?
			
			switch status {
			case .Available:
				okCallback()
				
			case .NoAccount:
				NSLog("CloudKit error: no account")
				errorCallback?()
				dispatch_async(dispatch_get_main_queue()) {
					errorWindow = MessageWindow(parent: viewForError, darkenBackground: true, titleStringId: "iCloudError", textStringId: "iCloudNoAccount", buttonStringId: "Close", handler: {
						errorWindow?.close()
					})
				}
				
			case .Restricted:
				NSLog("CloudKit error: Restricted")
				errorCallback?()
				dispatch_async(dispatch_get_main_queue()) {
					errorWindow = MessageWindow(parent: viewForError, darkenBackground: true, titleStringId: "iCloudError", textStringId: "iCloudRestricted", buttonStringId: "Close", handler: {
						errorWindow?.close()
					})
				}
				
			case .CouldNotDetermine:
				NSLog("CloudKit error: CouldNotDetermine")
				NSLog("CloudKit error description: \(error.description)")
				errorCallback?()
				dispatch_async(dispatch_get_main_queue()) {
					errorWindow = MessageWindow(parent: viewForError, darkenBackground: true, titleStringId: "iCloudError", textStringId: "iCloudCouldNotDetermine", buttonStringId: "Close", handler: {
						errorWindow?.close()
					})
				}
			}
		})
		
	}
	
}