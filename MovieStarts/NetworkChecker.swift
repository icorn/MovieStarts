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
	
		- parameter viewForError:	The parent view for error windows. If null, no error will be shown to user.
	
		- returns: TRUE if the network is available, FALSE otherwise
	*/
	class func checkReachability(viewForError: UIView?) -> Bool {
		
		let reachabilityStatus = Reach().connectionStatus()
		
		switch reachabilityStatus {
		case .Offline, .Unknown:
			NSLog("No network")
			
			if let viewForError = viewForError {
				var errorWindow: MessageWindow?
			
				dispatch_async(dispatch_get_main_queue()) {
					errorWindow = MessageWindow(parent: viewForError, darkenBackground: true, titleStringId: "NoNetworkTitle", textStringId: "NoNetworkText", buttonStringIds: 	["Close"],
						handler: { (buttonIndex) -> () in
							errorWindow?.close()
						}
					)
				}
			}
			
			return false
			
		case .Online(ReachabilityType.WiFi), .Online(ReachabilityType.WWAN):
			return true
		}
	}

	
	/**
		Checks the availibility of CloudKit.
	
		- parameter viewForError:	The parent view for error windows
		- parameter database:		The database object to use
		- parameter okCallback:		The callback which is called on success
		- parameter errorCallback:	The optional callback which is called on failure (even before the user has clicked "close" in the error-window)
	*/
	class func checkCloudKit(viewForError: UIView, database: DatabaseParent, okCallback: () -> (), errorCallback: (() -> ())?) {

		database.checkCloudKit({ (status: CKAccountStatus, error: NSError?) -> () in
			
			var errorWindow: MessageWindow?
			
			switch status {
			case .Available:
				okCallback()
				
			case .NoAccount:
				NSLog("CloudKit error: no account")
				errorCallback?()
				dispatch_async(dispatch_get_main_queue()) {
					errorWindow = MessageWindow(parent: viewForError, darkenBackground: true, titleStringId: "iCloudError", textStringId: "iCloudNoAccount", buttonStringIds: ["Close"],
						handler: { (buttonIndex) -> () in
							errorWindow?.close()
						}
					)
				}
				
			case .Restricted:
				NSLog("CloudKit error: Restricted")
				errorCallback?()
				dispatch_async(dispatch_get_main_queue()) {
					errorWindow = MessageWindow(parent: viewForError, darkenBackground: true, titleStringId: "iCloudError", textStringId: "iCloudRestricted", buttonStringIds: ["Close"],
						handler: { (buttonIndex) -> () in
							errorWindow?.close()
						}
					)
				}
				
			case .CouldNotDetermine:
				NSLog("CloudKit error: CouldNotDetermine")
				
				if let error = error {
					NSLog("CloudKit error description: \(error.description)")
				}
				
				errorCallback?()
				dispatch_async(dispatch_get_main_queue()) {
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