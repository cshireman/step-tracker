//
//  Untitled.swift
//  Step Tracker
//
//  Created by Chris Shireman on 5/9/25.
//

import Foundation
import HealthKit


extension HealthKitManager {
    func fetchSleep() async throws -> [HealthMetric] {
        guard store.authorizationStatus(for: HKCategoryType(.sleepAnalysis)) != .notDetermined else {
            throw STError.authNotDetermined
        }
        
        let interval = createDateInterval(from: .now, daysBack: 28)
        
        let queryPredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end, options: [.strictStartDate])
        let samplePredicate = HKSamplePredicate.categorySample(type: HKCategoryType(.sleepAnalysis), predicate: queryPredicate)
        let sleepQuery = HKSampleQueryDescriptor(predicates: [samplePredicate], sortDescriptors: [])
        
        do {
            let samples = try await sleepQuery.result(for: store)
            return processSleepSamples(samples)
        } catch HKError.errorNoData {
            throw STError.noData
        } catch {
            throw STError.unableToCompleteRequest
        }
    }
    
    private func processSleepSamples(_ samples: [HKCategorySample]) -> [HealthMetric] {
        // Dictionary to hold sleep data by date
        var sleepDataByDate: [Date: [String: TimeInterval]] = [:]
        
        // Process each sample
        for sample in samples {
            let date = sample.startDate.startOfDay
            
            // Initialize entry if it doesn't exist
            if sleepDataByDate[date] == nil {
                sleepDataByDate[date] = [
                    "totalSleep": 0,
                    "deepSleep": 0,
                    "remSleep": 0,
                    "lightSleep": 0
                ]
            }
            
            // Calculate duration
            let duration = sample.endDate.timeIntervalSince(sample.startDate)
            
            // Update the appropriate sleep stage
            sleepDataByDate[date]?["totalSleep"]? += duration
            
            // Update specific sleep stage
            switch sample.value {
            case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
                sleepDataByDate[date]?["deepSleep"]? += duration
            case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
                sleepDataByDate[date]?["remSleep"]? += duration
            case HKCategoryValueSleepAnalysis.asleepCore.rawValue, HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue:
                sleepDataByDate[date]?["lightSleep"]? += duration
            default:
                break
            }
        }
        
        return calculateSleepScores(sleepDataByDate)
    }
    
    private func calculateSleepScores(_ sleepDataByDate: [Date: [String: TimeInterval]]) -> [HealthMetric] {
        var results: [HealthMetric] = []
        
        for (date, sleepData) in sleepDataByDate {
            // Get sleep durations in hours
            let totalSleepHours = sleepData["totalSleep"]! / 3600
            let deepSleepHours = sleepData["deepSleep"]! / 3600
            let remSleepHours = sleepData["remSleep"]! / 3600
            
            // Score components
            var durationScore: Double = 0
            var qualityScore: Double = 0
            
            // Duration score (based on recommended 7-9 hours)
            if totalSleepHours < 5 {
                durationScore = 40 * (totalSleepHours / 5)
            } else if totalSleepHours < 7 {
                durationScore = 40 + 30 * ((totalSleepHours - 5) / 2)
            } else if totalSleepHours <= 9 {
                durationScore = 70 + 30 * ((totalSleepHours - 7) / 2)
            } else {
                durationScore = 100 - (totalSleepHours - 9) * 10 // Penalty for too much sleep
            }
            
            // Quality score (based on ideal proportions of sleep stages)
            let deepSleepPercentage = (deepSleepHours / totalSleepHours) * 100
            let remSleepPercentage = (remSleepHours / totalSleepHours) * 100
            
            // Ideal: ~15-20% deep sleep, ~20-25% REM sleep
            let deepSleepScore = 50 - min(abs(deepSleepPercentage - 17.5), 17.5) * (50/17.5)
            let remSleepScore = 50 - min(abs(remSleepPercentage - 22.5), 22.5) * (50/22.5)
            
            qualityScore = (deepSleepScore + remSleepScore) / 2
            
            // Final sleep score (60% duration, 40% quality)
            let sleepScore = (durationScore * 0.6) + (qualityScore * 0.4)
            
            // Store the calculated score
            let healthMetric = HealthMetric(date: date, value: min(max(sleepScore, 0), 100))  // Ensure score is between 0-100
            results.append(healthMetric)
        }
        
        let sortedResults = results.sorted { $0.date < $1.date }
        return sortedResults
    }
    
//    func addSimulatorSleepData() async {
//        // Generate 28 days of sleep data
//        for day in 0..<28 {
//            // Start date is X days ago from now
//            guard let startDate = Calendar.current.date(byAdding: .day, value: -day, to: Date()) else { continue }
//            
//            // Calculate a random sleep duration between 5-9 hours (in seconds)
//            let sleepHours = Double.random(in: 5...9)
//            let sleepSeconds = sleepHours * 3600
//            
//            // Set end date based on sleep duration
//            let endDate = startDate.addingTimeInterval(sleepSeconds)
//            
//            // Create samples for different sleep stages
//            createSleepStages(startDate: startDate, endDate: endDate, day: day)
//        }
//    }
//    
//    private func createSleepStages(startDate: Date, endDate: Date, day: Int) {
//        let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
//        
//        // Sleep stages distribution will vary slightly based on the day
//        // This creates some variation in our sleep quality
//        let variation = Double(day % 5) / 10.0
//        
//        // Total sleep duration in seconds
//        let totalDuration = endDate.timeIntervalSince(startDate)
//        
//        // Define stage proportions (vary slightly based on the day)
//        let deepSleepProportion = 0.15 + variation
//        let remSleepProportion = abs(0.25 - variation)
//        
//        // Calculate durations
//        let deepSleepDuration = totalDuration * deepSleepProportion
//        let remSleepDuration = totalDuration * remSleepProportion
//        
//        // Current tracking time
//        var currentTime = startDate
//        
//        // Create deep sleep sample
//        let deepSleepEndTime = currentTime.addingTimeInterval(deepSleepDuration)
//        let deepSleepSample = HKCategorySample(
//            type: sleepType,
//            value: HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
//            start: currentTime,
//            end: deepSleepEndTime
//        )
//        
//        // Update current time
//        currentTime = deepSleepEndTime
//        
//        // Create REM sleep sample
//        let remSleepEndTime = currentTime.addingTimeInterval(remSleepDuration)
//        let remSleepSample = HKCategorySample(
//            type: sleepType,
//            value: HKCategoryValueSleepAnalysis.asleepREM.rawValue,
//            start: currentTime,
//            end: remSleepEndTime
//        )
//        
//        // Update current time
//        currentTime = remSleepEndTime
//        
//        // Create light sleep sample
//        let lightSleepSample = HKCategorySample(
//            type: sleepType,
//            value: HKCategoryValueSleepAnalysis.asleepCore.rawValue,
//            start: currentTime,
//            end: endDate
//        )
//        
//        // Write all the samples to HealthKit
//        store.save([deepSleepSample, remSleepSample, lightSleepSample]) { success, error in
//            if let error = error {
//                print("Error saving sleep data: \(error.localizedDescription)")
//            }
//        }
//    }
}
