//
//  ImageCollectionViewCell.swift
//  VirtualTourist
//
//  Created by felix on 8/19/16.
//  Copyright © 2016 Felix Chen. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var selectedImageView: UIImageView!
    
    var stack: CoreDataStack?
    
    var photo: Photo? {
        didSet {
            if let photo = photo {
                if let photoData = photo.photoFileData {
                    FunctionsHelper.performUIUpdatesOnMain({
                        self.imageView.image = UIImage(data: photoData)
                        self.activityIndicator.stopAnimating()
                    })
                } else {
                    if let photoURL = photo.photoURL {
                        if let url = NSURL(string: photoURL) {
                            FunctionsHelper.performUIUpdatesOnMain({
                                self.imageView.image = nil
                                self.activityIndicator.startAnimating()
                            })
                            getImageData(url)
                        }
                    }
                }
            }
        }
    }
    
    var pin: Pin?
    
    private func getImageData(url: NSURL){
        HTTPHelper.downloadImageFromUrl(url) { (data, response, error)  in
            FunctionsHelper.performUIUpdatesOnMain({
                guard let data = data where error == nil else {
                    self.activityIndicator.stopAnimating()
                    return
                }
                
                Logger.log.debug(response?.suggestedFilename ?? url.lastPathComponent ?? "")
                Logger.log.debug("Download finished.")
                self.imageView.image = UIImage(data: data)
                
                if let photo = self.photo {
                    photo.photoFileData = data
                }
                self.activityIndicator.stopAnimating()
                
                if let stack = self.stack {
                    stack.save()
                }
            })
        }
    }
}
