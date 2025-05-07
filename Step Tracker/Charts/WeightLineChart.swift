//
//  WeightLineChart.swift
//  Step Tracker
//
//  Created by Chris Shireman on 4/28/25.
//

import SwiftUI
import Charts

struct WeightLineChart: View {
    @State private var rawSelectedDate: Date?
    @State private var selectedDate: Date = .now
    
    var chartData: [DateValueChartData]
    
    var minValue: Double {
        chartData.map { $0.value }.min() ?? 0
    }
    
    var avgWeight: Double {
        guard !chartData.isEmpty else { return 0 }
        let avg = chartData.reduce(0) { $0 + $1.value } / Double(chartData.count)
        return avg.rounded()
    }
    
    
    var selectedData: DateValueChartData? {
        ChartHelper.parseSelectedData(from: chartData, in: rawSelectedDate)
    }
    
    var body: some View {
        let config = ChartContainerConfiguration(title: "Weight", symbol: "figure", subtitle: "Avg: \(avgWeight) lbs", context: .weight, isNav: true)
        ChartContainer(config: config) {
            if chartData.isEmpty {
                ChartEmptyView(systemImageName: "chart.line.downtrend.xyaxis", title: "No Weight Data", description: "There is no weight data from the Health App.")
            } else {
                Chart {
                    if let selectedData {
                        ChartAnnotationView(data: selectedData,
                                            context: .weight,
                                            precision: 1)
                    }
                    
                    RuleMark(y: .value("Goal", 155))
                        .foregroundStyle(Color.mint)
                        .lineStyle(.init(lineWidth: 1, dash: [5]))
                    
                    ForEach(chartData) { weight in
                        AreaMark(
                            x: .value("Day", weight.date, unit: .day),
                            yStart: .value("Value", weight.value),
                            yEnd: .value("Min Value", minValue)
                        )
                        .foregroundStyle(Gradient(colors: [.indigo.opacity(0.5), .clear]))
                        .interpolationMethod(.catmullRom)
                        
                        LineMark(
                            x: .value("Day", weight.date, unit: .day),
                            y: .value("Value", weight.value)
                        )
                        .foregroundStyle(.indigo)
                        .interpolationMethod(.catmullRom)
                        .symbol(.circle)
                    }
                }
                .frame(height: 150)
                .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
                .chartYScale(domain: .automatic(includesZero: false))
                .chartXAxis {
                    AxisMarks {
                        AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
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
                    if oldValue?.weekdayInt != newValue?.weekdayInt {
                        selectedDate = newValue ?? .now
                    }
                }
            }
        }
    }
}

#Preview {
    WeightLineChart(chartData: [])
}
