//
//  Project+Extensions.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 10/02/2022.
//

import Foundation

extension Project {
    static let colors = ProjectColor.allNames
    
    // MARK: - CoreData helpers
    var projectTitle: String {
        return title ?? "New Project"
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
    
    var projectItemsSorted: [Item] {
        return projectItems.sorted { first, second in
            if !first.completed && second.completed {
                return true
            } else if first.completed && !second.completed {
                return false
            }
            
            if first.priority > second.priority {
                return true
            } else if first.priority < second.priority {
                return false
            }
            
            return first.itemCreationDate < second.itemCreationDate
        }
    }
    
    var completionAmount: Double {
        guard !projectItems.isEmpty else {
            return 0
        }
        
        let completedItems = projectItems.filter(\.completed)
        return Double(completedItems.count) / Double(projectItems.count)
    }
    
    static var example: Project {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        let project = Project(context: viewContext)
        project.title = "Example project"
        project.detail = "This is an example Project"
        project.closed = true
        project.creationDate = Date()
        
        return project
    }
    
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
}
