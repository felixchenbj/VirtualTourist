//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by felix on 8/17/16.
//  Copyright © 2016 Felix Chen. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    var fetchedResultsController: NSFetchedResultsController!
    var blockOperations = [NSBlockOperation]()
    
    var pin: Pin?
    var stack: CoreDataStack!
    
    var hasItemSelected = false
    
    
    @IBOutlet weak var noImageLabel: UILabel!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBAction func fetchNewCollection(sender: UIButton) {
        
        if hasItemSelected {
            if let selectedItems = collectionView.indexPathsForSelectedItems() {
                for item in selectedItems {
                    if let obj = fetchedResultsController.objectAtIndexPath(item) as? NSManagedObject {
                        fetchedResultsController.managedObjectContext.deleteObject(obj)
                    }
                }
                stack.save()
            }
        } else {
            fetchRandomPhotos()
        }
        updateNewCollectionButton()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Logger.log.info("PhotoAlbumViewController.viewDidLoad")

        let space: CGFloat = 5.0
        
        collectionViewFlowLayout.minimumInteritemSpacing = space
        collectionViewFlowLayout.minimumLineSpacing = space
        collectionViewFlowLayout.itemSize = CGSizeMake(100, 100)
        
        collectionView.allowsMultipleSelection = true
        
        fetchedResultsController.delegate = self
        
        updateNewCollectionButton()
        
        // Get the stack
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        stack = delegate.stack
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let pin = pin {
            clearAllAnnotations()
            mapView.addAnnotation(pin)
            FunctionsHelper.centerMapOnStudentLocation(pin, mapView: mapView)
        }
        
        if needToRefetchPhotos() {
            fetchRandomPhotos()
        }
        
        collectionView.reloadData()
    }
    
    func needToRefetchPhotos() -> Bool{
        executeSearch()
        
        if let fc = self.fetchedResultsController {
            if let fetchedObjects = fc.fetchedObjects {
                
                guard fetchedObjects.count > 0 else {
                    return true
                }
                
                for object in fetchedObjects {
                    if let photo = object as? Photo {
                        if  photo.photoFileData != nil{
                            Logger.log.debug("There is a photo has data in core data.")
                            return false
                        }
                    }
                }
            }
        }
        
        return true
    }
    
    func fetchRandomPhotos() {
        if let pin = pin {
            FlickerClient.sharedFlickerClient().getRandomPhotos(pin.latitude as! Double, longitude: pin.longitude as! Double, completionHandler: { (info, results, success) in
                
                FunctionsHelper.performUIUpdatesOnMain({
                    
                    guard success else {
                        Logger.log.error(info)
                        return
                    }
                    
                    if let fetchedObjects = self.fetchedResultsController.fetchedObjects {
                        for object in fetchedObjects {
                            if let obj = object as? NSManagedObject {
                                self.fetchedResultsController.managedObjectContext.deleteObject(obj)
                            }
                        }
                    }
                    
                    
                    if let results = results {
                        for photoPath in results {
                            let _ = Photo(data: nil, photoURL: photoPath, pin: self.pin, context: self.fetchedResultsController.managedObjectContext)
                        }
                    }
                })
                self.stack.save()
            })
        }
    }
    
    func executeSearch(){
        if let fetchedResultsController = fetchedResultsController {
            
            do{
                try fetchedResultsController.performFetch()
                Logger.log.info("performFetch")
            }catch let e as NSError{
                Logger.log.error("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
    
    func clearAllAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
    }
    
    func updateNewCollectionButton() {
        hasItemSelected = false
        if let selectedItems = collectionView.indexPathsForSelectedItems() {
            if selectedItems.count > 0 {
                hasItemSelected = true
            }
        }
        
        if hasItemSelected {
            newCollectionButton.setTitle("Remove Selected Items", forState: UIControlState.Normal)
        } else {
            newCollectionButton.setTitle("New Collection", forState: UIControlState.Normal)
        }
        
    }
}

