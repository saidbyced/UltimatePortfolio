//
//  ReviewProvider.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 05/04/2022.
//

import StoreKit

extension DataController {
    /// Shows App Store review if conditions met
    func appLaunched() {
        guard count(for: Project.fetchRequest()) >= 5 else { return }
        
        let allScenes = UIApplication.shared.connectedScenes
        let scene = allScenes.first { $0.activationState == .foregroundActive }
        
        if let windowScene = scene as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
