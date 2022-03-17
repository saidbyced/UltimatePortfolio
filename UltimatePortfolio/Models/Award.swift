//
//  Award.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 16/02/2022.
//

import Foundation

struct Award: Decodable, Identifiable {
    var id: String { name }
    let name: String
    let description: String
    let color: String
    let criterion: Criterion
    let value: Int
    let image: String
    
    static let allAwards: [Award] = Bundle.main.decode([Award].self, from: "Awards.json")
    static let example: Award = allAwards[0]
    
    enum Criterion: String, Decodable {
        case items, complete, chat, unlock
    }
}
