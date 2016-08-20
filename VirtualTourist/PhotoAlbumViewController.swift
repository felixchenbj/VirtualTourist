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

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    var fetchedResultsController: NSFetchedResultsController!
    
    var pin: Pin?
    
    var stack: CoreDataStack!
    
    @IBAction func fetchNewCollection(sender: UIButton) {
        fetchRandomPhotos()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Logger.log.info("PhotoAlbumViewController.viewDidLoad")

        let space: CGFloat = 5.0
        
        collectionViewFlowLayout.minimumInteritemSpacing = space
        collectionViewFlowLayout.minimumLineSpacing = space
        collectionViewFlowLayout.itemSize = CGSizeMake(100, 100)
        
        //fetchedResultsController?.delegate = CollectionViewFetchedResultsControllerDelegate(collectionView: collectionView)
        
        //collectionView.delegate = self
        
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
        
        /*
        if let fc = self.fetchedResultsController {
            if let fetchedObjects = fc.fetchedObjects {
                if fetchedObjects.count <= 0 {
                    fetchRandomPhotos()
                }
            }
        }
 */
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
                        Logger.log.debug("")
                        if  photo.photoFileData != nil{
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
                    
                    //self.executeSearch()
                    if let fc = self.fetchedResultsController {
                        if let fetchedObjects = fc.fetchedObjects {
                            for object in fetchedObjects {
                                if let obj = object as? NSManagedObject {
                                    fc.managedObjectContext.deleteObject(obj)
                                }
                            }
                        }
                    }
                    
                    if let results = results {
                        for photoPath in results {
                            //self.imageList.append(photoPath)
                            //print(photoPath)
                            let _ = Photo(data: nil, photoURL: photoPath, pin: self.pin, context: self.fetchedResultsController.managedObjectContext)
                        }
                    }
                    self.executeSearch()
                    
                    self.collectionView.reloadData()
                    
                    self.stack.save()
                })
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

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fc = fetchedResultsController{
            
            if let count = fc.sections?[section].numberOfObjects {
                return count
            }
        }
        return 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let photo = fetchedResultsController?.objectAtIndexPath(indexPath) as! Photo
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! ImageCollectionViewCell
        
        cell.photo = photo
        //cell.photoPath = path
        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8, 8, 8, 8)
    }
}

/*
extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView.performBatchUpdates({
            self.blockOperations.forEach { $0.start() }
            }, completion: { finished in
                self.blockOperations.removeAll(keepCapacity: false)
        })
    }

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        blockOperations.removeAll(keepCapacity: false)
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
            
        case .Insert:
            guard let newIndexPath = newIndexPath else { return }
            let op = NSBlockOperation { [weak self] in self?.collectionView.insertItemsAtIndexPaths([newIndexPath]) }
            blockOperations.append(op)
            
        case .Update:
            guard let newIndexPath = newIndexPath else { return }
            let op = NSBlockOperation { [weak self] in self?.collectionView.reloadItemsAtIndexPaths([newIndexPath]) }
            blockOperations.append(op)
            
        case .Move:
            guard let indexPath = indexPath else { return }
            guard let newIndexPath = newIndexPath else { return }
            let op = NSBlockOperation { [weak self] in self?.collectionView.moveItemAtIndexPath(indexPath, toIndexPath: newIndexPath) }
            blockOperations.append(op)
            
        case .Delete:
            guard let indexPath = indexPath else { return }
            let op = NSBlockOperation { [weak self] in self?.collectionView.deleteItemsAtIndexPaths([indexPath]) }
            blockOperations.append(op)
            
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        switch type {
            
        case .Insert:
            let op = NSBlockOperation { [weak self] in self?.collectionView.insertSections(NSIndexSet(index: sectionIndex)) }
            blockOperations.append(op)
            
        case .Update:
            let op = NSBlockOperation { [weak self] in self?.collectionView.reloadSections(NSIndexSet(index: sectionIndex)) }
            blockOperations.append(op)
            
        case .Delete:
            let op = NSBlockOperation { [weak self] in self?.collectionView.deleteSections(NSIndexSet(index: sectionIndex)) }
            blockOperations.append(op)
            
        default: break
            
        }
    }
}
 */
