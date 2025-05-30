//
//  ChartEmptyView.swift
//  Step Tracker
//
//  Created by Chris Shireman on 4/30/25.
//

import SwiftUI

struct ChartEmptyView: View {
    let systemImageName: String
    let title: String
    let description: String
    
    var body: some View {
        ContentUnavailableView {
            Image(systemName: systemImageName)
                .resizable()
                .frame(width: 32, height: 32)
                .padding(.bottom, 8)
            
            Text(title)
                .font(.callout.bold())
                
            Text(description)
                .font(.footnote)
        }
        .foregroundStyle(.secondary)
        .offset(y: -12)
    }
}

#Preview {
    ChartEmptyView(systemImageName: "chart.bar", title: "No Data", description: "There is no step data from the Health App.")
}
