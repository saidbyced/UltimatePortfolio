//
//  AwardsViewModel.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 21/03/2022.
//

import Foundation

extension AwardsView {
    class ViewModel: ObservableObject {
        let dataController: DataController
        
        init(dataController: DataController) {
            self.dataController = dataController
        }
        
        func hasEarnedAward(for award: Award) -> Bool {
            return dataController.hasEarned(award: award)
        }
        
        func color(for award: Award) -> String? {
            return hasEarnedAward(for: award) ? award.color : nil
        }
        
        func statusText(for award: Award) -> String {
            return hasEarnedAward(for: award) ? "Unlocked: \(award.name)" : "Locked"
        }
    }
}
