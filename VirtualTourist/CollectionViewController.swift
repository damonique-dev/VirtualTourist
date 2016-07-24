//
//  CollectionViewController.swift
//  VirtualTourist
//
//  Created by Damonique Thomas on 7/20/16.
//  Copyright © 2016 Damonique Thomas. All rights reserved.
//

import UIKit
import MapKit

class CollectionViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionBtn: UIButton!
    
    var pin: Pin!
    var lat:Float!
    var lng:Float!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(pin.lat)
        print(pin.lng)
        lat = Float(pin.lat!)
        lng = Float(pin.lng!)
        
    }
    
    @IBAction func getNewCollection(sender: UIButton) {
        FlickrClient.sharedInstance().getLocationPhotos(lat, lng: lng) { (photos, success, bool) in
            if success {
                
            }
        }
    }

}
