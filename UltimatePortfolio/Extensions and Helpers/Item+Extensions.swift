//
//  Item+Extensions.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 10/02/2022.
//

import CoreData
import Foundation

extension Item {
    // MARK: - CoreData helpers
    var itemTitle: String {
        return title ?? NSLocalizedString("New Item", comment: "Name for new Item")
    }
    
    var itemDetail: String {
        return detail ?? ""
    }
    
    var itemCreationDate: Date {
        return creationDate ?? Date()
    }
    
    enum Priority: Int, CaseIterable {
        case low = 1, medium, high
        
        var asString: String {
            switch self {
            case .low:
                return NSLocalizedString("Low", comment: "Low priority")
            case .medium:
                return NSLocalizedString("Medium", comment: "Medium priority")
            case .high:
                return NSLocalizedString("High", comment: "High priority")
            }
        }
    }
    
    // MARK: - View helpers
    enum SortOrder {
        case creationDate, optimised, title
        
        var asString: String {
            switch self {
            case .creationDate:
                return NSLocalizedString("Creation Date", comment: "Sort order 'creationDate' name")
            case .optimised:
                return NSLocalizedString("Optimised", comment: "Sort order 'optimised' name")
            case .title:
                return NSLocalizedString("Title", comment: "Sort order 'title' name")
            }
        }
        
        var sortDescriptors: [NSSortDescriptor] {
            switch self {
            case .creationDate:
                return [
                    NSSortDescriptor(
                        keyPath: \Item.creationDate,
                        ascending: true
                    )
                ]
            case .title:
                return [
                    NSSortDescriptor(
                        keyPath: \Item.itemTitle,
                        ascending: true
                    )
                ]
            case .optimised:
                return [
                    NSSortDescriptor(
                        keyPath: \Item.completed,
                        ascending: true
                    ),
                    NSSortDescriptor(
                        keyPath: \Item.priority,
                        ascending: true
                    )
                ]
            }
        }
    }
    
    static var example: Item {
        let controller = DataController.preview
        let viewContext = controller.container.viewContext
        
        let item = Item(context: viewContext)
        item.title = "Example Item"
        item.detail = "This is an example Item"
        item.priority = 3
        item.creationDate = Date()
        
        return item
    }
    
    // MARK: - Apple integration helpers
    var idURIString: String {
        objectID.uriRepresentation().absoluteString
    }
}
