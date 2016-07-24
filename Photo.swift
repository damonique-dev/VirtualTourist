//
//  Photo.swift
//  VirtualTourist
//
//  Created by Damonique Thomas on 7/23/16.
//  Copyright © 2016 Damonique Thomas. All rights reserved.
//

import Foundation
import CoreData


class Photo: NSManagedObject {
    
    convenience init(url: String, data: NSData, context : NSManagedObjectContext){
        if let ent = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context){
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            imagePath = url
            imageData = data
        }else{
            fatalError("Unable to find Photo Entity name!")
        }
        
    }
    
}
