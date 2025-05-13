//
//  Step_Tracker_Tests.swift
//  Step Tracker Tests
//
//  Created by Chris Shireman on 5/13/25.
//

import Testing
import Foundation
@testable import Step_Tracker

struct Step_Tracker_Tests {

    @Test func arrayAverage() async throws {
        let testArray: [Double] = [1, 2, 3, 4, 5]
        #expect(testArray.average == 3)
    }

}

@Suite("Chart Helper Tests") struct ChartHelperTests {
    @Test func averageWeekdayCount() async throws {
        let testData: [HealthMetric] = [
            HealthMetric(date: Calendar.current.date(from: .init(year: 2025, month: 5, day: 1))!, value: 1000),
            HealthMetric(date: Calendar.current.date(from: .init(year: 2025, month: 5, day: 8))!, value: 2000),
            HealthMetric(date: Calendar.current.date(from: .init(year: 2025, month: 5, day: 15))!, value: 3000),
            HealthMetric(date: Calendar.current.date(from: .init(year: 2025, month: 5, day: 22))!, value: 4000),
            HealthMetric(date: Calendar.current.date(from: .init(year: 2025, month: 5, day: 29))!, value: 5000),
        ]
        
        let result = ChartHelper.averageWeekdayCount(for: testData)
        #expect(result.count == 1)
        #expect(result[0].value == 3000)
    }
}
