//
//  CoreDataStack.swift
//  Seecret
//
//  Created by Matthew D'Arcy on 1/25/16.
//  Copyright © 2016 Matt D'Arcy. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    let context: NSManagedObjectContext
    let psc: NSPersistentStoreCoordinator
    let model: NSManagedObjectModel
    
    init() {
        let bundle = NSBundle.mainBundle()
        let modelURL = bundle.URLForResource("Data", withExtension: "momd")!
        model = NSManagedObjectModel(contentsOfURL: modelURL)!
        
        psc = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        context = NSManagedObjectContext()
        context.persistentStoreCoordinator = psc
        
        let appDir = applicationDocumentDirectory()
        let storeURL = appDir.URLByAppendingPathComponent("Data")
        
        let option = [NSMigratePersistentStoresAutomaticallyOption: true]
        
        var err: NSError?
        
        do {
            
            try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: option)
            
        } catch let err1 as NSError {
            err = err1
        }
        
        if(err != nil) {
            print("Could not create the store")
            abort()
        }
    }
    
    
    
    
    func save() {
        var err: NSError?
        
        do {
            
            try context.save()
            
        } catch let err1 as NSError {
            err = err1
        }
        
        if(err != nil) {
            print("Could not save data")
        }
    }
    
    
    
    
    func applicationDocumentDirectory() -> NSURL {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[0]
    }
    
}