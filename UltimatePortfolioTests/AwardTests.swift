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
    
    func test_Award_IDMatchesName() {
        for award in awards {
            XCTAssertEqual(award.id, award.name, "Award ID should always match name")
        }
    }
    
    func test_Award_NamesAreUnique() {
        for award in awards {
            XCTAssertEqual(awards.filter({ $0.name == award.name }).count, 1, "Award names should always be unique.")
        }
    }
    
    func test_Award_AchievedCountForNewUserIsNil() {
        for award in awards {
            XCTAssertFalse(dataController.hasEarned(award: award))
        }
    }
    
    func test_Award_EarnsAwardsForAddingItems() {
        // GIVEN an array or completion goals
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]
        
        // WHEN we create enough items to match the completion values
        for (index, value) in values.enumerated() {
            for _ in 0..<value {
                _ = Item(context: managedObjectContext)
            }
            
            let matches = awards.filter { award in
                award.criterion == .items && dataController.hasEarned(award: award)
            }
            
            // THEN we should have unlocked the corresponding number of awards
            XCTAssertEqual(matches.count, index + 1, "Adding \(value) items should unlock \(index + 1) awards.")
            
            dataController.deleteAll()
        }
    }
    
    func test_Award_EarnsAwardsForCompletingItems() {
        // GIVEN an array or completion goals
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]
        
        // WHEN we create and complete enough items to match the completion values
        for (index, value) in values.enumerated() {
            for _ in 0..<value {
                let item = Item(context: managedObjectContext)
                item.completed = true
            }
            
            let matches = awards.filter { award in
                award.criterion == .complete && dataController.hasEarned(award: award)
            }
            
            // THEN we should have unlocked the corresponding number of awards
            XCTAssertEqual(matches.count, index + 1, "Completing \(value) items should unlock \(index + 1) awards.")
            
            dataController.deleteAll()
        }
    }
}
