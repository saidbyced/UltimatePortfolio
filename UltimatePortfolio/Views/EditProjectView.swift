//
//  EditProjectView.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 11/02/2022.
//

import SwiftUI

struct EditProjectView: View {
    let project: Project
    
    @EnvironmentObject var dataController: DataController
    @Environment(\.presentationMode) var presentationMode
    @State private var title: String
    @State private var detail: String
    @State private var color: String
    @State private var isShowingDeleteAlert: Bool = false
    
    let colorColumns = [
        GridItem(.adaptive(minimum: 44))
    ]
    
    init(project: Project) {
        self.project = project
        
        _title = State(wrappedValue: project.projectTitle)
        _detail = State(wrappedValue: project.projectDetail)
        _color = State(wrappedValue: project.projectColor)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Basic settings")) {
                TextField("Project name", text: $title.onChange(update))
                
                TextField("Description of this project", text: $detail.onChange(update))
            }
            
            Section(header: Text("Custom project colour")) {
                LazyVGrid(columns: colorColumns) {
                    ForEach(Project.colors, id: \.self) { item in
                        ZStack {
                            Color(item)
                                .aspectRatio(1, contentMode: .fit)
                            
                            if item == color {
                                Image(systemName: SystemImage.checkmarkCircle)
                                    .foregroundColor(.white)
                                    .font(.largeTitle)
                            }
                        }
                        .onTapGesture {
                            color = item
                            update()
                        }
                    }
                }
                .padding(.vertical)
            }
            
            Section(footer: Text("Closing a project moves it from the Open to Closed tab; deleting it removes the project entirely.")) {
                Button(project.closed ? "Reopen this project" : "Close this project") {
                    project.closed.toggle()
                    update()
                }
                
                Button("Delete this project") {
                    isShowingDeleteAlert.toggle()
                }
                .accentColor(.red)
            }
        }
        .navigationTitle("Edit project")
        .onDisappear(perform: dataController.save)
        .alert(isPresented: $isShowingDeleteAlert) {
            Alert(
                title: Text("Delete Project?"),
                message: Text("Are you sure you want to delete this project? You will also delete all the items it contains."),
                primaryButton: .default(
                    Text("Delete"),
                    action: delete
                ),
                secondaryButton: .cancel()
            )
        }
    }
    
    func update() {
        project.title = title
        project.detail = detail
        project.color = color
    }
    
    func delete() {
        dataController.delete(project)
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditProjectView_Previews: PreviewProvider {
    static let project = Project.example
    
    static var previews: some View {
        EditProjectView(project: project)
    }
}
