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
}
