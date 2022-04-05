//
//  DataProvider.swift
//  UltimatePortfolioWidgetExtension
//
//  Created by Christopher Eadie on 05/04/2022.
//

import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    typealias Entry = SimpleEntry
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), items: [Item.example])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), items: loadTopItems())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let entries: [SimpleEntry] = [
            SimpleEntry(date: Date(), items: loadTopItems())
        ]
        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
    
    func loadTopItems(count: Int = 5) -> [Item] {
        let dataController = DataController()
        let itemsFetchRequest = dataController.fetchRequestForTopItems(count: count)
        return dataController.results(for: itemsFetchRequest)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let items: [Item]
}
