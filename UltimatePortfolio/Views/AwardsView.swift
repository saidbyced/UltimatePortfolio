//
//  AwardsView.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 16/02/2022.
//

import SwiftUI

struct AwardsView: View {
    static let tag: String? = "Awards"
    
    @StateObject var viewModel: ViewModel
    @State private var selectedAward: Award = .example
    @State private var isShowingAwardDetails: Bool = false
    
    var columns: [GridItem] {
        [ GridItem(.adaptive(minimum: 100, maximum: 100)) ]
    }
    
    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                awardsGrid
            }
            .navigationTitle("Awards")
        }
        .alert(isPresented: $isShowingAwardDetails) {
            Alert(
                title: Text(viewModel.statusText(for: selectedAward)),
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
                        .foregroundColor(viewModel.color(for: award).map { Color($0) } ?? .secondary.opacity(0.5))
                }
                .accessibilityLabel(viewModel.statusText(for: award))
                .accessibilityHint(Text(award.description))
            }
        }
    }
}

struct AwardsView_Previews: PreviewProvider {
    static var dataController = DataController.preview
    
    static var previews: some View {
        AwardsView(dataController: dataController)
    }
}
