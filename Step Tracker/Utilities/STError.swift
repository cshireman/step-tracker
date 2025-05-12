//
//  STError.swift
//  Step Tracker
//
//  Created by Chris Shireman on 5/9/25.
//

import Foundation

enum STError: LocalizedError {
    case authNotDetermined
    case noData
    case sharingDenied(quantityType: String)
    case unableToCompleteRequest
    case invalidInput
    
    var errorDescription: String? {
        switch self {
        case .authNotDetermined:
            "Need Access to Health Data"
        case .noData:
            "No Data"
        case .sharingDenied(let quantityType):
            "Sharing Denied for \(quantityType)"
        case .unableToCompleteRequest:
            "Unable to Complete Request"
        case .invalidInput:
            "Invalid Input"
        }
    }
    
    var failureReason: String? {
        switch self {
        case .authNotDetermined:
            "You have not given access to your Health data.  Please go to Settings > Health > Data Access & Devices."
        case .noData:
            "No data available for the selected date range."
        case .sharingDenied(let quantityType):
            "Please enable sharing for \(quantityType) in Settings."
        case .unableToCompleteRequest:
            "An error occurred while processing the request."
        case .invalidInput:
            "Must be a numeric value with a maximum of 1 decimal place."
        }
    }
}
