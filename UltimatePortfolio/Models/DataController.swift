//
//  DataController.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 26/01/2022.
//

import CoreData
import CoreSpotlight
import StoreKit
import SwiftUI
import UserNotifications

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
            userDefaults.bool(forKey: UDKey.fullVersionUnlocked)
        }
        set {
            userDefaults.set(newValue, forKey: UDKey.fullVersionUnlocked)
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
        }
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
            
            #if DEBUG
            if CommandLine.arguments.contains(CLArgument.enableTesting) {
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
        if viewContext.hasChanges {
            try? viewContext.save()
        }
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
        let batchDeleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)
        _ = try? viewContext.execute(batchDeleteRequest1)
        
        let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = Project.fetchRequest()
        let batchDeleteRequest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2)
        _ = try? viewContext.execute(batchDeleteRequest2)
    }
    
    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        let count = try? viewContext.count(for: fetchRequest)
        return count ?? 0
    }
    
    func hasEarned(award: Award) -> Bool {
        switch award.criterion {
        case .items:
            let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
            let criterionCount = count(for: fetchRequest)
            return criterionCount >= award.value
        case .complete:
            let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
            fetchRequest.predicate = NSPredicate(format: "completed = true")
            let criterionCount = count(for: fetchRequest)
            return criterionCount >= award.value
        // TODO: Other cases to be handled when features created
        default:
            return false
        }
    }
    
    // MARK: - Spotlight integration
    /// Adds Item Spotlight registry then saves CoreData changes
    func update(_ item: Item) {
        let itemID = item.objectID.uriRepresentation().absoluteString
        let projectID = item.project?.idURIString
        
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
    
    // MARK: - Notifications
    var uNCenter: UNUserNotificationCenter { return .current() }
    
    func addReminders(for project: Project, completion: @escaping (Bool) -> Void) {
        uNCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestNotificationsAuthorization { success in
                    if success {
                        self.placeReminders(for: project, completion: completion)
                    } else {
                        DispatchQueue.main.async {
                            completion(false)
                        }
                    }
                }
            case .authorized:
                self.placeReminders(for: project, completion: completion)
            case .denied, .ephemeral, .provisional:
                DispatchQueue.main.async {
                    completion(false)
                }
            @unknown default:
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    func removeReminders(for project: Project) {
        let id = project.idURIString
        uNCenter.removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    private func requestNotificationsAuthorization(completion: @escaping (Bool) -> Void) {
        uNCenter.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            completion(granted)
        }
    }
    
    private func placeReminders(for project: Project, completion: @escaping (Bool) -> Void) {
        let id = project.idURIString
        
        let nContent = UNMutableNotificationContent()
        nContent.title = project.projectTitle
        nContent.sound = .default
        if let projectDetail = project.detail {
            nContent.subtitle = projectDetail
        }
        
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: project.reminderTime ?? Date())
        let nTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let nRequest = UNNotificationRequest(identifier: id, content: nContent, trigger: nTrigger)
        uNCenter.add(nRequest) { error in
            DispatchQueue.main.async {
                let success = error == nil
                completion(success)
            }
        }
    }
    
    func appLaunched() {
        guard count(for: Project.fetchRequest()) >= 5 else { return }
        
        let allScenes = UIApplication.shared.connectedScenes
        let scene = allScenes.first { $0.activationState == .foregroundActive }
        
        if let windowScene = scene as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
