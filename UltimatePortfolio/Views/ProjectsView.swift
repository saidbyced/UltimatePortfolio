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
            List {
                ForEach(projects) { project in
                    Section(header: ProjectHeaderView(project: project)) {
                        ForEach(project.projectItems(using: sortOrder)) { item in
                            ItemRowView(item: item)
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
            .navigationTitle(showClosedProjects ? "Closed Projects" : "Open projects")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !showClosedProjects {
                        Button {
                            withAnimation {
                                addProject()
                            }
                        } label: {
                            Label("Add Project", systemImage: SystemImage.plus)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isShowingSortOrder.toggle()
                    } label: {
                        Label("Sort", systemImage: SystemImage.arrowUpArrowDown)
                    }

                }
            }
            .actionSheet(
                isPresented: $isShowingSortOrder
            ) {
                ActionSheet(
                    title: Text("Sort items"),
                    message: nil,
                    buttons: [
                        .default(
                            Text("Optimised")
                        ) {
                            sortOrder = .optimised
                        },
                        .default(
                            Text("Creation Date")
                        ) {
                            sortOrder = .creationDate
                        },
                        .default(
                            Text("Title")
                        ) {
                            sortOrder = .title
                        }
                    ]
                )
            }
        }
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
        let projectItems = project.projectItems
        
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
