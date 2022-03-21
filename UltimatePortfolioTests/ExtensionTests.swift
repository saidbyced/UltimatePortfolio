//
//  ExtensionTests.swift
//  UltimatePortfolioTests
//
//  Created by Christopher Eadie on 17/03/2022.
//

import SwiftUI
import XCTest
@testable import UltimatePortfolio

class ExtensionTests: XCTestCase {
    let testBundle = Bundle(for: ExtensionTests.self)
    
    func test_Sequence_KeyPathSortingBySelf_Works() {
        // GIVEN an un-ordered array of Integers
        let items = [1, 5, 3, 2, 4]
        
        // WHEN they are sorted
        let sortedItems = items.sorted(by: \.self)
        
        // THEN they should be in ascending order
        XCTAssertEqual(sortedItems, [1, 2, 3, 4, 5], "The sorted numbers must be ascending.")
    }
    
    func test_Sequence_KeyPathSortingByCustom_Works() {
        // GIVEN an un-ordered array of a custom Struct
        struct ExampleStruct: Equatable {
            let value: String
        }
        
        let example1 = ExampleStruct(value: "a")
        let example2 = ExampleStruct(value: "b")
        let example3 = ExampleStruct(value: "c")
        let array = [example1, example3, example2]
        
        // WHEN we sort them with a reverse order function
        let sortedItems = array.sorted(by: \.value) { $0 > $1 }
        
        // THEN they should be in reverse order
        XCTAssertEqual(sortedItems, [example3, example2, example1], "Reverse sorting should yield c, b, a.")
    }
    
    func test_Bundle_DecodingAwards_Works() {
        let awards = Bundle.main.decode([Award].self, from: "Awards.json")
        XCTAssertFalse(awards.isEmpty, "Decoding Awards.json should yield a non-empty array.")
    }
    
    func test_Bundle_DecodingString_Works() {
        let data = testBundle.decode(String.self, from: "DecodableString.json")
        let correctString = "The rain in Spain falls mainly on the Spaniards."
        XCTAssertEqual(data, correctString, "Decoding DecodableString.json should match the file contents.")
    }
    
    func test_Bundle_DecodingDictionary_Works() {
        let data = testBundle.decode([String: Int].self, from: "DecodableDictionary.json")
        XCTAssertEqual(data.count, 3, "Decoding DecodableDictionary.json should yield 3 values.")
        XCTAssertEqual(data["One"], 1, "Decoded dictionary should contain Int to String mappings.")
    }
    
    func test_Binding_OnChange_CallsFunction() {
        // GIVEN a binding and function to run
        var onChangeFunctionRun = false
        
        func exampleFunctionToCall() {
            onChangeFunctionRun = true
        }
        
        var storedValue = ""
        
        let binding = Binding(
            get: { storedValue },
            set: { newValue in
                storedValue = newValue
            }
        )
        
        let changedBinding = binding.onChange(exampleFunctionToCall)
        
        // WHEN that binding is changed
        changedBinding.wrappedValue = "New value"
        
        // THEN the function should run
        XCTAssertTrue(onChangeFunctionRun, "The onChange() function must be run when the binding is changed.")
    }
}
