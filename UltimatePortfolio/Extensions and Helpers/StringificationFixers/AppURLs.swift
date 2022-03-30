//
//  AppURLs.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 30/03/2022.
//

import Foundation

enum AppURL: String {
    private static let base: String = "ultimateportfolio://"
    
    case newProject
    
    var url: URL {
        let urlString = AppURL.base + self.rawValue
        return URL(string: urlString)!
    }
}
