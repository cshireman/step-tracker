//
//  HealthKitManager.swift
//  Step Tracker
//
//  Created by Chris Shireman on 4/23/25.
//

import Foundation
import HealthKit
import Observation

@Observable @MainActor
final class HealthKitData: Sendable {
    var activeEnergyData: [HealthMetric] = []
    var stepData: [HealthMetric] = []
    var weightData: [HealthMetric] = []
    var weightDiffData: [HealthMetric] = []
    var sleepData: [HealthMetric] = []
}

@Observable final class HealthKitManager: Sendable {
    let store = HKHealthStore()
    
    let types: Set = [
        HKQuantityType(.stepCount),
        HKQuantityType(.bodyMass),
        HKQuantityType(.activeEnergyBurned),
        HKCategoryType(.sleepAnalysis)
    ]
    
    /// Fetch last 28 days of step count from HealthKit
    /// - Returns: Array of ``HealthMetric``
    func fetchStepCount() async throws -> [HealthMetric] {
        guard store.authorizationStatus(for: HKQuantityType(.stepCount)) != .notDetermined else {
            throw STError.authNotDetermined
        }
        
        let interval = createDateInterval(from: .now, daysBack: 28)
        
        let queryPredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end, options: [])
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.stepCount), predicate: queryPredicate)
        let stepsQuery = HKStatisticsCollectionQueryDescriptor(predicate: samplePredicate,
                                                               options: .cumulativeSum,
                                                               anchorDate: interval.end,
                                                               intervalComponents: .init(day: 1))
        
        do {
            let stepCounts = try await stepsQuery.result(for: store)
            return stepCounts.statistics().map {
                .init(date: $0.startDate, value: $0.sumQuantity()?.doubleValue(for: .count()) ?? 0)
            }
        } catch HKError.errorNoData {
            throw STError.noData
        } catch {
            throw STError.unableToCompleteRequest
        }
    }
    
    /// Fetch last 28 days of active energy from HealthKit
    /// - Returns: Array of ``HealthMetric``
    func fetchActiveEnergy() async throws -> [HealthMetric] {
        guard store.authorizationStatus(for: HKQuantityType(.activeEnergyBurned)) != .notDetermined else {
            throw STError.authNotDetermined
        }
        
        let interval = createDateInterval(from: .now, daysBack: 28)
        
        let queryPredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end, options: [])
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.activeEnergyBurned), predicate: queryPredicate)
        let stepsQuery = HKStatisticsCollectionQueryDescriptor(predicate: samplePredicate,
                                                               options: .cumulativeSum,
                                                               anchorDate: interval.end,
                                                               intervalComponents: .init(day: 1))
        
        do {
            let activeEnergies = try await stepsQuery.result(for: store)
            return activeEnergies.statistics().map {
                .init(date: $0.startDate, value: $0.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0)
            }
        } catch HKError.errorNoData {
            throw STError.noData
        } catch {
            throw STError.unableToCompleteRequest
        }
    }
    
    /// Fetch most recent weight sample on each day for a specified number of days back from today.
    /// - Parameter daysBack: Days back from today. Ex - 20 will returh the last 20 days.
    /// - Returns: Array of ```HealthMetric```
    func fetchWeights(daysBack: Int) async throws -> [HealthMetric] {
        guard store.authorizationStatus(for: HKQuantityType(.bodyMass)) != .notDetermined else {
            throw STError.authNotDetermined
        }
        
        let interval = createDateInterval(from: .now, daysBack: daysBack)
        
        let queryPredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end, options: [])
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.bodyMass), predicate: queryPredicate)
        let weightsQuery = HKStatisticsCollectionQueryDescriptor(predicate: samplePredicate,
                                                                 options: .mostRecent,
                                                                 anchorDate: interval.end,
                                                                 intervalComponents: .init(day: 1))
        
        do {
            let weights = try await weightsQuery.result(for: store)
            return weights.statistics().map {
                .init(date: $0.startDate, value: $0.mostRecentQuantity()?.doubleValue(for: .pound()) ?? 0)
            }
        } catch HKError.errorNoData {
            throw STError.noData
        } catch {
            throw STError.unableToCompleteRequest
        }
    }
    
    /// Write step count data to HealthKit.  Requires HealthKit write permission.
    /// - Parameters:
    ///   - date: Date for step count value
    ///   - value: Step count value
    func addStepData(for date: Date, value: Double) async throws {
        let status = store.authorizationStatus(for: HKQuantityType(.stepCount))
        switch status {
        case .notDetermined:
            throw STError.authNotDetermined
        case .sharingDenied:
            throw STError.sharingDenied(quantityType: "step count")
        case .sharingAuthorized:
            break
        @unknown default:
            break
        }
        
        let stepQuantity = HKQuantity(unit: .count(), doubleValue: value)
        let stepSample = HKQuantitySample(type: HKQuantityType(.stepCount), quantity: stepQuantity, start: date, end: date)
        
        do {
            try await store.save(stepSample)
        } catch {
            throw STError.unableToCompleteRequest
        }
    }
    
    /// Write weight data to HealthKit. Requires HealthKit write permission.
    /// - Parameters:
    ///   - date: Date for weight value
    ///   - value: Weight value in pounds.  Uses pounds as a Double for .bodyMass conversions.
    func addWeightData(for date: Date, value: Double) async throws {
        let status = store.authorizationStatus(for: HKQuantityType(.bodyMass))
        switch status {
        case .notDetermined:
            throw STError.authNotDetermined
        case .sharingDenied:
            throw STError.sharingDenied(quantityType: "weight")
        case .sharingAuthorized:
            break
        @unknown default:
            break
        }
        
        let weightQuantity = HKQuantity(unit: .pound(), doubleValue: value)
        let weightSample = HKQuantitySample(type: HKQuantityType(.bodyMass), quantity: weightQuantity, start: date, end: date)
        
        do {
            try await store.save(weightSample)
        } catch {
            throw STError.unableToCompleteRequest
        }
    }
    
    /// Write active energy data to HealthKit. Requires HealthKit write permission.
    /// - Parameters:
    ///   - date: Date for active energy value
    ///   - value: The active energy value in kilocalories.
    func addActiveEneryData(for date: Date, value: Double) async throws {
        let status = store.authorizationStatus(for: HKQuantityType(.activeEnergyBurned))
        switch status {
        case .notDetermined:
            throw STError.authNotDetermined
        case .sharingDenied:
            throw STError.sharingDenied(quantityType: "active energy")
        case .sharingAuthorized:
            break
        @unknown default:
            break
        }
        
        let energyQuantity = HKQuantity(unit: .largeCalorie(), doubleValue: value)
        let energySample = HKQuantitySample(type: HKQuantityType(.activeEnergyBurned), quantity: energyQuantity, start: date, end: date)
        
        do {
            try await store.save(energySample)
        } catch {
            throw STError.unableToCompleteRequest
        }
    }
    
//    func addSimulatorData() async {
//        var mockSamples: [HKQuantitySample] = []
//
//        for i in 0..<28 {
//            let stepQuantity = HKQuantity(unit: .count(), doubleValue: .random(in: 4000...20000))
//            let weightQuantity = HKQuantity(unit: .pound(), doubleValue: .random(in: (160 + Double(i/3)...165 + Double(i/3))))
//            let energyQuantity = HKQuantity(unit: .largeCalorie(), doubleValue: .random(in: 900...1500))
//            
//            let startDate = Calendar.current.date(byAdding: .day, value: -i, to: .now)!
//            let endDate = Calendar.current.date(byAdding: .second, value: 1, to: startDate)!
//            
//            let stepSample = HKQuantitySample(type: HKQuantityType(.stepCount), quantity: stepQuantity, start: startDate, end: endDate)
//            let weightSample = HKQuantitySample(type: HKQuantityType(.bodyMass), quantity: weightQuantity, start: startDate, end: endDate)
//            let energySample = HKQuantitySample(type: HKQuantityType(.activeEnergyBurned), quantity: energyQuantity, start: startDate, end: endDate)
//            
//            mockSamples.append(stepSample)
//            mockSamples.append(weightSample)
//            mockSamples.append(energySample)
//        }
//        
//        try! await store.save(mockSamples)
//        print("✅ Dummy Health Kit Data Added Successfully!")
//    }
    
    /// Creates a date interval for the last N days from the given date.
    /// - Parameters:
    ///   - date: The end date for the interval. Ex - today
    ///   - daysBack: The number of days back to include in the interval.
    /// - Returns: The ```DateInterval``` object representing the interval.
    func createDateInterval(from date: Date, daysBack: Int) -> DateInterval {
        let calendar = Calendar.current
        let startOfEndDate = calendar.startOfDay(for: date)
        
        let endDate = calendar.date(byAdding: .day, value: 1, to: startOfEndDate)!
        let startDate = calendar.date(byAdding: .day, value: -daysBack, to: endDate)!
        
        return DateInterval(start: startDate, end: endDate)
    }
}
