//
//  AwardTests.swift
//  UltimatePortfolioTests
//
//  Created by Christopher Eadie on 11/03/2022.
//

import CoreData
import XCTest
@testable import UltimatePortfolio

class AwardTests: UPXCTestCase {
    let awards = Award.allAwards
    
    func testAwardIDMatchesName() {
        for award in awards {
            XCTAssertEqual(award.id, award.name, "Award ID should always match name")
        }
    }
    
    func testAwardNamesAreUnique() {
        for award in awards {
            XCTAssertEqual(awards.filter({ $0.name == award.name }).count, 1, "Award names should always be unique.")
        }
    }
    
    func testNewUserHasNoAwards() {
        for award in awards {
            XCTAssertFalse(dataController.hasEarned(award: award))
        }
    }
    
    func testAddingItemsEarnsAwards() {
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]
        
        for (index, value) in values.enumerated() {
            var items = [Item]()
            
            for _ in 0..<value {
                let item = Item(context: managedObjectContext)
                items.append(item)
            }
            
            let matches = awards.filter { award in
                award.criterion == .items && dataController.hasEarned(award: award)
            }
            
            XCTAssertEqual(matches.count, index + 1, "Adding \(value) items should unlock \(index + 1) awards.")
            
            dataController.delete(items)
        }
    }
    
    func testCompletingItemsEarnsAwards() {
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]
        
        for (index, value) in values.enumerated() {
            var items = [Item]()
            
            for _ in 0..<value {
                let item = Item(context: managedObjectContext)
                item.completed = true
                items.append(item)
            }
            
            let matches = awards.filter { award in
                award.criterion == .complete && dataController.hasEarned(award: award)
            }
            
            XCTAssertEqual(matches.count, index + 1, "Completing \(value) items should unlock \(index + 1) awards.")
            
            dataController.delete(items)
        }
    }
}
