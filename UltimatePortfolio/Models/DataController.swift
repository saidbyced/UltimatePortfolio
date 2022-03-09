//
//  DataController.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 26/01/2022.
//

import CoreData
import SwiftUI

/// An environment singleton created for interfacing with CoreData including
/// saving, creation of preview/test data and award status.
class DataController: ObservableObject {
    /// The lone CloudKit container used to store all our data.
    let container: NSPersistentCloudKitContainer
    
    /// Initialises a data controller either in memory (for temporary use in tests and previews),
    /// or in permanent storage (regular application).
    ///
    /// Defaults to permanent storage.
    /// - Parameter inMemory: Whether to store this data in temporary memory or not.
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Main")
        
        // Temporary, in-memory database creation for use in testing and previews;
        // this will be destroyed once app finishes running.
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
        }
    }
    
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        
        do {
            try dataController.createSampleData()
        } catch {
            fatalError("Fatal error creating preview: \(error.localizedDescription)")
        }
        
        return dataController
    }()
    
    /// Creates example projects and items to make testing, and previewing views, easier.
    /// - Throws: An error from calling save() on the NSManagedObjectContext.
    func createSampleData() throws {
        let viewContext = container.viewContext
        
        for projectNumber in 1...5 {
            let project = Project(context: viewContext)
            project.title = "Project \(projectNumber)"
            project.items = []
            project.creationDate = Date()
            project.closed = Bool.random()
            
            for itemNumber in 1...10 {
                let item = Item(context: viewContext)
                item.title = "Item \(itemNumber)"
                item.creationDate = Date()
                item.completed = Bool.random()
                item.project = project
                item.priority = Int16.random(in: 1...3)
            }
        }
        
        try viewContext.save()
    }
    
    /// Saves the CoreData context only if there are changes. Errors are silently
    /// ignored since all attributes are optional.
    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }
    
    func delete(_ object: NSManagedObject) {
        container.viewContext.delete(object)
    }
    
    func deleteAll() {
        let fetchRequest1: NSFetchRequest<NSFetchRequestResult> = Item.fetchRequest()
        let batchDeleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)
        _ = try? container.viewContext.execute(batchDeleteRequest1)
        
        let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = Project.fetchRequest()
        let batchDeleteRequest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2)
        _ = try? container.viewContext.execute(batchDeleteRequest2)
    }
    
    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        let count = try? container.viewContext.count(for: fetchRequest)
        return count ?? 0
    }
    
    func hasEarned(award: Award) -> Bool? {
        switch award.criterion {
        case "items":
            let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
            let criterionCount = count(for: fetchRequest)
            return criterionCount >= award.value
        case "complete":
            let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
            fetchRequest.predicate = NSPredicate(format: "completed = true")
            let criterionCount = count(for: fetchRequest)
            return criterionCount >= award.value
        default:
            return nil
        }
    }
}
