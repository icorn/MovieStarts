//
//  AcceptPrivacyDelegate.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 21.05.18.
//  Copyright © 2018 Oliver Eichhorn. All rights reserved.
//


/*
 
If we ever need to show the privacy view in its own card, use this and implement the delegate:
 
if let acceptPrivacyViewController = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyViewController") as? AcceptPrivacyViewController
{
    acceptPrivacyViewController.acceptPrivacyDelegate = self
    self.present(acceptPrivacyViewController, animated: true, completion: { () in })
}
*/

protocol AcceptPrivacyDelegate
{
    func privacyStatementAccepted()
}
