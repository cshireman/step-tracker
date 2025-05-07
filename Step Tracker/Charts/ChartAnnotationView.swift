//
//  ChartAnnotationView.swift
//  Step Tracker
//
//  Created by Chris Shireman on 5/1/25.
//

import SwiftUI
import Charts

struct ChartAnnotationView: ChartContent {
    let data: DateValueChartData
    let context: HealthMetricContext
    
    var precision: Int = 0
    var tint: Color {
        data.value < 0 ? context.negativeColor : context.color
    }
    
    var body: some ChartContent {
        RuleMark(x: .value("Selected Metric", data.date, unit: .day))
            .foregroundStyle(Color.secondary.opacity(0.3))
            .offset(y: -10)
            .annotation(position: .top,
                        spacing: 0,
                        overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                annotationView
            }
    }
    
    var annotationView: some View {
        VStack(alignment: .leading) {
            Text(data.date, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                .font(.footnote.bold())
                .foregroundStyle(.secondary)
            
            Text(data.value, format: .number.precision(.fractionLength(precision)))
                .fontWeight(.heavy)
                .foregroundStyle(tint)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .secondary.opacity(0.3), radius: 2, x: 2, y: 2)
        )
    }
}
