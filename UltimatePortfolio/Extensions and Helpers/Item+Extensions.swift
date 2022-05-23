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
        return detail.orEmpty
    }
    
    var itemCreationDate: Date {
        return creationDate.orToday
    }
    
    static let ckRecordType: String = "Item"
    
    enum Priority: Int, CaseIterable {
        case low = 1, medium, high
        
        var asString: String {
            var priorityString = ""
            switch self {
            case .low:
                priorityString = "Low"
            case .medium:
                priorityString = "Medium"
            case .high:
                priorityString = "High"
            }
            return NSLocalizedString(priorityString, comment: "\(priorityString) priority")
        }
    }
    
    // MARK: - View helpers
    enum SortOrder: String {
        case creationDate, optimised, title
        
        var asString: String {
            var orderTypeString = self.rawValue.capitalized
            if self == .creationDate {
                orderTypeString = "Creation Date"
            }
            return NSLocalizedString(orderTypeString, comment: "Sort order '\(self.rawValue)' name")
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
                        ascending: false
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
