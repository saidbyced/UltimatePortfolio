//
//  ProjectSummaryView.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 01/03/2022.
//

import SwiftUI

struct ProjectsSummariesView: View {
    let projects: FetchedResults<Project>
    
    var projectRows: [GridItem] {
        [ GridItem(.fixed(100)) ]
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: projectRows) {
                ForEach(projects, content: projectBox)
            }
            .padding([.horizontal, .top])
        }
    }
    
    func projectBox(project: Project) -> some View {
        VStack(alignment: .leading) {
            Text("\(project.projectItems.count) items")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(project.projectTitle)
                .font(.title2)
            
            ProgressView(value: project.completionAmount)
                .accentColor(Color(project.projectColor))
        }
        .padding()
        .background(Color.secondarySystemGroupedBackground)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.2), radius: 5)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(project.accessibleLabel)
    }
}
