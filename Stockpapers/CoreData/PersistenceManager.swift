//
//  PersistenceManager.swift
//  Wallpapers
//
//  Created by Federico Vitale on 16/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import CoreData

class PersistenceManager {
    private init() {}
    
    static let shared = PersistenceManager()
    
    lazy var context = persistentContainer.viewContext
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "StockPapers")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func save() {
        if context.hasChanges {
            do {
                try context.save()
                print("New item saved successfully!")
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    func delete(object: NSManagedObject) {
        context.delete(object)
        save()
    }
    
    func fetch<T: NSManagedObject>(_ objectType: T.Type) -> [T] {
        let entityName = String(describing: objectType)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        do {
            let fetchedObjects = try context.fetch(fetchRequest) as? [T]
            return fetchedObjects ?? [T]()
        } catch {
            print(error.localizedDescription)
            return [T]()
        }
    }
}
