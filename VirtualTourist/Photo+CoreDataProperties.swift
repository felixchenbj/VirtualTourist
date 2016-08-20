//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by felix on 8/19/16.
//  Copyright © 2016 Felix Chen. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photo {

    @NSManaged var photoFileData: NSData?
    @NSManaged var photoURL: String?
    @NSManaged var pin: Pin?

}
