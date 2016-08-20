//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by felix on 8/17/16.
//  Copyright © 2016 Felix Chen. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var noteView: UIView!
    
    var fetchedResultsController: NSFetchedResultsController?
    
    var editButton: UIBarButtonItem!
    var doneButton: UIBarButtonItem!
    
    var stack: CoreDataStack!
    
    var selectedPinIndex:Int = 0
    
    var isInEditMode = false

    
    func rightBarButtonPressed() {
        Logger.log.info("rightBarButtonPressed")
        
        isInEditMode = !isInEditMode
        
        updateUI()
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        editButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(TravelLocationsMapViewController.rightBarButtonPressed))
        
        doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(TravelLocationsMapViewController.rightBarButtonPressed))
        
        
        updateUI()

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(TravelLocationsMapViewController.dropPin(_:)))
        longPress.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPress)
        
        mapView.delegate = self
        
        // Get the stack
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        stack = delegate.stack
        
        setUpFetchedResultsController()
        
        executeSearch()
        loadPinFromModel()
    }
    
    private func setUpFetchedResultsController() {
        // Create a fetchrequest
        let fr = NSFetchRequest(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true),
                              NSSortDescriptor(key: "longitude", ascending: true)]
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr,
                                                              managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)

    }
    
    func dropPin(gestureRecognizer: UIGestureRecognizer) {
        let tapPoint: CGPoint = gestureRecognizer.locationInView(mapView)
        let touchMapCoordinate: CLLocationCoordinate2D = mapView.convertPoint(tapPoint, toCoordinateFromView: mapView)
        
        if UIGestureRecognizerState.Began == gestureRecognizer.state {
            if let fetchedResultsController = fetchedResultsController {
                let pin = Pin(annotationLatitude: touchMapCoordinate.latitude, annotationLongitude: touchMapCoordinate.longitude, context: fetchedResultsController.managedObjectContext)
                mapView.addAnnotation(pin)
            }
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        if isInEditMode {
            if let pin = view.annotation as? Pin {
                if let fetchedResultsController = fetchedResultsController {
                    Logger.log.debug("Delete a pin.")
                    mapView.removeAnnotation(pin)
                    fetchedResultsController.managedObjectContext.deleteObject(pin)
                }
            }
        } else {
            performSegueWithIdentifier("gotoPhotoAlbum", sender: view.annotation)
        }
    }
    
    func loadPinFromModel() {
        if let fc = fetchedResultsController {
            if let fetchedObjects = fc.fetchedObjects {
                clearAllAnnotations()
                
                for object in fetchedObjects {
                    if let pin = object as? Pin {
                        mapView.addAnnotation(pin)
                    }
                }
                
                if mapView.annotations.count > 0 {
                    FunctionsHelper.centerMapOnStudentLocation((mapView.annotations[0] as? Pin)!, mapView: mapView, regionRadius: 20000)
                }
            }
        }
    }
    
    func clearAllAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
    }
    
    func executeSearch(){
        if let fetchedResultsController = fetchedResultsController {
            do{
                try fetchedResultsController.performFetch()
            }catch let e as NSError{
                Logger.log.error("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "gotoPhotoAlbum") {
            Logger.log.info("gotoPhotoAlbum")
            if let viewController = segue.destinationViewController as? PhotoAlbumViewController {
                if let pin = sender as? Pin {
                    Logger.log.debug("Set pin to next view controller")
                    
                    let fr = NSFetchRequest(entityName: "Photo")
                    let pred = NSPredicate(format: "pin = %@", argumentArray: [pin])
                    
                    fr.predicate = pred
                    fr.sortDescriptors = [NSSortDescriptor(key: "photoURL", ascending: true)]
                    
                    // Create FetchedResultsController
                    let fc = NSFetchedResultsController(fetchRequest: fr,
                                                        managedObjectContext:fetchedResultsController!.managedObjectContext,
                                                        sectionNameKeyPath: nil,
                                                        cacheName: nil)

                    viewController.fetchedResultsController = fc
                    viewController.pin = pin
                    
                    stack.save()
                }
            }
        }
    }
    
    func updateUI() {
        if isInEditMode {
            print("edit")
            navigationItem.rightBarButtonItem = doneButton
            
            self.view.frame.origin.y -= noteView.frame.size.height

        } else {
            print("done")
            navigationItem.rightBarButtonItem = editButton
            self.view.frame.origin.y += noteView.frame.size.height
        }
    }
}