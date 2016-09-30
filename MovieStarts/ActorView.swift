//
//  ActorStackView.swift
//  MovieStarts
//
//  Created by Oliver Eichhorn on 18.09.16.
//  Copyright © 2016 Oliver Eichhorn. All rights reserved.
//

import UIKit

class ActorView: UIStackView {

    static let imageSize = 45
    var imageView: UIImageView?

    open func setupWithActor(_ actorName: String, characterName: String, profilePicture: String, hidden: Bool) {

        self.imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: ActorView.imageSize, height: ActorView.imageSize))
        guard let imageView = self.imageView else { return }

        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.image = UIImage(named: "noactor")

        let basePath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.movieStartsGroup)?.path

        if let basePath = basePath, (profilePicture.characters.count > 0) {
            let actorImageFilePath = basePath + Constants.actorThumbnailFolder + profilePicture
            imageView.image = self.cropImage(UIImage(contentsOfFile: actorImageFilePath))

            if (imageView.image == nil) {
                // actor-image not found: use default-image
                imageView.image = UIImage(named: "noactor")

                // load the correct image from YouTube
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
                            imageView.image = self.cropImage(UIImage(contentsOfFile: actorImageFilePath))
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

        let actorNameLabel = UILabel()
        actorNameLabel.text = actorName
        actorNameLabel.font = UIFont.systemFont(ofSize: 14.0)

        let innerStackView = UIStackView(arrangedSubviews: [actorNameLabel])
        innerStackView.axis = .vertical
        innerStackView.alignment = UIStackViewAlignment.leading
        innerStackView.distribution = UIStackViewDistribution.fill
        innerStackView.spacing = 0
        
        if (characterName.characters.count > 0) {
            let characterNameLabel = UILabel()
            characterNameLabel.text = NSLocalizedString("ActorAs", comment: "") + " " + characterName
            characterNameLabel.font = UIFont.systemFont(ofSize: 12.0)
            innerStackView.addArrangedSubview(characterNameLabel)
        }

        self.addArrangedSubview(imageView)
        self.addArrangedSubview(innerStackView)
        self.axis = .horizontal
        self.alignment = UIStackViewAlignment.center
        self.distribution = UIStackViewDistribution.fill
        self.spacing = 8
        self.isHidden = hidden
    }


    final func cropImage(_ inputImage: UIImage?) -> UIImage? {
        guard let inputImage = inputImage, let inputCgImage = inputImage.cgImage else { return nil }

        if let imageRef = inputCgImage.cropping(to:
            CGRect(x: 0, y: 0, width: ActorView.imageSize, height: ActorView.imageSize + 15))
        {
            return UIImage(cgImage: imageRef)
        }
        
        return nil
    }

}
