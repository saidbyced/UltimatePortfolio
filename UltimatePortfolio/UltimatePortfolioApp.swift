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
    
    init() {
        let dataController = DataController()
        _dataController = StateObject(wrappedValue: dataController)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
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
