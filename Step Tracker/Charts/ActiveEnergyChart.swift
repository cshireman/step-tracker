//
//  ActiveEnergyChart.swift
//  Step Tracker
//
//  Created by Chris Shireman on 5/1/25.
//

import SwiftUI
import Charts

struct ActiveEnergyChart: View {
    @State private var rawSelectedDate: Date?
    @State private var selectedDate: Date = .now
    
    var chartData: [DateValueChartData]
    
    var selectedData: DateValueChartData? {
        ChartHelper.parseSelectedData(from: chartData, in: rawSelectedDate)
    }
    
    var body: some View {
        ChartContainer(title: "Energy", symbol: "figure.run", subtitle: "Avg: \(Int(ChartHelper.averageValue(for: chartData))) calories", context: .activeEnergy, isNav: true) {
            if chartData.isEmpty {
                ChartEmptyView(systemImageName: "chart.bar", title: "No Data", description: "There is no active energy data from the Health App.")
            } else {
                Chart {
                    if let selectedData {
                        RuleMark(x: .value("Selected Metric", selectedData.date, unit: .day))
                            .foregroundStyle(Color.secondary.opacity(0.3))
                            .offset(y: -10)
                            .annotation(position: .top,
                                        spacing: 0,
                                        overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                                ChartAnnotationView(data: selectedData,
                                                    context: .activeEnergy)
                            }
                    }
                    
                    RuleMark(y: .value("Average", ChartHelper.averageValue(for: chartData)))
                        .foregroundStyle(Color.secondary)
                        .lineStyle(.init(lineWidth: 1, dash: [5]))
                    
                    ForEach(chartData) { activity in
                        BarMark(
                            x: .value("Date", activity.date, unit: .day),
                            y: .value("Activity", activity.value)
                        )
                        .foregroundStyle(Color.orange.gradient)
                        .opacity(rawSelectedDate == nil || activity.date == selectedData?.date ? 1 : 0.3)
                    }
                }
                .frame(height: 150)
                .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
                .chartXAxis {
                    AxisMarks {
                        AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                            .foregroundStyle(Color.secondary.opacity(0.3))
                        
                        AxisValueLabel((value.as(Double.self) ?? 0).formatted(.number.notation(.compactName)))
                    }
                }
            }
        }
        .sensoryFeedback(.selection, trigger: selectedDate)
        .onChange(of: rawSelectedDate) { oldValue, newValue in
            guard let oldValue, let newValue else { return }
            if oldValue.weekdayInt != newValue.weekdayInt {
                selectedDate = newValue
            }
        }
    }
}

#Preview {
    ActiveEnergyChart(chartData: [])
}
