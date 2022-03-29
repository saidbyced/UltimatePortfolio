//
//  ProductView.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 29/03/2022.
//

import StoreKit
import SwiftUI

struct ProductView: View {
    @EnvironmentObject var unlockManager: UnlockManager
    let product: SKProduct
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Get Unlimited Projects")
                    .font(.headline)
                    .padding(.top, 10)
                
                Text("You can add three projects for free, or pay \(product.localizedPrice) to add unlimited projects.") // swiftlint:disable:this line_length
                
                Text("If you have already bought the unlock on another device, press Restore Purchases.")
                
                Button("Buy: \(product.localizedPrice)", action: unlock)
                    .buttonStyle(PurchaseButton())
                
                Button("Restore Purchases", action: restore)
                    .buttonStyle(PurchaseButton())
            }
            .multilineTextAlignment(.center)
        }
    }
    
    func unlock() {
        unlockManager.buy(product: product)
    }
    
    func restore() {
        unlockManager.restore()
    }
}
