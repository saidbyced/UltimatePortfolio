//
//  SKProduct+Extensions.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 29/03/2022.
//

import StoreKit

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        
        guard let returnString = formatter.string(from: price) else {
            return ""
        }
        
        return returnString
    }
}
