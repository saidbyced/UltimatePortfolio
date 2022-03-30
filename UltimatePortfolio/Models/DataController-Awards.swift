//
//  DataController-Awards.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 30/03/2022.
//

import CoreData
import Foundation

extension DataController {
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
        // Other cases to be handled when features created
        default:
            return false
        }
    }
}
