//
//  DataController.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 26/01/2022.
//

import CoreData
import CoreSpotlight
import SwiftUI
import WidgetKit

/// An environment singleton created for interfacing with CoreData including
/// saving, creation of preview/test data and award status.
class DataController: ObservableObject {
    /// The lone CloudKit container used to store all our data.
    let container: NSPersistentCloudKitContainer
    
    /// The UserDefaults suite we're using to save user data.
    let userDefaults: UserDefaults
    
    /// Loads and saves whether our premium unlock has been purchased.
    var fullVersionUnlocked: Bool {
        get {
            userDefaults.bool(forKey: UDKey.fullVersionUnlocked.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: UDKey.fullVersionUnlocked.rawValue)
        }
    }
    
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    /// Initialises a data controller either in memory (for temporary use in tests and previews),
    /// or in permanent storage (regular application).
    ///
    /// Defaults to permanent storage.
    /// - Parameter inMemory: Whether to store this data in temporary memory or not.
    /// - Parameter defaults: The UserDefaults suite to use for saving user data.
    init(inMemory: Bool = false, userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        
        container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)
        
        // Temporary, in-memory database creation for use in testing and previews;
        // this will be destroyed once app finishes running.
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            let groupID = "group.com.christophereadie.UltimatePortfolio"
            if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) {
                container.persistentStoreDescriptions.first?.url = url.appendingPathComponent("Main.sqlite")
            }
        }
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
            
            self.viewContext.automaticallyMergesChangesFromParent = true
            
            #if DEBUG
            if CommandLine.arguments.contains(CLArgument.enableTesting.rawValue) {
                self.deleteAll()
                UIView.setAnimationsEnabled(false)
            }
            #endif
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
    
    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Main", withExtension: "momd") else {
            fatalError("Failed to locate main model file.")
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load model file.")
        }
        
        return managedObjectModel
    }()
    
    /// Creates example projects and items to make testing, and previewing views, easier.
    /// - Throws: An error from calling save() on the NSManagedObjectContext.
    func createSampleData() throws {
        let viewContext = viewContext
        
        for projectNumber in 1...5 {
            let project = Project(context: viewContext)
            project.title = "Project \(projectNumber)"
            project.color = ProjectColor.lightBlue.asString
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
        
        save()
    }
    
    /// Saves the CoreData context only if there are changes. Errors are silently
    /// ignored since all attributes are optional.
    func save() {
        if viewContext.hasChanges {
            try? viewContext.save()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    @discardableResult func addProject() -> Bool {
        let canCreate = fullVersionUnlocked || count(for: Project.fetchRequest()) < 3
        if canCreate {
            let project = Project(context: viewContext)
            project.closed = false
            project.color = ProjectColor.lightBlue.asString
            project.creationDate = Date()
            save()
            return true
        } else {
            return false
        }
    }
    
    func addNewItem(to project: Project) {
        let item = Item(context: viewContext)
        item.project = project
        item.priority = 2
        item.completed = false
        item.creationDate = Date()
        save()
    }
    
    func delete(_ object: NSManagedObject) {
        let id = object.objectID.uriRepresentation().absoluteString
        
        if object is Project {
            CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [id])
        } else {
            CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [id])
        }
        
        viewContext.delete(object)
    }
    
    func delete(_ objects: [NSManagedObject]) {
        for object in objects {
            delete(object)
        }
    }
    
    func deleteAll() {
        let fetchRequest1: NSFetchRequest<NSFetchRequestResult> = Item.fetchRequest()
        delete(fetchRequest1)
        
        let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = Project.fetchRequest()
        delete(fetchRequest2)
    }
    
    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        if
            let delete = try? viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult,
            let deleteResult = delete.result as? [NSManagedObjectID]
        {
            let changes = [NSDeletedObjectsKey: deleteResult]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [viewContext])
        }
    }
    
    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        let count = try? viewContext.count(for: fetchRequest)
        return count ?? 0
    }
    
    func fetchRequestForTopItems(count: Int) -> NSFetchRequest<Item> {
        let itemFetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        let completedPredicate = NSPredicate(format: "completed = false")
        let openProjectPredicate = NSPredicate(format: "project.closed = false")
        let compoundPredicate = NSCompoundPredicate(
            type: .and,
            subpredicates: [completedPredicate, openProjectPredicate]
        )
        itemFetchRequest.predicate = compoundPredicate
        let sortdescriptor = NSSortDescriptor(keyPath: \Item.priority, ascending: false)
        itemFetchRequest.sortDescriptors = [sortdescriptor]
        itemFetchRequest.fetchLimit = count
        return itemFetchRequest
    }
    
    func results<T: NSManagedObject>(for fetchRequest: NSFetchRequest<T>) -> [T] {
        let results = try? viewContext.fetch(fetchRequest)
        return results ?? []
    }
    
    // MARK: - Spotlight integration
    /// Adds Item Spotlight registry then saves CoreData changes
    func update(_ item: Item) {
        let itemID = item.objectID.uriRepresentation().absoluteString
        let projectID = item.project?.objectID.uriRepresentation().absoluteString
        
        let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
        attributeSet.title = item.itemTitle
        attributeSet.contentDescription = item.itemDetail
        
        let searchableItem = CSSearchableItem(
            uniqueIdentifier: itemID,
            domainIdentifier: projectID,
            attributeSet: attributeSet
        )
        
        CSSearchableIndex.default().indexSearchableItems([searchableItem])
        
        save()
    }
    
    /// Returns Item from  Spotlight identifier
    func item(with uniqueIdentifier: String) -> Item? {
        guard
            let url = URL(string: uniqueIdentifier),
            let id = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url)
        else {
            return nil
        }
        
        return try? viewContext.existingObject(with: id) as? Item
    }
}
