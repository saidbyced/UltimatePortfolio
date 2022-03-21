//
//  ProjectsView.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 08/02/2022.
//

import SwiftUI

struct ProjectsView: View {
    static let openTag: String? = "Open"
    static let closedTag: String? = "Closed"
    
    @StateObject var viewModel: ViewModel
    @State private var isShowingSortOrder: Bool = false
    
    init(dataController: DataController, showClosedProjects: Bool) {
        let viewModel = ViewModel(dataController: dataController, showClosedProjects: showClosedProjects)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var navigationTitle: LocalizedStringKey {
        return viewModel.showClosedProjects ? "Closed Projects" : "Open Projects"
    }
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.projects.isEmpty {
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
            ForEach(viewModel.projects) { project in
                Section(header: ProjectHeaderView(project: project)) {
                    ForEach(project.projectItems(using: viewModel.sortOrder)) { item in
                        ItemRowView(project: project, item: item)
                    }
                    .onDelete { indexSet in
                        viewModel.removeItems(from: project, at: indexSet)
                    }
                    
                    if !viewModel.showClosedProjects {
                        Button {
                            withAnimation {
                                viewModel.addNewItem(to: project)
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
    
    var sortItemsActionSheet: ActionSheet {
        .init(
            title: Text("Sort items"),
            message: nil,
            buttons: [
                .default(
                    Text(Item.SortOrder.optimised.asString)
                ) {
                    viewModel.sortOrder = .optimised
                },
                .default(
                    Text(Item.SortOrder.creationDate.asString)
                ) {
                    viewModel.sortOrder = .creationDate
                },
                .default(
                    Text(Item.SortOrder.title.asString)
                ) {
                    viewModel.sortOrder = .title
                }
            ]
        )
    }
    
    func addToolBarItem(placement: ToolbarItemPlacement) -> some ToolbarContent {
        ToolbarItem(placement: placement) {
            if !viewModel.showClosedProjects {
                Button {
                    withAnimation {
                        viewModel.addProject()
                    }
                } label: {
                    Label("Add Project", systemImage: SystemImage.plus)
                }
            }
        }
    }
    
    func sortToolBarItem(placement: ToolbarItemPlacement) -> some ToolbarContent {
        ToolbarItem(placement: placement) {
            // swiftlint:disable:next multiple_closures_with_trailing_closure
            Button(action: { isShowingSortOrder.toggle() }) {
                Label("Sort", systemImage: SystemImage.arrowUpArrowDown)
            }
        }
    }
}

struct ProjectsView_Previews: PreviewProvider {
    static var dataController = DataController.preview

    static var previews: some View {
        ProjectsView(dataController: dataController, showClosedProjects: false)
    }
}
