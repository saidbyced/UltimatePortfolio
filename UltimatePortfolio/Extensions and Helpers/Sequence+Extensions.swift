//
//  Sequence+Extensions.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 14/02/2022.
//

import Foundation

extension Sequence {
    func sorted<Value>(
        by keyPath: KeyPath<Element, Value>,
        using areInIncreasingOrder: (Value, Value) throws -> Bool
    ) rethrows -> [Element] {
        try self.sorted {
            try areInIncreasingOrder($0[keyPath: keyPath], $1[keyPath: keyPath])
        }
    }
    
    func sorted<Value: Comparable>(
        by keyPath: KeyPath<Element, Value>,
        ascending: Bool = true
    ) -> [Element] {
        return self.sorted(by: keyPath, using: ascending ? (<) : (>))
    }
    
    func sorted(
        by sortDescriptor: NSSortDescriptor,
        as comparisonResult: ComparisonResult = .orderedAscending
    ) -> [Element] {
        self.sorted {
            sortDescriptor.compare($0, to: $1) == comparisonResult
        }
    }
    
    func sorted(
        by sortDescriptors: [NSSortDescriptor],
        ascending: Bool = true
    ) -> [Element] {
        self.sorted {
            for descriptor in sortDescriptors {
                switch descriptor.compare($0, to: $1) {
                case .orderedAscending:
                    return ascending
                case .orderedDescending:
                    return !ascending
                case .orderedSame:
                    continue
                }
            }
            
            return false
        }
    }
}
