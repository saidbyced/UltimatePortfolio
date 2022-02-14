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
