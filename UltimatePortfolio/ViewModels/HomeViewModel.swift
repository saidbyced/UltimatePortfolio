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
        @Published var selectedItem: Item?
        @Published var upNextItems = ArraySlice<Item>()
        @Published var moreToExploreItems = ArraySlice<Item>()
        
        var managedObjectContext: NSManagedObjectContext {
            return dataController.container.viewContext
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
            let itemFetchRequest = dataController.fetchRequestForTopItems(count: 10)
            
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
                upNextItems = items.prefix(3)
                moreToExploreItems = items.dropFirst(3)
            } catch {
                print("Failed to fetch our items!")
            }
        }
        
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            items = itemsController.fetchedObjects ?? []
            upNextItems = items.prefix(3)
            moreToExploreItems = items.dropFirst(3)
            
            projects = projectsController.fetchedObjects ?? []
        }
        
        func addSampleData() {
            dataController.deleteAll()
            try? dataController.createSampleData()
        }
        
        func selectItem(with identifier: String) {
            selectedItem = dataController.item(with: identifier)
        }
    }
}
