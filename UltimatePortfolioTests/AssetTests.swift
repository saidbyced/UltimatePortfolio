//
//  AssetTests.swift
//  UltimatePortfolioTests
//
//  Created by Christopher Eadie on 11/03/2022.
//

import XCTest
@testable import UltimatePortfolio

class AssetTests: XCTestCase {
    func testAwardsJSONLoadsCorrectly() {
        XCTAssertFalse(Award.allAwards.isEmpty, "Failed to load awards from JSON")
    }
}
