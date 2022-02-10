//
//  Binding+Extensions.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 10/02/2022.
//

import SwiftUI

extension Binding {
    func onChange(_ handler: @escaping () -> Void) -> Binding<Value> {
        Binding(
            get: {
                self.wrappedValue
            },
            set: { newValue in
                self.wrappedValue = newValue
                handler()
            }
        )
    }
}
