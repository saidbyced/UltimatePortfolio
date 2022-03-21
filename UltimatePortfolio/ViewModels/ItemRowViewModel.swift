//
//  ItemRowViewModel.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 21/03/2022.
//

import Foundation

extension ItemRowView {
    class ViewModel: ObservableObject {
        @Published var project: Project
        @Published var item: Item
        
        var itemTitle: String {
            return item.itemTitle
        }
        
        var accessibilityLabel: String {
            if item.completed {
                return "\(item.itemTitle), completed."
            } else if item.priority == 3 {
                return "\(item.itemTitle), high priority."
            } else {
                return "\(item.itemTitle)"
            }
        }
        
        var iconName: String {
            if item.completed {
                return SystemImage.checkmarkCircle
            } else if item.priority == 3 {
                return SystemImage.exclamationmarkTriangle
            } else {
                return SystemImage.checkmarkCircle
            }
        }
        
        var iconColor: String? {
            if item.completed || item.priority == 3 {
                return project.projectColor
            } else {
                return nil
            }
        }
        
        init(project: Project, item: Item) {
            self.project = project
            self.item = item
        }
    }
}
