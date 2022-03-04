//
//  HomeView.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 08/02/2022.
//

import CoreData
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dataController: DataController
    @FetchRequest(
        entity: Project.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Project.title, ascending: true)
        ],
        predicate: NSPredicate(format: "closed = false")
    ) var projects: FetchedResults<Project>
    
    let items: FetchRequest<Item>
    
    static let tag: String? = "Home"
    
    init() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let completedPredicate = NSPredicate(format: "completed = false")
        let openProjectPredicate = NSPredicate(format: "project.closed = false")
        let compoundPredicate = NSCompoundPredicate(
            type: .and,
            subpredicates: [completedPredicate, openProjectPredicate]
        )
        let sortdescriptor = NSSortDescriptor(keyPath: \Item.priority, ascending: false)
        
        request.predicate = compoundPredicate
        request.sortDescriptors = [sortdescriptor]
        request.fetchLimit = 10
        
        items = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {
        ZStack {
            Color.systemGroupedBackground
            
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    if !projects.isEmpty {
                        ProjectsSummariesView(projects: projects)
                    }
                    
                    VStack(alignment: .leading) {
                        ItemListView(title: "Up next", items: items.wrappedValue.prefix(3))
                        
                        ItemListView(title: "More to explore", items: items.wrappedValue.dropFirst(3))
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Home")
            .toolbar {
                addDataButton
            }
        }
        }
    }
    
    // FIXME: remove prior to any production ship
    var addDataButton: some View {
        Button("Add data") {
            dataController.deleteAll()
            try? dataController.createSampleData()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
