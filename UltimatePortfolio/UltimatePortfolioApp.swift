//
//  UltimatePortfolioApp.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 26/01/2022.
//

import SwiftUI

@main
struct UltimatePortfolioApp: App {
    @StateObject var dataController: DataController
    @StateObject var unlockManager: UnlockManager
    
    init() {
        let dataController = DataController()
        let unlockManager = UnlockManager(dataController: dataController)
        
        _dataController = StateObject(wrappedValue: dataController)
        _unlockManager = StateObject(wrappedValue: unlockManager)
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
        }
    }
    
    func save(_ note: Notification) {
        dataController.save()
    }
}
