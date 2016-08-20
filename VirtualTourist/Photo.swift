//
//  Photo.swift
//  VirtualTourist
//
//  Created by felix on 8/18/16.
//  Copyright © 2016 Felix Chen. All rights reserved.
//

import Foundation
import CoreData


class Photo: NSManagedObject {
    
    convenience init(data: NSData?, photoURL: String?, pin: Pin?, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context) {
            self.init(entity: entity, insertIntoManagedObjectContext: context)
            
            self.photoFileData = data
            self.photoURL = photoURL
            self.pin = pin
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
