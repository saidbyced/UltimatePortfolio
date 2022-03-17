//
//  ProjectTests.swift
//  UltimatePortfolioTests
//
//  Created by Christopher Eadie on 11/03/2022.
//

import CoreData
import XCTest
@testable import UltimatePortfolio

class ProjectTests: UPXCTestCase {
    func test_ProjectsAndItems_Creation() {
        // GIVEN that want 10 Projects and 100 items
        let projectTargetCount = 10
        let itemsPerProjectCount = 10
        
        // WHEN we create Projects and Items
        for _ in 0..<projectTargetCount {
            let project = Project(context: managedObjectContext)
            
            for _ in 0..<itemsPerProjectCount {
                let item = Item(context: managedObjectContext)
                item.project = project
            }
        }
        
        // THEN we should have 1o Projects and 100 Items
        XCTAssertEqual(dataController.count(for: Project.fetchRequest()), projectTargetCount)
        XCTAssertEqual(dataController.count(for: Item.fetchRequest()), (projectTargetCount * itemsPerProjectCount))
    }
    
    func test_ProjectAndItems_DeletingProjectCascadeDeletesItems() throws {
        // GIVEN some sample data
        try dataController.createSampleData()
        
        let request = NSFetchRequest<Project>(entityName: "Project")
        let projects = try managedObjectContext.fetch(request)
        
        // WHEN we delete one Project
        dataController.delete(projects[0])
        
        // THEN we should have 4 Projects and 40 Items
        XCTAssertEqual(dataController.count(for: Project.fetchRequest()), 4)
        XCTAssertEqual(dataController.count(for: Item.fetchRequest()), 40)
    }
}
