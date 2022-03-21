//
//  AwardTests.swift
//  AwardTests
//
//  Created by Christopher Eadie on 21/03/2022.
//

import XCTest
@testable import UltimatePortfolio

class AwardTests: UPXCTestCase {
    func test_Award_Calculation() throws {
        // GIVEN a large amount of sample data and a large amount of awards
        for _ in 1...100 {
            try dataController.createSampleData()
        }
        
        let awards = Array(repeating: Award.allAwards, count: 25).joined()
        XCTAssertEqual(awards.count, 500, "Ensures awards count is constant. *** Change if new awards added.")
        
        // THEN performance should not significantly change
        measure {
            _ = awards.filter(dataController.hasEarned)
        }
    }
}
