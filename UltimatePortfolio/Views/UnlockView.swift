//
//  UnlockView.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 29/03/2022.
//

import StoreKit
import SwiftUI

struct UnlockView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var unlockManager: UnlockManager
    
    var body: some View {
        VStack {
            switch unlockManager.requestState {
            case .loaded(let product):
                ProductView(product: product)
            case .failed(_): // swiftlint:disable:this empty_enum_arguments
                Text("Sorry, there was an error loading the store. Please try again later.")
            case .loading:
                ProgressView("Loading...")
            case .purchased:
                Text("Thank you. You rock 🤘")
            case .deferred:
                Text("Thank you. Your request is pending approval but you can carry on using the app in the mean time.")
            }
        }
        .multilineTextAlignment(.center)
        .padding()
        .onReceive(unlockManager.$requestState) { requestState in
            if case .purchased = requestState {
                dismiss()
            }
        }
    }
    
    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}
