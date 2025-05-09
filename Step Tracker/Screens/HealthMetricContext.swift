//
//  HealthMetricContext.swift
//  Step Tracker
//
//  Created by Chris Shireman on 5/9/25.
//
import Foundation
import SwiftUI

enum HealthMetricContext: CaseIterable, Identifiable {
    case steps, weight, activeEnergy, sleep

    var id: Self { self }
    
    var title: String {
        switch self {
        case .steps:
            return "Steps"
        case .weight:
            return "Weight"
        case .activeEnergy:
            return "Activity"
        case .sleep:
            return "Sleep"
        }
    }
    
    var color: Color {
        switch self {
        case .steps:
            return .pink
        case .weight:
            return .indigo
        case .activeEnergy:
            return .orange
        case .sleep:
            return .blue
        }
    }
    
    var negativeColor: Color {
        return .mint
    }
}
