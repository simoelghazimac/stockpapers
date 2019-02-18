//
//  Favourite+CoreDataProperties.swift
//  Stockpapers
//
//  Created by Federico Vitale on 07/12/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//
//

import Foundation
import CoreData


extension Favourite {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Favourite> {
        return NSFetchRequest<Favourite>(entityName: "Favourite")
    }

    @NSManaged public var id: String
    @NSManaged public var url: URL
    @NSManaged public var addedOn: NSDate
}
