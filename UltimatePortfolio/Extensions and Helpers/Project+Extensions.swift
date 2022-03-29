//
//  Project+Extensions.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 10/02/2022.
//

import CoreData
import SwiftUI

extension Project {
    // MARK: - CoreData helpers
    var projectTitle: String {
        return title ?? NSLocalizedString("New Project", comment: "Name for new Project")
    }
    
    var projectDetail: String {
        return detail ?? ""
    }
    
    var projectColor: String {
        return color ?? "Light Blue"
    }
    
    var projectItems: [Item] {
        let itemsArray = items?.allObjects
        let items = itemsArray as? [Item]
        return items ?? []
    }
    
    func projectItems(using sortOrder: Item.SortOrder) -> [Item] {
        return projectItems.sorted(by: sortOrder.sortDescriptors)
    }
    
    static func newProject(managedObjectContext: NSManagedObjectContext, dataController: DataController) {
        let project = Project(context: managedObjectContext)
        project.closed = false
        project.creationDate = Date()
        dataController.save()
    }
    
    static let colors = ProjectColor.allNames
    
    enum ProjectColor: String, CaseIterable {
        case pink, purple, red, orange, gold, green, teal, lightBlue, darkBlue, midnight, darkGray, gray
        
        var asString: String {
            switch self {
            case .pink, .purple, .red, .orange, .gold, .green, .teal, .midnight, .gray:
                return self.rawValue.capitalized
            case .lightBlue:
                return "Light Blue"
            case .darkBlue:
                return "Dark Blue"
            case .darkGray:
                return "Dark Gray"
            }
        }
        
        static var allNames: [String] {
            return ProjectColor.allCases.map { color in
                color.asString
            }
        }
    }
    
    // MARK: - View helpers
    var completionAmount: Double {
        guard projectItems.isEmpty == false else {
            return 0
        }
        
        let completedItems = projectItems.filter(\.completed)
        return Double(completedItems.count) / Double(projectItems.count)
    }
    
    var accessibleLabel: LocalizedStringKey {
        // swiftlint:disable:next line_length
        return LocalizedStringKey("\(projectTitle), \(projectItems.count) items, \(completionAmount * 100, specifier: "%g")% complete")
    }
    
    static var example: Project {
        let controller = DataController.preview
        let viewContext = controller.container.viewContext
        
        let project = Project(context: viewContext)
        project.title = "Example project"
        project.detail = "This is an example Project"
        project.closed = true
        project.creationDate = Date()
        
        return project
    }
    
    // MARK: - Apple integration helpers
    var idURIString: String {
        objectID.uriRepresentation().absoluteString
    }
}
