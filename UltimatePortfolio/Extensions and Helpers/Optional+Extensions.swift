//
//  Optional+Extensions.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 06/04/2022.
//

import Foundation

extension Optional where Wrapped == String {
    var orEmpty: String {
        return self ?? ""
    }
    
    func orString(_ string: String) -> String {
        return self ?? ""
    }
}

extension Optional where Wrapped == Date {
    var orToday: Date {
        return self ?? Date()
    }
}
