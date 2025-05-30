//
//  DateValueChartData.swift
//  Step Tracker
//
//  Created by Chris Shireman on 4/25/25.
//

import Foundation

struct DateValueChartData: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let value: Double
}
