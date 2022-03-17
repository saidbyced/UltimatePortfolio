//
//  DevelopmentTests.swift
//  UltimatePortfolioTests
//
//  Created by Christopher Eadie on 17/03/2022.
//

import CoreData
import XCTest
@testable import UltimatePortfolio

class DevelopmentTests: UPXCTestCase {
    func test_SampleData_CreationWorks() throws {
        // WHEN we create sample data
        try dataController.createSampleData()
        
        // THEN we should have 5 Projects and 50 Items
        XCTAssertEqual(dataController.count(for: Project.fetchRequest()), 5, "There should be 5 sample projects.")
        XCTAssertEqual(dataController.count(for: Item.fetchRequest()), 50, "There should be 50 sample items.")
    }
    
    func test_DeleteAll_FunctionsCorrectly() throws {
        // GIVEN sample data
        try dataController.createSampleData()
        
        // WHEN we delete all the data
        dataController.deleteAll()
        
        // THEN we should have no Projects or Items left
        XCTAssertEqual(dataController.count(for: Project.fetchRequest()), 0, "deleteAll() should leave 0 projects.")
        XCTAssertEqual(dataController.count(for: Item.fetchRequest()), 0, "deleteAll() should leave 0 items.")
    }
    
    func test_ProjectExample_IsClosed() {
        // WHEN we create an example Project
        let project = Project.example
        
        // THEN its status should be closed
        XCTAssertEqual(project.closed, true, "The example project should be closed.")
    }
    
    func test_ItemExample_IsHighPriority() {
        // WHEN we create an example Item
        let item = Item.example
        
        // THEN its priority should be high
        XCTAssertEqual(item.priority, 3, "The example item should be high priority ")
    }
}
