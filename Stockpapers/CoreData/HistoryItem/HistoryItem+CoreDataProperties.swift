//
//  HistoryItem+CoreDataProperties.swift
//  Wallpapers
//
//  Created by Federico Vitale on 16/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//
//

import Foundation
import CoreData


extension HistoryItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<HistoryItem> {
        return NSFetchRequest<HistoryItem>(entityName: "HistoryItem")
    }

    @NSManaged public var id: String
    @NSManaged public var url: URL
    @NSManaged public var download_date: NSDate
}
