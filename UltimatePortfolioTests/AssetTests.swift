//
//  AssetTests.swift
//  UltimatePortfolioTests
//
//  Created by Christopher Eadie on 11/03/2022.
//

import XCTest
@testable import UltimatePortfolio

class AssetTests: UPXCTestCase {
    func test_AwardsJSON_LoadsCorrectly() {
        XCTAssertFalse(Award.allAwards.isEmpty, "Failed to load awards from JSON")
    }
}
