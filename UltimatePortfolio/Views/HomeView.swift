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
    @FetchRequest(entity: Project.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Project.title, ascending: true)], predicate: NSPredicate(format: "closed = false")) var projects: FetchedResults<Project>
    
    let items: FetchRequest<Item>
    
    static let tag: String = "Home"
    
    var projectRows: [GridItem] {
        [ GridItem(.fixed(100)) ]
    }
    
    init() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "completed = false")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Item.priority, ascending: false)]
        request.fetchLimit = 10
        
        items = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        projectBoxes
                            .padding([.horizontal, .top])
                    }
                    
                    VStack(alignment: .leading) {
                        itemList("Up next", for: items.wrappedValue.prefix(3))
                        
                        itemList("More to explore", for: items.wrappedValue.dropFirst(3))
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color.systemGroupedBackground)
            .navigationTitle("Home")
        }
    }
    
    var addDataButton: some View {
        Button("Add data") {
            dataController.deleteAll()
            try? dataController.createSampleData()
        }
    }
    
    var projectBoxes: some View {
        LazyHGrid(rows: projectRows) {
            ForEach(projects) { project in
                VStack(alignment: .leading) {
                    Text("\(project.projectItems.count) items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(project.projectTitle)
                        .font(.title2)
                    
                    ProgressView(value: project.completionAmount)
                        .accentColor(Color(project.projectColor))
                }
                .padding()
                .background(Color.secondarySystemGroupedBackground)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.2), radius: 5)
            }
        }
    }
    
    @ViewBuilder
    func itemList(_ title: String, for items: FetchedResults<Item>.SubSequence) -> some View {
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
                    HStack {
                        Circle()
                            .stroke(Color(item.project?.projectColor ?? Project.ProjectColor.lightBlue.asString))
                            .frame(width: 44, height: 44)
                        
                        VStack(alignment: .leading) {
                            Text(item.itemTitle)
                                .font(.title2)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if !item.itemDetail.isEmpty {
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
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
