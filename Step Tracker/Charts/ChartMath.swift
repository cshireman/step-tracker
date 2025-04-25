//
//  ChartMath.swift
//  Step Tracker
//
//  Created by Chris Shireman on 4/25/25.
//

import Foundation
import Algorithms

struct ChartMath {
    @discardableResult
    static func averageWeekdayCount(for metric: [HealthMetric]) -> [WeekdayChartData] {
        let sortedByWeekday = metric.sorted { $0.date.weekdayInt < $1.date.weekdayInt }
        let weekdayArray = sortedByWeekday.chunked { $0.date.weekdayInt == $1.date.weekdayInt}
        
        var weekdayChartData : [WeekdayChartData] = []
        for array in weekdayArray {
            guard let firstValue = array.first else { continue }
            
            let total = array.reduce(0.0) { $0 + $1.value }
            let average = total / Double(array.count)
            weekdayChartData.append(.init(date: firstValue.date, value: average))
        }

        return weekdayChartData
    }
}
