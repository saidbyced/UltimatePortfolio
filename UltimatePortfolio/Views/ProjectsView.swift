//
//  ProjectsView.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 08/02/2022.
//

import SwiftUI

struct ProjectsView: View {
    let showClosedProjects: Bool
    
    @FetchRequest var projects: FetchedResults<Project>
    @EnvironmentObject var dataController: DataController
    @Environment(\.managedObjectContext) var managedObjectContext
    
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
                        ForEach(project.projectItems) { item in
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
