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
    
    static let openTag: String = "Open"
    static let closedTag: String = "Closed"
    
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !showClosedProjects {
                        addProjectButton
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    sortingButton
                }
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
                        removeItems(for: project, at: indexSet)
                    }
                    
                    if !showClosedProjects {
                        Button {
                            withAnimation {
                                addNewItem(to: project)
                            }
                        } label: {
                            Label("Add New Item", systemImage: SystemImage.plus)
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    var addProjectButton: some View {
        Button {
            withAnimation {
                addProject()
            }
        } label: {
            Label("Add Project", systemImage: SystemImage.plus)
        }
    }
    
    var sortingButton: some View {
        Button {
            isShowingSortOrder.toggle()
        } label: {
            Label("Sort", systemImage: SystemImage.arrowUpArrowDown)
        }
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
    
    func addProject() {
        let project = Project(context: managedObjectContext)
        project.closed = false
        project.creationDate = Date()
        dataController.save()
    }
    
    func addNewItem(to project: Project) {
        let item = Item(context: managedObjectContext)
        item.project = project
        item.creationDate = Date()
        dataController.save()
    }
    
    func removeItems(for project: Project, at indexSet: IndexSet) {
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
