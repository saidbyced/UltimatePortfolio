//
//  ItemRowView.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 10/02/2022.
//

import SwiftUI

struct ItemRowView: View {
    @StateObject var viewModel: ViewModel
    @ObservedObject var item: Item
    
    init(project: Project, item: Item) {
        let viewModel = ViewModel(project: project, item: item)
        _viewModel = StateObject(wrappedValue: viewModel)
        
        self.item = item
    }
    
    var body: some View {
        NavigationLink(destination: EditItemView(item: viewModel.item)) {
            Label {
                Text(item.itemTitle)
            } icon: {
                Image(systemName: viewModel.iconName)
                    .foregroundColor( viewModel.iconColor.map { Color($0) } ?? .clear)
            }
        }
        .accessibilityLabel(viewModel.accessibilityLabel)
    }
}

struct ItemRowView_Previews: PreviewProvider {
    static let item: Item = Item.example
    static let project: Project = Project.example
    
    static var previews: some View {
        ItemRowView(project: project, item: item)
    }
}
