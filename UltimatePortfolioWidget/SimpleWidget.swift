//
//  SimpleWidget.swift
//  UltimatePortfolioWidgetExtension
//
//  Created by Christopher Eadie on 05/04/2022.
//

import SwiftUI
import WidgetKit

struct UltimatePortfolioWidgetEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            Text("Up next...")
                .font(.title)
            
            if entry.items.isEmpty == false, let item = entry.items.first {
                Text(item.itemTitle)
            } else {
                Text("Nothing!")
            }
        }
    }
}

struct SimpleUltimatePortfolioWidget: Widget {
    let kind: String = "SimpleUltimatePortfolioWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            UltimatePortfolioWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Up next...")
        .description("Your #1 priority item.")
        .supportedFamilies([.systemSmall])
    }
}

struct SimpleUltimatePortfolioWidget_Previews: PreviewProvider {
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
