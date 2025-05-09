//
//  WeightBarChart.swift
//  Step Tracker
//
//  Created by Chris Shireman on 4/28/25.
//

import SwiftUI
import Charts

struct WeightBarChart: View {
    @State private var rawSelectedDate: Date?
    @State private var selectedDate: Date = .now
    
    var chartData: [DateValueChartData]
    
    var selectedWeekdayData: DateValueChartData? {
        ChartHelper.parseSelectedData(from: chartData, in: rawSelectedDate)
    }
    
    var body: some View {
        let config = ChartContainerConfiguration(title: "Average Weight Change", symbol: "figure", subtitle: "Per Weekday (Last 28 Days)", context: .weight, isNav: false)
        
        ChartContainer(config: config) {
            Chart {
                if let selectedWeekdayData {
                    ChartAnnotationView(data: selectedWeekdayData,
                                        context: .weight,
                                        precision: 2)
                }
                
                ForEach(chartData) { data in
                    BarMark(
                        x: .value("Date", data.date, unit: .day),
                        y: .value("Weight Diff", data.value)
                    )
                    .foregroundStyle(data.value >= 0 ? Color.indigo.gradient : Color.mint.gradient)
                }
            }
            .frame(height: 240)
            .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
            .chartYScale(domain: .automatic(includesZero: true))
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) {
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated), centered: true)
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                        .foregroundStyle(Color.secondary.opacity(0.3))
                    
                    AxisValueLabel()
                }
            }
            .sensoryFeedback(.selection, trigger: selectedDate)
            .onChange(of: rawSelectedDate) { oldValue, newValue in
                guard let oldValue, let newValue else { return }
                if oldValue.weekdayInt != newValue.weekdayInt {
                    selectedDate = newValue
                }
            }
            .overlay {
                if chartData.isEmpty {
                    ChartEmptyView(systemImageName: "chart.bar", title: "No Weight Data", description: "There is no weight data from the Health App.")
                }
            }
            
        }
    }
}

#Preview {
    WeightBarChart(chartData: ChartHelper.averageDailyWeightDiffs(for: []))
}
