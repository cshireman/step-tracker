//
//  Step_TrackerApp.swift
//  Step Tracker
//
//  Created by Chris Shireman on 4/20/25.
//

import SwiftUI

@main
struct Step_TrackerApp: App {
    
    let hkManager = HealthKitManager()
    let hkData = HealthKitData()
    
    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environment(hkManager)
                .environment(hkData)
        }
    }
}
