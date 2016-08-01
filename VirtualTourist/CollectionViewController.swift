//
//  CollectionViewController.swift
//  VirtualTourist
//
//  Created by Damonique Thomas on 7/20/16.
//  Copyright © 2016 Damonique Thomas. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class CollectionViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var noPhotosLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!

    var managedObjectContext = CoreDataManager.sharedInstance().managedObjectContext
    var pin: Pin!
    var coordinates: CLLocationCoordinate2D!
    var lat:Float!
    var lng:Float!
    var photos: [Photo]!
    var downloadCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        automaticallyAdjustsScrollViewInsets = false;
        lat = Float(pin.lat!)
        lng = Float(pin.lng!)
        noPhotosLabel.hidden = true
        setUpMap()
        getPinPhotos()
    }

    @IBAction func getNewCollection(sender: UIButton) {
        for photo in photos {
            removePhoto(photo)
        }
        newCollectionBtn.enabled = false
        noPhotosLabel.hidden = true
        photos.removeAll()
        downloadCount = 0
        
        getFlickrPhotos()
        collectionView.reloadData()
    }

    //MARK: Networking Methods
    private func getFlickrPhotos() {
        FlickrClient.sharedInstance().getLocationPhotos(lat, lng: lng) { (results, success, bool) in
            if success {
                FlickrClient.sharedInstance().getPagePhotos(self.lat, lng: self.lng, page: results!) {  (results, success, bool) in
                    if success {
                        
                        if results!.count == 0{
                            self.noPhotosLabel.hidden = false
                        }
                        else {
                            for url in results! {
                                dispatch_async(dispatch_get_main_queue()) {
                                let newPhoto = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: self.managedObjectContext) as! Photo
                                newPhoto.imagePath = url
                                newPhoto.pin = self.pin
                                CoreDataManager.sharedInstance().saveContext()
                                self.photos.append(newPhoto)
                                self.downloadCount+=1
                                print(self.downloadCount)
                                }
                            }
                            self.collectionView.reloadData()
                        }
                    } else {
                        print("error getting photos from networking")
                    }
                }
            } else {
                print("error getting random page from networking")
            }
        }
    }

    //MARK: Helper Methods
    private func getPinPhotos() {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin)
        if let fetchResults = (try? managedObjectContext.executeFetchRequest(fetchRequest)) as? [Photo] {
            photos = fetchResults
            if photos.count == 0 {
                getFlickrPhotos();
            }
        }
        else {
            print("error getting photos from core data")
        }
    }

    func removePhoto(photo: Photo) {
        managedObjectContext.deleteObject(photo)
        CoreDataManager.sharedInstance().saveContext()
    }

    func setUpMap(){
        let annotation = MKPointAnnotation()
        let regionRadius: CLLocationDistance = 10000
        annotation.coordinate = coordinates
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinates, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.addAnnotation(annotation)
    }

    func configureCell(cell: FlickrPhotoCell, photo: Photo){
        let tempImage = UIImage(named:"Temp Image")
        cell.setCellImage(nil)
        if let imageData = photo.imageData {
            cell.setCellImage(UIImage(data: imageData))
        } else {
            cell.setCellImage(tempImage)
                FlickrClient.sharedInstance().getPhoto(photo.imagePath!) { (data, success) in
                    if success {
                        dispatch_async(dispatch_get_main_queue()) {
                        cell.setCellImage(UIImage(data: data!))
                        photo.imageData = data
                        CoreDataManager.sharedInstance().saveContext()
                        self.downloadCount-=1
                        print(self.downloadCount)
                        }

                    } else {
                        print("Error getting image data")
                    }
                
                }
        }
    }

    //MARK: Map view methods
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "userpin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    //MARK: Collection view methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("picCell", forIndexPath: indexPath) as! FlickrPhotoCell
        let photo = photos[indexPath.item]
        dispatch_async(dispatch_get_main_queue()) {
            self.configureCell(cell, photo: photo)
        }
        if downloadCount <= 0 {
            newCollectionBtn.enabled = true
        }
        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        if downloadCount <= 0 {
            let index = indexPath.row
            let photo = photos[index]
            if photo.imageData != nil {
                removePhoto(photo)
                photos.removeAtIndex(index)
                collectionView.deleteItemsAtIndexPaths([indexPath])
            }
        }
    }

}