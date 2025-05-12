//
//  SleepBarChart.swift
//  Step Tracker
//
//  Created by Chris Shireman on 5/1/25.
//

import SwiftUI
import Charts

struct SleepBarChart: View {
    @State private var rawSelectedDate: Date?
    @State private var selectedDate: Date = .now
    
    var chartData: [DateValueChartData]
    
    var selectedData: DateValueChartData? {
        ChartHelper.parseSelectedData(from: chartData, in: rawSelectedDate)
    }
    
    var averageSleep: Int {
        Int(chartData.map { $0.value}.average)
    }
    
    var body: some View {
        ChartContainer(chartType: .sleepBar(average: averageSleep)) {
            Chart {
                if let selectedData {
                    ChartAnnotationView(data: selectedData, context: .sleep)
                }
                
                if !chartData.isEmpty {
                    RuleMark(y: .value("Average", chartData.map { $0.value}.average))
                        .foregroundStyle(Color.secondary)
                        .lineStyle(.init(lineWidth: 1, dash: [5]))
                        .accessibilityHidden(true)
                }
                
                ForEach(chartData) { sleepScore in
                    Plot {
                        BarMark(
                            x: .value("Date", sleepScore.date, unit: .day),
                            y: .value("Sleep Score", sleepScore.value)
                        )
                        .foregroundStyle(Color.blue.gradient)
                        .opacity(rawSelectedDate == nil || sleepScore.date == selectedData?.date ? 1 : 0.3)
                    }
                    .accessibilityLabel(sleepScore.date.accessibilityDate)
                    .accessibilityValue("\(Int(sleepScore.value))")
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
            .overlay {
                if chartData.isEmpty {
                    ChartEmptyView(systemImageName: "chart.bar", title: "No Data", description: "There is no sleep data from the Health App.")
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
    StepBarChart(chartData: [])
}
