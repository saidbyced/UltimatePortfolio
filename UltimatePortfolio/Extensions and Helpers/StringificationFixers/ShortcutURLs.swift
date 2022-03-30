//
//  ShortcutURLs.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 30/03/2022.
//

import Foundation

enum ShortcutURL: String {
    static let base: String = "com.christophereadie.ultimateportfolio."
    
    case newProject = "newProject"
    
    var activityType: String {
        return ShortcutURL.base + self.rawValue
    }
    
    var title: String {
        switch self {
        case .newProject:
            return "New Project"
        }
    }
}
