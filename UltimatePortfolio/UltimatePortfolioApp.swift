//
//  UltimatePortfolioApp.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 26/01/2022.
//

import SwiftUI

@main
struct UltimatePortfolioApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var dataController: DataController
    @StateObject var unlockManager: UnlockManager
    @State var newProjectCount: Int
    
    init() {
        let dataController = DataController()
        let unlockManager = UnlockManager(dataController: dataController)
        
        _dataController = StateObject(wrappedValue: dataController)
        _unlockManager = StateObject(wrappedValue: unlockManager)
        _newProjectCount = State(wrappedValue: 0)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
                .environmentObject(unlockManager)
                .onReceive(
                    // As of macOS 11.1, scene phase is not supported, so using this notification
                    // publisher instead for multi-platform deployment.
                    NotificationCenter.default.publisher(
                        for: UIApplication.willResignActiveNotification
                    ),
                    perform: save
                )
                .onAppear(perform: dataController.appLaunched)
        }
    }
    
    func save(_ note: Notification) {
        dataController.save()
    }
    
    func resetNewProjectCount() {
        newProjectCount = 0
    }
}
