//
//  HistoryItem.swift
//  Wallpapers
//
//  Created by Federico Vitale on 16/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit
import CoreData


//let newHistoryItem = NSManagedObject(entity: entity!, insertInto: context)

//class HistoryItem {
//    private let appDelegate: AppDelegate!
//    private let context:NSManagedObjectContext!
//    private let entity: NSEntityDescription!
//
//    init(photo: Unsplash.Photo) {
//        self.appDelegate = UIApplication.shared.delegate as? AppDelegate
//        self.context = appDelegate.persistentContainer.viewContext
//        self.entity = NSEntityDescription.entity(forEntityName: "HistoryItems", in: context)
//
//        let item = NSManagedObject(entity: self.entity, insertInto: self.context)
//
//        item.setValue(photo.id, forKey: "id")
//        item.setValue(photo.urls.regular, forKey: "url")
//        item.setValue(Date(), forKey: "download_date")
//
//        do {
//            try context.save()
//        } catch let error {
//            print("Failed saving with error: \(error.localizedDescription)")
//        }
//    }
//}

class HistoryItem: NSManagedObject {
    
}

extension HistoryItem {
    
}
