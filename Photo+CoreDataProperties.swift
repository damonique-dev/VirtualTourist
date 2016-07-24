//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Damonique Thomas on 7/23/16.
//  Copyright © 2016 Damonique Thomas. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photo {

    @NSManaged var imagePath: String?
    @NSManaged var imageData: NSData?
    @NSManaged var pin: NSManagedObject?

}
