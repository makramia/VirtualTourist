//
//  DataController.swift
//  Mooskine
//
//  Created by Ibrahim Al-Makrami on 08/05/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import Foundation
import CoreData

class DataController{
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext{
        
        return persistentContainer.viewContext
    }
    
    init(modelName: String){
        
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(compeletion: (() -> Void)? = nil){
        
        persistentContainer.loadPersistentStores { storedDescription, error in
            
            guard error == nil else{
                
                fatalError(error!.localizedDescription)
            }
            
            self.autoSaveViewContext()
            compeletion?()
        }
    }
    
    
}

extension DataController{
    
    func autoSaveViewContext(interval: TimeInterval = 30){
        
        //print("autosaving")
        
        guard interval > 0 else{
            
            print("cannot set negative autosave interval")
            return
        }
        
        if viewContext.hasChanges{
            try? viewContext.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval){
            self.autoSaveViewContext(interval: interval)
        }
    }
    
    
    func fetchPin(_ predicate: NSPredicate) throws -> Pin? {
       
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.predicate = predicate
        
        guard let pin = (try viewContext.fetch(fetchRequest) ).first else {
            return nil
        }
        return pin
    }
}
