//
//  HealthKitManager.swift
//  Step Tracker
//
//  Created by Chris Shireman on 4/23/25.
//

import Foundation
import HealthKit
import Observation

@Observable class HealthKitManager {
    let store = HKHealthStore()
    
    let types: Set = [
        HKQuantityType(.stepCount),
        HKQuantityType(.bodyMass)
    ]
}
