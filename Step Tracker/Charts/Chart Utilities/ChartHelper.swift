//
//  ChartHelper.swift
//  Step Tracker
//
//  Created by Chris Shireman on 5/1/25.
//

import Foundation
import Algorithms

struct ChartHelper {
    
    /// Convert an array of HealthMetric to an array of DateValueChartData
    /// - Parameter data: The array of HealthMetric to convert
    /// - Returns: Array of ```DateValueChartData```
    static func convert(data: [HealthMetric]) -> [DateValueChartData] {
        data.map { metric in
            DateValueChartData(date: metric.date, value: metric.value)
        }
    }
    
    /// Finds the first instance of ```DateValueChartData``` that matches the given date
    /// - Parameters:
    ///   - data: The array of ```DateValueChartData``` to search
    ///   - date: The Date to search for
    /// - Returns: DateValueChartData for the given date, nil is not found.
    static func parseSelectedData(from data: [DateValueChartData], in date: Date?) -> DateValueChartData? {
        guard let date else { return nil }
        return data.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    
    /// The average of the ```HealthMetric``` grouped by weekday
    /// - Parameter metric: Array of ```HealthMetric```
    /// - Returns: Array of ```DateValueChartData``` with the average value for each weekday
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
    
    /// The average weeight differences of the ```HealthMetric``` grouped by weekday
    /// - Parameter metric: Array of ```HealthMetric```
    /// - Returns: Array of ```DateValueChartData``` with the average weight differences for each weekday
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
