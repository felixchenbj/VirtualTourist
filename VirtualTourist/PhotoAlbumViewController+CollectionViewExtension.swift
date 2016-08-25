//
//  PhotoAlbumViewController+Extension.swift
//  VirtualTourist
//
//  Created by felix on 8/20/16.
//  Copyright © 2016 Felix Chen. All rights reserved.
//

import UIKit


extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fc = fetchedResultsController{
            if let count = fc.sections?[section].numberOfObjects {
                if count == 0 {
                    noImageLabel.hidden = false
                } else {
                    noImageLabel.hidden = true
                }
                return count
            }
        }
        noImageLabel.hidden = false
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let photo = fetchedResultsController?.objectAtIndexPath(indexPath) as! Photo
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! ImageCollectionViewCell
        cell.selectedImageView.hidden = true
        
        cell.photo = photo
        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8, 8, 8, 8)
    }
    
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, shouldDeselectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ImageCollectionViewCell
        
        cell.selectedImageView.hidden = false
        updateNewCollectionButton()
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ImageCollectionViewCell
        
        cell.stack = self.stack
        cell.selectedImageView.hidden = true
        updateNewCollectionButton()
    }
}