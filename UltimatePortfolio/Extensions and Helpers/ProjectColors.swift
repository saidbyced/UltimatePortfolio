//
//  ProjectColors.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 31/03/2022.
//

import SwiftUI

enum ProjectColor: String, CaseIterable {
    case pink, purple, red, orange, gold, green, teal, lightBlue, darkBlue, midnight, darkGray, gray
    
    var asString: String {
        switch self {
        case .pink, .purple, .red, .orange, .gold, .green, .teal, .midnight, .gray:
            return self.rawValue.capitalized
        case .lightBlue:
            return "Light Blue"
        case .darkBlue:
            return "Dark Blue"
        case .darkGray:
            return "Dark Gray"
        }
    }
    
    static var allNames: [String] {
        return ProjectColor.allCases.map { $0.asString }
    }
}
