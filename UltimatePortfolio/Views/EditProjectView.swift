//
//  EditProjectView.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 11/02/2022.
//

import CoreHaptics
import SwiftUI

struct EditProjectView: View {
    @ObservedObject var project: Project
    
    @EnvironmentObject var dataController: DataController
    @Environment(\.presentationMode) var presentationMode
    @State private var title: String
    @State private var detail: String
    @State private var color: String
    @State private var remindMe: Bool
    @State private var reminderTime: Date
    
    @State private var isShowingDeleteAlert: Bool = false
    @State private var isShowingNCFailureAlert: Bool = false
    
    @State private var hapticEngine: CHHapticEngine? = try? CHHapticEngine()
    
    let colorColumns = [
        GridItem(.adaptive(minimum: 44))
    ]
    
    init(project: Project) {
        self.project = project
        
        _title = State(wrappedValue: project.projectTitle)
        _detail = State(wrappedValue: project.projectDetail)
        _color = State(wrappedValue: project.projectColor)
        
        if let projectReminderTime = project.reminderTime {
            _remindMe = State(wrappedValue: true)
            _reminderTime = State(wrappedValue: projectReminderTime)
        } else {
            _remindMe = State(wrappedValue: false)
            _reminderTime = State(wrappedValue: Date())
        }
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
                        customColorButton(for: item)
                    }
                }
                .padding(.vertical)
            }
            
            Section(header: Text("Project reminders")) {
                Toggle("Show reminders", isOn: $remindMe.animation().onChange(update))
                    .alert(isPresented: $isShowingNCFailureAlert, content: nCFailureAlert)
                
                if remindMe {
                    DatePicker(
                        "Daily reminder time",
                        selection: $reminderTime.onChange(update),
                        displayedComponents: .hourAndMinute
                    )
                }
            }
            
            Section(
                footer: Text("Closing a project moves it from the Open to Closed tab; deleting it removes the project entirely.") // swiftlint:disable:this line_length
            ) {
                Button(project.closed ? "Reopen this project" : "Close this project", action: toggleClosed)
                
                Button("Delete this project") {
                    isShowingDeleteAlert.toggle()
                }
                .accentColor(.red)
            }
        }
        .navigationTitle("Edit project")
        .toolbar {
            Button(action: project.pushToICloud) {
                Label("Upload to iCloud", image: SystemImage.iCloudAndArrowUp)
            }
        }
        .onDisappear(perform: dataController.save)
        .alert(isPresented: $isShowingDeleteAlert, content: deleteAlert)
    }
    
    func customColorButton(for item: String) -> some View {
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
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(accessibilityTrait(for: item))
        .accessibilityLabel(LocalizedStringKey(item))
    }
    
    func deleteAlert() -> Alert {
        return Alert(
            title: Text("Delete Project?"),
            message: Text("Are you sure you want to delete this project? You will also delete all the items it contains."), // swiftlint:disable:this line_length
            primaryButton: .default(
                Text("Delete"),
                action: delete
            ),
            secondaryButton: .cancel()
        )
    }
    
    func nCFailureAlert() -> Alert {
        return Alert(
            title: Text("Oops!"),
            message: Text("There was a problem; please check you have notifications enabled."),
            primaryButton: .default(
                Text("Open Settings"),
                action: showAppSettings
            ),
            secondaryButton: .cancel()
        )
    }
    
    func update() {
        project.title = title
        project.detail = detail
        project.color = color
        
        if remindMe {
            project.reminderTime = reminderTime
            
            dataController.addReminders(for: project) { success in
                if success == false {
                    project.reminderTime = nil
                    remindMe = false
                    isShowingNCFailureAlert = true
                }
            }
        } else {
            project.reminderTime = nil
            
            dataController.removeReminders(for: project)
        }
    }
    
    func delete() {
        dataController.delete(project)
        presentationMode.wrappedValue.dismiss()
    }
    
    func toggleClosed() {
        project.closed.toggle()
        
        update()
        
        if project.closed {
            do {
                try hapticEngine?.start()
                
                let player = try hapticEngine?.makePlayer(with: UPHaptic.tada.pattern())
                
                try player?.start(atTime: 0)
            } catch {
                print("Haptics didn't work dude. Bummer.")
            }
        }
    }
    
    func accessibilityTrait(for item: String) -> AccessibilityTraits {
        if item == color {
            return [.isSelected, .isButton]
        } else {
            return .isButton
        }
    }
    
    func showAppSettings() {
        guard
            let settingsURL = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(settingsURL)
        else {
            return
        }
        
        UIApplication.shared.open(settingsURL)
    }
}

struct EditProjectView_Previews: PreviewProvider {
    static let project = Project.example
    
    static var previews: some View {
        EditProjectView(project: project)
    }
}
