//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Damonique Thomas on 7/11/16.
//  Copyright © 2016 Damonique Thomas. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var pins = [Pin]()
    var editMode = false
    var managedObjectContext = CoreDataManager.sharedInstance().managedObjectContext

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        editMode = false
        setUp()
    }
    
    @IBAction func deletePin(sender: UIBarButtonItem) {
        print("here")
        deletePinHelper()
        
    }
    
    //MARK: Helper functions
    func addPin(gestureRecognizer : UIGestureRecognizer) {
        //add to map
        if gestureRecognizer.state == .Ended {
            let location = gestureRecognizer.locationInView(self.mapView)
            let coordinates = mapView.convertPoint(location, toCoordinateFromView: mapView)
            annotationHelper(coordinates)
            //add to core data
            let newPin = NSEntityDescription.insertNewObjectForEntityForName("Pin", inManagedObjectContext: self.managedObjectContext) as! Pin
            newPin.lat = coordinates.latitude
            newPin.lng = coordinates.longitude
            CoreDataManager.sharedInstance().saveContext()
        }
    }
    
    func deletePinHelper() {
        switch editMode {
        case false:
            editMode = true
             self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(MapViewController.deletePinHelper))
        case true:
            editMode = false
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(MapViewController.deletePinHelper))
        }
    }

    private func setUp() {
        //Gesture
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.addPin(_:)))
        longPress.minimumPressDuration = 1
        mapView.addGestureRecognizer(longPress)
        
        //Get pins from core data
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        if let fetchResults = (try? managedObjectContext.executeFetchRequest(fetchRequest)) as? [Pin] {
            pins = fetchResults
            for pin in pins {
                let coordinate = CLLocationCoordinate2D(latitude: Double(pin.lat!), longitude: Double(pin.lng!))
                annotationHelper(coordinate)
            }
        }
        else {
            print("error getting pins from core data")
        }
        
    }
    
    private func annotationHelper(coordinate: CLLocationCoordinate2D){
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "title"
        mapView.addAnnotation(annotation)
    }
    
    private func getSelectedPin(annotation: MKAnnotation) -> Pin? {
        for pin in pins {
            let coord = annotation.coordinate
            if coord.latitude == pin.lat && coord.longitude == pin.lng {
                return pin
            }
        }
        return nil
    }

    //MARK: Map functions
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.animatesDrop = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let pin = getSelectedPin(view.annotation!) {
            if !editMode {
                let controller = storyboard!.instantiateViewControllerWithIdentifier("collectionVC") as! CollectionViewController
                controller.pin = pin
                navigationController?.pushViewController(controller, animated: true)
                mapView.deselectAnnotation(view.annotation, animated: true)
            }
            else {
                mapView.removeAnnotation(view.annotation!)
                managedObjectContext.deleteObject(pin)
                CoreDataManager.sharedInstance().saveContext()
            }
        }

    }
    
}