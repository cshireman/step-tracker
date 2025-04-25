//
//  HealthMetric.swift
//  Step Tracker
//
//  Created by Chris Shireman on 4/24/25.
//

import Foundation

struct HealthMetric: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    
    static var mockData: [HealthMetric] {
        var array: [HealthMetric] = []
        
        for i in 0..<28 {
            let metric = HealthMetric(date: Calendar.current.date(byAdding: .day, value: -i, to: .now)!,
                                      value: Double.random(in: 4000...15000))
            array.append(metric)
        }
        
        return array
    }
}
