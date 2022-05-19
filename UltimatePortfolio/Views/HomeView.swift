//
//  HomeView.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 08/02/2022.
//

import CoreData
import CoreSpotlight
import SwiftUI

struct HomeView: View {
    static let tag: String? = "Home"
    
    @StateObject var viewModel: ViewModel
    
    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            Color.systemGroupedBackground
            
            NavigationView {
                ScrollView {
                    if let item = viewModel.selectedItem {
                        NavigationLink(
                            destination: EditItemView(item: item),
                            tag: item,
                            selection: $viewModel.selectedItem,
                            label: EmptyView.init
                        )
                        .id(item)
                    }
                    
                    VStack(alignment: .leading) {
                        if viewModel.projects.isEmpty == false {
                            ProjectsSummariesView(projects: $viewModel.projects)
                        }
                        
                        VStack(alignment: .leading) {
                            ItemListView(title: "Up next", items: $viewModel.upNextItems)
                            
                            ItemListView(title: "More to explore", items: $viewModel.moreToExploreItems)
                        }
                        .padding(.horizontal)
                    }
                }
                .navigationTitle("Home")
                .toolbar {
                    Button("Add data", action: viewModel.addSampleData)
                    
//                    Button("Delete all", action: viewModel.dataController.deleteAll)
                }
                .onContinueUserActivity(CSSearchableItemActionType, perform: loadSpotlightItem)
            }
        }
    }
    
    func loadSpotlightItem(_ userActivity: NSUserActivity) {
        if let uniqueItendifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            viewModel.selectItem(with: uniqueItendifier)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var dataController: DataController = .preview
    
    static var previews: some View {
        HomeView(dataController: dataController)
    }
}
