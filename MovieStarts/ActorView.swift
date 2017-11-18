//
//  ActorStackView.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 18.09.16.
//  Copyright © 2016 Oliver Eichhorn. All rights reserved.
//

import UIKit

class ActorView: UIView { // UIStackView {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var actorNameLabel: UILabel!
    @IBOutlet weak var characterNameLabel: UILabel!
    @IBOutlet weak var characterLabelMaxWidth: NSLayoutConstraint!

    static let imageSize = CGFloat(45.0)


    class func instanceFromNib() -> ActorView {
        return UINib(nibName: "ActorView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ActorView
    }

    open func setupWithActorWithName(_ actorName: String,
                                     characterName: String,
                                     profilePicture: String,
                                     hidden: Bool,
                                     parentWidth: CGFloat)
    {
        let basePath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.movieStartsGroup)?.path

        if let basePath = basePath, (profilePicture.count > 0) {
            let actorImageFilePath = basePath + Constants.actorThumbnailFolder + profilePicture
            imageView.image = self.cropImage(UIImage(contentsOfFile: actorImageFilePath))

            if (imageView.image == nil) {
                // actor-image not found: use default-image
                imageView.image = UIImage(named: "no-actor")

                // load the correct image from tmdb
                guard let sourceImageUrl = URL(string: "http://image.tmdb.org/t/p/w45" + profilePicture) else {
                    return
                }

                let task = URLSession.shared.downloadTask(with: sourceImageUrl, completionHandler: { (location: URL?, response: URLResponse?, error: Error?) -> Void in

                    if let error = error {
                        NSLog("Error getting actor thumbnail: \(error.localizedDescription)")
                    }
                    else if let receivedPath = location?.path {
                        // move received poster to target path where it belongs and update the button
                        do {
                            try FileManager.default.moveItem(atPath: receivedPath, toPath: actorImageFilePath)

                            DispatchQueue.main.async {
                                self.imageView.image = self.cropImage(UIImage(contentsOfFile: actorImageFilePath))
                            }
                        }
                        catch let error as NSError {
                            if ((error.domain == NSCocoaErrorDomain) && (error.code == NSFileWriteFileExistsError)) {
                                // ignoring, because it's okay it it's already there
                            }
                            else {
                                NSLog("Error moving actor thumbnail: \(error.localizedDescription)")
                            }
                        }
                    }
                })

                task.resume()
            }
        }

        actorNameLabel.text = actorName

        if (characterName.count > 0) {
            characterNameLabel.text = NSLocalizedString("ActorAs", comment: "") + " " + characterName
        }

        self.characterLabelMaxWidth.constant = parentWidth - ActorView.imageSize - 48.0
        self.isHidden = hidden
    }


    final func cropImage(_ inputImage: UIImage?) -> UIImage? {
        guard let inputImage = inputImage, let inputCgImage = inputImage.cgImage else { return nil }

        if let imageRef = inputCgImage.cropping(to:
            CGRect(x: 0.0, y: 0.0, width: ActorView.imageSize, height: ActorView.imageSize + 15.0))
        {
            return UIImage(cgImage: imageRef)
        }
        
        return nil
    }

}
