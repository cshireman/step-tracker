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
    
    var selectedStat: HealthMetricContext
    var chartData: [WeekdayChartData]
    
    var selectedWeekdayData: WeekdayChartData? {
        guard let rawSelectedDate else { return nil }
        return chartData.first { Calendar.current.isDate($0.date, inSameDayAs: rawSelectedDate) }
    }
    
    var body: some View {
        ChartContainer(title: "Average Weight Change", symbol: "figure", subtitle: "Per Weekday (Last 28 Days)", context: .weight, isNav: false) {
            if chartData.isEmpty {
                ChartEmptyView(systemImageName: "chart.bar", title: "No Weight Data", description: "There is no weight data from the Health App.")
            } else {
                Chart {
                    if let selectedWeekdayData {
                        RuleMark(x: .value("Selected Metric", selectedWeekdayData.date, unit: .day))
                            .foregroundStyle(Color.secondary.opacity(0.3))
                            .offset(y: -10)
                            .annotation(position: .top,
                                        spacing: 0,
                                        overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                                annotationView
                            }
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
            }
        }
    }
    
    var annotationView: some View {
        VStack(alignment: .leading) {
            Text(selectedWeekdayData?.date ?? .now, format: .dateTime.weekday(.wide))
                .font(.footnote.bold())
                .foregroundStyle(.secondary)
            
            let sign = self.selectedWeekdayData?.value ?? 0 < 0 ? "" : "+"
            HStack(spacing: 0) {
                Text(sign)
                Text(selectedWeekdayData?.value ?? 0, format: .number.precision(.fractionLength(2)))
            }
            .fontWeight(.heavy)
            .foregroundStyle(self.selectedWeekdayData?.value ?? 0 < 0 ? .mint : .indigo)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .secondary.opacity(0.3), radius: 2, x: 2, y: 2)
        )
    }
}

#Preview {
    WeightBarChart(selectedStat: .weight, chartData: ChartMath.averageDailyWeightDiffs(for: []))
}
