//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Damonique Thomas on 7/11/16.
//  Copyright © 2016 Damonique Thomas. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.addPin(_:)))
        longPress.minimumPressDuration = 2
        mapView.addGestureRecognizer(longPress)
    }
    
    func addPin(getstureRecognizer : UIGestureRecognizer) {
        let location = getstureRecognizer.locationInView(self.mapView)
        let coordinates = mapView.convertPoint(location, toCoordinateFromView: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        mapView.addAnnotation(annotation)
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            performSegueWithIdentifier("pinPhotos", sender: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pinPhotos" {
            //let controller = segue.destinationViewController as! MapViewController
            
        }
    }
    
}