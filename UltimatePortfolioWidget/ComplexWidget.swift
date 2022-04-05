//
//  ComplexWidget.swift
//  UltimatePortfolioWidgetExtension
//
//  Created by Christopher Eadie on 05/04/2022.
//

import SwiftUI
import WidgetKit

struct UltimatePortfolioWidgetMultipleEntryView: View {
    static let acceptableWidgetFamilys: [WidgetFamily] = [
        .systemSmall,
        .systemMedium,
        .systemLarge
    ]
    
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.sizeCategory) var sizeCategory
    
    var entry: Provider.Entry
    
    var items: ArraySlice<Item> {
        var itemCount: Int
        
        switch widgetFamily {
        case .systemSmall: itemCount = 1
        case .systemMedium:
            if sizeCategory < .extraLarge {
                itemCount = 3
            } else {
                itemCount = 2
            }
        case .systemLarge:
            if sizeCategory < .extraExtraLarge {
                itemCount = 5
            } else {
                itemCount = 4
            }
        default:
            itemCount = 3
        }
        
        return entry.items.prefix(itemCount)
    }
    
    var body: some View {
        VStack {
            if items.isEmpty {
                Text("Nothing!")
            } else {
                ForEach(items) { item in
                    HStack {
                        Color.init(red: 0.1, green: 0.55, blue: 1)
                            .frame(width: 5)
                            .clipShape(Capsule())
                        
                        VStack(alignment: .leading) {
                            Text(item.itemTitle)
                                .font(.headline)
                                .layoutPriority(1)
                            
                            if let projectTitle = item.project?.projectTitle {
                                Text(projectTitle)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(20)
    }
}

struct ComplexUltimatePortfolioWidget: Widget {
    let kind: String = "ComplexUltimatePortfolioWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            UltimatePortfolioWidgetMultipleEntryView(entry: entry)
        }
        .configurationDisplayName("Up next...")
        .description("Your most important items.")
        .supportedFamilies(UltimatePortfolioWidgetMultipleEntryView.acceptableWidgetFamilys)
    }
}

struct ComplexUltimatePortfolioWidget_Previews: PreviewProvider {
    static let acceptableWidgetFamilys = UltimatePortfolioWidgetMultipleEntryView.acceptableWidgetFamilys
    
    static var previews: some View {
        ForEach(acceptableWidgetFamilys, id: \.self) { family in
            UltimatePortfolioWidgetMultipleEntryView(
                entry: SimpleEntry(
                    date: Date(),
                    items: [
                        Item.example,
                        Item.example,
                        Item.example,
                        Item.example,
                        Item.example
                    ]
                )
            )
            .previewContext(WidgetPreviewContext(family: family))
            .previewDisplayName(family.description)
        }
    }
}
