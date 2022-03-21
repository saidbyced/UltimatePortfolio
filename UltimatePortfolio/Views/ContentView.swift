//
//  ContentView.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 26/01/2022.
//

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
