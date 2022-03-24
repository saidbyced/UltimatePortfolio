//
//  EditItemView.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 10/02/2022.
//

import SwiftUI

struct EditItemView: View {
    @ObservedObject var item: Item
    
    @EnvironmentObject var dataController: DataController
    
    @State private var title: String
    @State private var detail: String
    @State private var priority: Int
    @State private var completed: Bool
    
    init(item: Item) {
        self.item = item
        _title = State(wrappedValue: item.itemTitle)
        _detail = State(wrappedValue: item.itemDetail)
        _priority = State(wrappedValue: Int(item.priority))
        _completed = State(wrappedValue: item.completed)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Basic settings")) {
                TextField("Item name", text: $title.onChange(update))
                
                TextField("Description", text: $detail.onChange(update))
            }
            
            Section(header: Text("Priority")) {
                Picker("Priority", selection: $priority.onChange(update)) {
                    ForEach(Item.Priority.allCases, id: \.rawValue) { priority in
                        Text(priority.asString)
                            .tag(priority.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Section {
                Toggle("Mark completed", isOn: $completed.onChange(update))
            }
        }
        .navigationTitle("Edit Item")
        .onDisappear(perform: save)
    }
    
    func update() {
        item.project?.objectWillChange.send()
        
        item.title = title
        item.detail = detail
        item.priority = Int16(priority)
        item.completed = completed
    }
    
    func save() {
        update()
        dataController.update(item)
    }
}

struct EditItemView_Previews: PreviewProvider {
    static let item: Item = Item.example
    
    static var previews: some View {
        EditItemView(item: item)
    }
}
