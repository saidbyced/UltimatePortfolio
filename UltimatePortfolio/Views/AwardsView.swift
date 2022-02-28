//
//  AwardsView.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 16/02/2022.
//

import SwiftUI

struct AwardsView: View {
    @EnvironmentObject var dataController: DataController
    @State private var selectedAward: Award = .example
    @State private var isShowingAwardDetails: Bool = false
    
    static let tag: String? = "Awards"
    
    var columns: [GridItem] {
        [ GridItem(.adaptive(minimum: 100, maximum: 100)) ]
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                awardsGrid
            }
            .navigationTitle("Awards")
        }
        .alert(isPresented: $isShowingAwardDetails) {
            .init(
                title: lockedStatusText(for: selectedAward),
                message: Text(selectedAward.description),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    var awardsGrid: some View {
        LazyVGrid(columns: columns) {
            ForEach(Award.allAwards) { award in
                Button {
                    selectedAward = award
                    isShowingAwardDetails = true
                } label: {
                    Image(systemName: award.image)
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .frame(width: 100, height: 100)
                        .foregroundColor(color(for: award))
                }
                .accessibilityLabel(lockedStatusText(for: award))
                .accessibilityHint(Text(award.description))
            }
        }
    }
    
    func lockedStatusText(for award: Award) -> Text {
        if dataController.hasEarned(award: award) {
            return Text("Unlocked: \(award.name)")
        } else {
            return Text("Locked")
        }
    }
    
    func color(for award: Award) -> Color {
        return dataController.hasEarned(award: award) ? Color(award.color) : .secondary.opacity(0.5)
    }
}

struct AwardsView_Previews: PreviewProvider {
    static var previews: some View {
        AwardsView()
    }
}
