//
//  ProjectsView.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 08/02/2022.
//

import SwiftUI

struct ProjectsView: View {
    let showClosedProjects: Bool
    
    @EnvironmentObject var dataController: DataController
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest var projects: FetchedResults<Project>
    @State private var sortOrder: Item.SortOrder = .optimised
    @State private var isShowingSortOrder: Bool = false
    
    static let openTag: String? = "Open"
    static let closedTag: String? = "Closed"
    
    var navigationTitle: LocalizedStringKey {
        return showClosedProjects ? "Closed Projects" : "Open Projects"
    }
    
    init(showClosedProjects: Bool) {
        self.showClosedProjects = showClosedProjects
        
        _projects = FetchRequest<Project>(
            entity: Project.entity(),
            sortDescriptors: [
                NSSortDescriptor(
                    keyPath: \Project.creationDate,
                    ascending: false
                )
            ],
            predicate: NSPredicate(
                format: "closed = %d",
                showClosedProjects
            )
        )
    }
    
    var body: some View {
        NavigationView {
            Group {
                if projects.isEmpty {
                    emptyMessage
                } else {
                    projectsList
                }
            }
            .navigationTitle(navigationTitle)
            .toolbar {
                sortToolBarItem(placement: .navigationBarLeading)
                
                addToolBarItem(placement: .navigationBarTrailing)
            }
            .actionSheet(
                isPresented: $isShowingSortOrder
            ) {
                sortItemsActionSheet
            }
            
            SelectSomethingView()
        }
    }
    
    var emptyMessage: some View {
        Text("There's nothing here right now")
            .foregroundColor(.secondary)
    }
    
    var projectsList: some View {
        List {
            ForEach(projects) { project in
                Section(header: ProjectHeaderView(project: project)) {
                    ForEach(project.projectItems(using: sortOrder)) { item in
                        ItemRowView(project: project, item: item)
                    }
                    .onDelete { indexSet in
                        removeItems(from: project, at: indexSet)
                    }
                    
                    if !showClosedProjects {
                        Button(action: { addNewItem(to: project) }) {
                            Label("Add New Item", systemImage: SystemImage.plus)
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    var sortItemsActionSheet: ActionSheet {
        .init(
            title: Text("Sort items"),
            message: nil,
            buttons: [
                .default(
                    Text(Item.SortOrder.optimised.asString)
                ) {
                    sortOrder = .optimised
                },
                .default(
                    Text(Item.SortOrder.creationDate.asString)
                ) {
                    sortOrder = .creationDate
                },
                .default(
                    Text(Item.SortOrder.title.asString)
                ) {
                    sortOrder = .title
                }
            ]
        )
    }
    
    func addToolBarItem(placement: ToolbarItemPlacement) -> some ToolbarContent {
        ToolbarItem(placement: placement) {
            if !showClosedProjects {
                Button(action:  addProject) {
                    Label("Add Project", systemImage: SystemImage.plus)
                }
            }
        }
    }
    
    func sortToolBarItem(placement: ToolbarItemPlacement) -> some ToolbarContent {
        ToolbarItem(placement: placement) {
            Button(action: { isShowingSortOrder.toggle() }) {
                Label("Sort", systemImage: SystemImage.arrowUpArrowDown)
            }
        }
    }
    
    func addProject() {
        withAnimation {
            Project.newProject(managedObjectContext: managedObjectContext, dataController: dataController)
        }
    }
    
    func addNewItem(to project: Project) {
        withAnimation {
            Item.newItem(to: project, managedObjectContext: managedObjectContext, dataController: dataController)
        }
    }
    
    func removeItems(from project: Project, at indexSet: IndexSet) {
        let projectItems = project.projectItems(using: sortOrder)
        
        for index in indexSet {
            let item = projectItems[index]
            dataController.delete(item)
        }
        
        dataController.save()
    }
}

struct ProjectsView_Previews: PreviewProvider {
    static var dataController = DataController.preview
    
    static var previews: some View {
        ProjectsView(
            showClosedProjects: false
        )
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
