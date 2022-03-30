//
//  ContentView.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 26/01/2022.
//

import CoreSpotlight
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataController: DataController
    @SceneStorage("selectedView") var selectedView: String?
    
    var body: some View {
        TabView(selection: $selectedView) {
            HomeView(dataController: dataController)
                .tag(HomeView.tag)
                .tabItem {
                    Image(systemName: SystemImage.house)
                    Text("Home")
                }
            
            ProjectsView(dataController: dataController, showClosedProjects: false)
                .tag(ProjectsView.openTag)
                .tabItem {
                    Image(systemName: SystemImage.listBullet)
                    Text("Open")
                }
            
            ProjectsView(dataController: dataController, showClosedProjects: true)
                .tag(ProjectsView.closedTag)
                .tabItem {
                    Image(systemName: SystemImage.checkmark)
                    Text("Closed")
                }
            
            AwardsView(dataController: dataController)
                .tag(AwardsView.tag)
                .tabItem {
                    Image(systemName: SystemImage.rosette)
                    Text("Awards")
                }
        }
        .onContinueUserActivity(CSSearchableItemActionType, perform: moveToHome)
        .onContinueUserActivity(ShortcutURL.newProject.activityType, perform: createProject)
        .userActivity(ShortcutURL.newProject.activityType) { activity in
            activity.title = ShortcutURL.newProject.title
            activity.isEligibleForPrediction = true
        }
        .onOpenURL(perform: openURL)
    }
    
    func moveToHome(_ input: Any) {
        selectedView = HomeView.tag
    }
    
    func openURL(_ url: URL) {
        if url.absoluteString.contains(AppURL.newProject.rawValue) {
            selectedView = ProjectsView.openTag
            dataController.addProject()
        }
    }
    
    func createProject(_ userActivity: NSUserActivity) {
        if userActivity.activityType == ShortcutURL.newProject.activityType {
            selectedView = ProjectsView.openTag
            dataController.addProject()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var dataController = DataController.preview
    
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
