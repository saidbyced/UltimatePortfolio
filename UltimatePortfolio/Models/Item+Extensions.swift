//
//  Item+Extensions.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 10/02/2022.
//

import Foundation

extension Item {
    // MARK: - CoreData helpers
    var itemTitle: String {
        return title ?? "New Item"
    }
    
    var itemDetail: String {
        return detail ?? ""
    }
    
    var itemCreationDate: Date {
        return creationDate ?? Date()
    }
    
    // MARK: - View helpers
    enum SortOrder {
        case creationDate, optimised, title
        
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
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        let item = Item(context: viewContext)
        item.title = "Example Item"
        item.detail = "This is an example Item"
        item.priority = 3
        item.creationDate = Date()
        
        return item
    }
}
