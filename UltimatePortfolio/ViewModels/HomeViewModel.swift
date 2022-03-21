//
//  HomeViewModel.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 21/03/2022.
//

import CoreData
import Foundation

extension HomeView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        let dataController: DataController
        
        private let projectsController: NSFetchedResultsController<Project>
        private let itemsController: NSFetchedResultsController<Item>
        
        @Published var projects = [Project]()
        @Published var items = [Item]()
        
        var managedObjectContext: NSManagedObjectContext {
            return dataController.container.viewContext
        }
        var upNextItems: ArraySlice<Item> {
            items.prefix(3)
        }
        var moreToExploreItems: ArraySlice<Item> {
            items.dropFirst(3)
        }
        
        init(dataController: DataController) {
            self.dataController = dataController
            
            // Construct a fetch request to show all open projects
            let projectFetchRequest: NSFetchRequest<Project> = Project.fetchRequest()
            projectFetchRequest.sortDescriptors = [
                NSSortDescriptor(
                    keyPath: \Project.title,
                    ascending: true
                )
            ]
            projectFetchRequest.predicate = NSPredicate(format: "closed = false")
            
            projectsController = NSFetchedResultsController(
                fetchRequest: projectFetchRequest,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            
            // Construct a fetch request to show the 10 highest priority,
            // incomplete items in open projects.
            let itemFetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
            let completedPredicate = NSPredicate(format: "completed = false")
            let openProjectPredicate = NSPredicate(format: "project.closed = false")
            let compoundPredicate = NSCompoundPredicate(
                type: .and,
                subpredicates: [completedPredicate, openProjectPredicate]
            )
            let sortdescriptor = NSSortDescriptor(keyPath: \Item.priority, ascending: false)
            itemFetchRequest.predicate = compoundPredicate
            itemFetchRequest.sortDescriptors = [sortdescriptor]
            itemFetchRequest.fetchLimit = 10
            
            itemsController = NSFetchedResultsController(
                fetchRequest: itemFetchRequest,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            
            super.init()
            projectsController.delegate = self
            itemsController.delegate = self
            
            do {
                try projectsController.performFetch()
                projects = projectsController.fetchedObjects ?? []
            } catch {
                print("Failed to fetch our projects!")
            }
            
            do {
                try itemsController.performFetch()
                items = itemsController.fetchedObjects ?? []
                
            } catch {
                print("Failed to fetch our items!")
            }
        }
        
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newItems = controller.fetchedObjects as? [Item] {
                self.items = newItems
            } else if let newProjects = controller.fetchedObjects as? [Project] {
                projects = newProjects
            }
        }
        
        func addSampleData() {
            dataController.deleteAll()
            try? dataController.createSampleData()
        }
    }
}
