//
//  Project+Extensions.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 10/02/2022.
//

import CloudKit
import CoreData
import SwiftUI

extension Project {
    // MARK: - CoreData helpers
    var projectTitle: String {
        return title ?? NSLocalizedString("New Project", comment: "Name for new Project")
    }
    
    var projectTitleForWidget: String {
        return title.orEmpty
    }
    
    var projectDetail: String {
        return detail.orEmpty
    }
    
    var projectColor: String {
        return color.orString("Light Blue")
    }
    
    var projectItems: [Item] {
        let itemsArray = items?.allObjects
        let items = itemsArray as? [Item]
        return items ?? []
    }
    
    func projectItems(using sortOrder: Item.SortOrder = .optimised) -> [Item] {
        return projectItems.sorted(by: sortOrder.sortDescriptors)
    }
    
    func prepareCloudRecords() -> [CKRecord] {
        let parentName = objectID.uriRepresentation().absoluteString
        let parentID = CKRecord.ID(recordName: parentName)
        let parent = CKRecord(recordType: "Project", recordID: parentID)
        parent["title"] = projectTitle
        parent["detail"] = projectDetail
        parent["owner"] = "saidByCed"
        parent["closed"] = closed
        
        var records = projectItems().map { item -> CKRecord in
            let childName = item.objectID.uriRepresentation().absoluteString
            let childID = CKRecord.ID(recordName: childName)
            let child = CKRecord(recordType: "Item", recordID: childID)
            child["title"] = item.itemTitle
            child["detail"] = item.itemDetail
            child["completed"] = item.completed
            child["project"] = CKRecord.Reference(recordID: parentID, action: .deleteSelf)
            return child
        }
        
        records.append(parent)
        return records
    }
    
    func pushToICloud() {
        let recordsToSave = prepareCloudRecords()
        let operation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: nil)
        operation.savePolicy = .allKeys
        operation.modifyRecordsCompletionBlock = { _, _, error in
            if let error = error {
                print("Error passing data to iCloud: \(error.localizedDescription)")
            }
        }
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    static let colors = ProjectColor.allNames
    
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
}
