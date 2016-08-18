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
        
        
        FlickerClient.sharedFlickerClient().searchPhotos(54.005108, longitude: -1.748286) { (info, results, success) in
            
            
        }
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
            
            self.view.height -= noteView.height

        } else {
            print("done")
            navigationItem.rightBarButtonItem = editButton
            self.view.height += noteView.height
        }
    }
}

extension UIView {
    var height:CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            self.frame.size.height = newValue
        }
    }
}
