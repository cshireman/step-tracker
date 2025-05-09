//
//  ChartHelper.swift
//  Step Tracker
//
//  Created by Chris Shireman on 5/1/25.
//

import Foundation
import Algorithms

struct ChartHelper {
    static func convert(data: [HealthMetric]) -> [DateValueChartData] {
        data.map { metric in
            DateValueChartData(date: metric.date, value: metric.value)
        }
    }
    
    static func parseSelectedData(from data: [DateValueChartData], in date: Date?) -> DateValueChartData? {
        guard let date else { return nil }
        return data.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    @discardableResult
    static func averageWeekdayCount(for metric: [HealthMetric]) -> [DateValueChartData] {
        let sortedByWeekday = metric.sorted(using: KeyPathComparator(\.date.weekdayInt))
        let weekdayArray = sortedByWeekday.chunked { $0.date.weekdayInt == $1.date.weekdayInt}
        
        var weekdayChartData : [DateValueChartData] = []
        for array in weekdayArray {
            guard let firstValue = array.first else { continue }
            
            let total = array.reduce(0.0) { $0 + $1.value }
            let average = total / Double(array.count)
            weekdayChartData.append(.init(date: firstValue.date, value: average))
        }

        return weekdayChartData
    }
    
    @discardableResult
    static func averageDailyWeightDiffs(for weights: [HealthMetric]) -> [DateValueChartData] {
        var diffValues: [(date: Date, value: Double)] = []
        
        guard weights.count > 1 else { return [] }
        
        for i in 1..<weights.count {
            let date = weights[i].date
            let diff = weights[i].value - weights[i-1].value
            diffValues.append((date: date, value: diff))
        }
        
        let sortedByWeekday = diffValues.sorted(using: KeyPathComparator(\.date.weekdayInt))
        let weekdayArray = sortedByWeekday.chunked { $0.date.weekdayInt == $1.date.weekdayInt}
        
        var weekdayChartData : [DateValueChartData] = []
        for array in weekdayArray {
            guard let firstValue = array.first else { continue }
            
            let total = array.reduce(0.0) { $0 + $1.value }
            let average = total / Double(array.count)
            weekdayChartData.append(.init(date: firstValue.date, value: average))
        }

        return weekdayChartData
    }
}
