//
//  ProjectsViewModel.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 21/03/2022.
//

import CoreData
import Foundation

extension ProjectsView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        let dataController: DataController
        let showClosedProjects: Bool
        
        private let projectsController: NSFetchedResultsController<Project>
        
        @Published var projects = [Project]()
        var sortOrder: Item.SortOrder = .optimised
        
        var managedObjectContext: NSManagedObjectContext {
            return dataController.container.viewContext
        }
        
        init(dataController: DataController, showClosedProjects: Bool) {
            self.dataController = dataController
            self.showClosedProjects = showClosedProjects
            
            let fetchRequest: NSFetchRequest<Project> = Project.fetchRequest()
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(
                    keyPath: \Project.creationDate,
                    ascending: false
                )
            ]
            fetchRequest.predicate = NSPredicate(
                format: "closed = %d",
                showClosedProjects
            )
            projectsController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            
            super.init()
            projectsController.delegate = self
            
            do {
                try projectsController.performFetch()
                projects = projectsController.fetchedObjects ?? []
            } catch {
                print("Failed to fetch our projects!")
            }
        }
        
        func addProject() {
//            withAnimation {
                Project.newProject(managedObjectContext: managedObjectContext, dataController: dataController)
//            }
        }
        
        func addNewItem(to project: Project) {
//            withAnimation {
                Item.newItem(to: project, managedObjectContext: managedObjectContext, dataController: dataController)
//            }
        }
        
        func removeItems(from project: Project, at indexSet: IndexSet) {
            let projectItems = project.projectItems(using: sortOrder)
            
            for index in indexSet {
                let item = projectItems[index]
                dataController.delete(item)
            }
            
            dataController.save()
        }
        
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newProjects = controller.fetchedObjects as? [Project] {
                projects = newProjects
            }
        }
    }
}
