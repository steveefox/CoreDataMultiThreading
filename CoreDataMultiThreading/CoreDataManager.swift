//
//  CoreDataManager.swift
//  CoreDataMultiThreading
//
//  Created by Nikita on 4.09.22.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer
    private var _backgroundContext: NSManagedObjectContext?
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var backgroundContext: NSManagedObjectContext {
        if _backgroundContext == nil {
            _backgroundContext = persistentContainer.newBackgroundContext()
        }
        
        return _backgroundContext!
    }
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "MovieAppModel")
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Unable to initialize Core Data \(error)")
            }
        }
    }
}
