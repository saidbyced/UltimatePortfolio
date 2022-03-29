//
//  UltimatePortfolioUITests.swift
//  UltimatePortfolioUITests
//
//  Created by Christopher Eadie on 21/03/2022.
//

import XCTest

class UltimatePortfolioUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = [CLArgument.enableTesting]
        app.launch()
    }
    
    func openOpenTabAndTest() {
        app.buttons["Open"].tap()
        XCTAssertEqual(app.tables.cells.count, 0, "There should be no initial list rows.")
    }
    
    func addProjectsAndTest(count: Int) {
        for tapCount in 1...count {
            app.buttons["Add Project"].tap()
            
            let errorMessage = "There should be \(tapCount) list row(s) after adding a Project."
            XCTAssertEqual(app.tables.cells.count, tapCount, errorMessage)
        }
    }
    
    func addItemsAndTest(count: Int, projectCount: Int = 1) {
        for tapCount in 1...count {
            app.buttons["Add New Item"].tap()
            
            let errorMessage = "There should be \(tapCount + projectCount) list rows after adding an Item."
            XCTAssertEqual(app.tables.cells.count, (tapCount + projectCount), errorMessage)
        }
    }
    
    func test_App_TabsCount_Correct() throws {
        XCTAssertEqual(app.tabBars.buttons.count, 4, "There should be 4 tabs in the app.")
    }
    
    func test_OpenTab_AddingProjects_InsertsRows() {
        openOpenTabAndTest()
        addProjectsAndTest(count: 5)
    }
    
    func test_OpenTab_AddingItems_InsertsRows() {
        openOpenTabAndTest()
        addProjectsAndTest(count: 1)
        addItemsAndTest(count: 1)
    }
    
    func test_ProjectDetail_Editing_UpdatesCorrectly() {
        openOpenTabAndTest()
        addProjectsAndTest(count: 1)
        
        app.buttons["edit project"].tap()
        app.textFields["Project name"].tap()
        
        app.typeText(" 2")
        
        app.buttons["Open Projects"].tap()
        
        let errorMessage = "The new Project name should be visible in the list."
        XCTAssertTrue(app.staticTexts["New Project 2"].exists, errorMessage)
    }
    
    func test_ItemDetail_Editing_UpdatesCorrectly() {
        openOpenTabAndTest()
        addProjectsAndTest(count: 1)
        addItemsAndTest(count: 1)
        
        app.buttons["New Item"].tap()
        app.textFields["Item name"].tap()
        
        app.typeText(" 2")
        
        app.buttons["Open Projects"].tap()
        
        let errorMessage = "The new Item name should be visible in the list."
        XCTAssertTrue(app.staticTexts["New Item 2"].exists, errorMessage)
    }
    
    func test_Awards_TappingEach_ShowsLocked() {
        app.buttons["Awards"].tap()
        
        for award in app.scrollViews.buttons.allElementsBoundByIndex {
            award.tap()
            
            let errorMessage = "There should be a locked alert for \(award.title)."
            XCTAssertTrue(app.alerts["Locked"].exists, errorMessage)
            
            // While XCUITest automatically taps "OK" alert buttons, directly specifying a tap speeds up the test
            app.buttons["OK"].tap()
        }
    }
}

extension UltimatePortfolioUITests {
    func typeLetters(of string: String, for app: XCUIApplication) {
        for letter in string {
            app.keys[String(letter)].tap()
        }
    }
}
