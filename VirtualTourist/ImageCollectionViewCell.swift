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

    var photo: Photo? {
        didSet {
            if let photo = photo {
                if let photoData = photo.photoFileData {
                    imageView.image = UIImage(data: photoData)
                    activityIndicator.stopAnimating()
                } else {
                    if let photoURL = photo.photoURL {
                        if let url = NSURL(string: photoURL) {
                            activityIndicator.startAnimating()
                            downloadImage(url)
                        }
                    }
                }
            }
        }
    }
    
    var pin: Pin?

    /*
    func clearPhoto() {
        imageView.image = nil
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if let photo = photo {
            delegate.stack.context.deleteObject(photo)
        }
        photo = nil
    }
 */
    
    private func getDataFromUrl(url: NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) {
            (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    private func downloadImage(url: NSURL){
        getDataFromUrl(url) { (data, response, error)  in
            guard let data = data where error == nil else { return }
            
            FunctionsHelper.performUIUpdatesOnMain({ 
                Logger.log.debug(response?.suggestedFilename ?? url.lastPathComponent ?? "")
                Logger.log.debug("Download finished.")
                self.imageView.image = UIImage(data: data)
                
                if let photo = self.photo {
                    photo.photoFileData = data
                }
                self.activityIndicator.stopAnimating()
            })
        }
    }
}
