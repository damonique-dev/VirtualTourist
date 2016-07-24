//
//  Pin.swift
//  VirtualTourist
//
//  Created by Damonique Thomas on 7/23/16.
//  Copyright © 2016 Damonique Thomas. All rights reserved.
//

import Foundation
import CoreData
import MapKit


class Pin: NSManagedObject {
    
    convenience init(coordinate: CLLocationCoordinate2D, context: NSManagedObjectContext){
        if let ent = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context){
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            lat = coordinate.latitude
            lng = coordinate.longitude
        }else{
            fatalError("Unable to find Pin Entity name!")
        }
    }
}
