//
//  InAppPurchaseProductIdentifiers.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 29/03/2022.
//

import Foundation

enum IAPProductIdentifier: String {
    private static let base: String = "com.ChristopherEadie.UltimatePortfolio."
    
    case unlock
    
    var id: String {
        return IAPProductIdentifier.base + self.rawValue
    }
}
