//
//  ChartHelper.swift
//  Step Tracker
//
//  Created by Chris Shireman on 5/1/25.
//

import Foundation

struct ChartHelper {
    static func convert(data: [HealthMetric]) -> [DateValueChartData] {
        data.map { metric in
            DateValueChartData(date: metric.date, value: metric.value)
        }
    }
    
    static func averageValue(for data: [DateValueChartData]) -> Double {
        guard !data.isEmpty else { return 0 }
        let sum = data.reduce(0) { $0 + $1.value }
        return sum / Double(data.count)
    }
    
    static func parseSelectedData(from data: [DateValueChartData], in date: Date?) -> DateValueChartData? {
        guard let date else { return nil }
        return data.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
}
