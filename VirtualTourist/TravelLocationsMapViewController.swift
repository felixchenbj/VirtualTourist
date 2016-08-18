//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by felix on 8/17/16.
//  Copyright © 2016 Felix Chen. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var noteView: UIView!
    
    
    var editButton: UIBarButtonItem!
    var doneButton: UIBarButtonItem!
    
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
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        // Dispose of any resources that can be recreated.
    }
    
    func dropPin(gestureRecognizer: UIGestureRecognizer) {
        let tapPoint: CGPoint = gestureRecognizer.locationInView(mapView)
        let touchMapCoordinate: CLLocationCoordinate2D = mapView.convertPoint(tapPoint, toCoordinateFromView: mapView)
        
        if UIGestureRecognizerState.Began == gestureRecognizer.state {
            let pin = MKPointAnnotation()
            pin.coordinate = touchMapCoordinate
            mapView.addAnnotation(pin)
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        if isInEditMode {
            performSegueWithIdentifier("gotoPhotoAlbum", sender: self)
        } else {
            if let pin = view.annotation {
                mapView.removeAnnotation(pin)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "gotoPhotoAlbum") {
            Logger.log.info("gotoPhotoAlbum")            /*
            if let viewController = segue.destinationViewController as? PhotoAlbumViewController {
                
            }
            */
        }
    }
    
    func updateUI() {
        if isInEditMode {
            navigationItem.rightBarButtonItem = doneButton
            
            UIView.animateWithDuration(0.4, delay: 0, options: [], animations: {
                self.noteView.hidden = false
                }, completion: { _ in } )
            
        } else {
            print("done")
            navigationItem.rightBarButtonItem = editButton
            
            UIView.animateWithDuration(0.4, delay: 0, options: [], animations: {
                self.noteView.hidden = true
                }, completion: { _ in } )
        }
    }
}
