//
//  ItemListView.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 01/03/2022.
//

import SwiftUI

struct ItemListView: View {
    let title: LocalizedStringKey
    @Binding var items: ArraySlice<Item>
    
    var body: some View {
        if items.isEmpty {
            EmptyView()
        } else {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.top)
            
            ForEach(items) { item in
                NavigationLink {
                    EditItemView(item: item)
                } label: {
                    navigationLabel(for: item)
                }
            }
        }
    }
    
    func navigationLabel(for item: Item) -> some View {
        HStack {
            Circle()
                .stroke(Color(item.project?.projectColor ?? ProjectColor.lightBlue.asString))
                .frame(width: 44, height: 44)
            
            VStack(alignment: .leading) {
                Text(item.itemTitle)
                    .font(.title2)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if item.itemDetail.isEmpty == false {
                    Text(item.itemDetail)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.secondarySystemGroupedBackground)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.2), radius: 5)
    }
}
