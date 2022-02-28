//
//  ItemRowView.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 10/02/2022.
//

import SwiftUI

struct ItemRowView: View {
    @ObservedObject var project: Project
    @ObservedObject var item: Item
    
    var body: some View {
        NavigationLink(destination: EditItemView(item: item)) {
            Label {
                Text(item.itemTitle)
            } icon: {
                icon
            }
        }
        .accessibilityLabel(label)
    }
    
    var label: Text {
        if item.completed {
            return Text("\(item.itemTitle), completed.")
        } else if item.priority == 3 {
            return Text("\(item.itemTitle), high priority.")
        } else {
            return Text("\(item.itemTitle)")
        }
    }
    
    var icon: some View {
        if item.completed {
            return Image(systemName: SystemImage.checkmarkCircle)
                .foregroundColor(Color(project.projectColor))
        } else if item.priority == 3 {
            return Image(systemName: SystemImage.exclamationmarkTriangle)
                .foregroundColor(Color(project.projectColor))
        } else {
            return Image(systemName: SystemImage.checkmarkCircle)
                .foregroundColor(.clear)
        }
    }
}

struct ItemRowView_Previews: PreviewProvider {
    static let item: Item = Item.example
    static let project: Project = Project.example
    
    static var previews: some View {
        ItemRowView(project: project, item: item)
    }
}
