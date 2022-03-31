//
//  UltimatePortfolioWidget.swift
//  UltimatePortfolioWidget
//
//  Created by Christopher Eadie on 30/03/2022.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), items: [Item.example])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), items: loadItems())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let entries: [SimpleEntry] = [
            SimpleEntry(date: Date(), items: loadItems())
        ]
        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
    
    func loadItems(count: Int = 1) -> [Item] {
        let dataController = DataController()
        let itemsFetchRequest = dataController.fetchRequestForTopItems(count: count)
        return dataController.results(for: itemsFetchRequest)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let items: [Item]
}

struct UltimatePortfolioWidgetEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            Text("Up next...")
                .font(.title)
            
            if entry.items.isEmpty == false {
                ForEach(entry.items, id: \.self) { item in
                    Text(item.itemTitle)
                }
            } else {
                Text("Nothing!")
            }
        }
    }
}

@main
struct UltimatePortfolioWidgets: WidgetBundle {
    var body: some Widget {
        UpNextWidget()
    }
}

struct UpNextWidget: Widget {
    let kind: String = "UpNextWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            UltimatePortfolioWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Up next...")
        .description("Your number one priority item.")
        .supportedFamilies([.systemSmall])
    }
}

struct UltimatePortfolioWidget_Previews: PreviewProvider {
    static var previews: some View {
        UltimatePortfolioWidgetEntryView(
            entry: SimpleEntry(
                date: Date(),
                items: [Item.example]
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        .previewDisplayName(WidgetFamily.systemSmall.description)
    }
}
