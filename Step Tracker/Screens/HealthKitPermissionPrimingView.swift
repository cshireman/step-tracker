//
//  HealthKitPermissionPrimingView.swift
//  Step Tracker
//
//  Created by Chris Shireman on 4/23/25.
//

import SwiftUI
import HealthKitUI

struct HealthKitPermissionPrimingView: View {
    @Environment(HealthKitManager.self) private var hkManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var isShowingHealthKitPermissions: Bool = false
    
    var description = """
    This app displays your step and weight data in interactive charts.
    
    You can also add new step or weight data to Apple Health from this app.  Your data is private and secured.
    """
    
    var body: some View {
        VStack(spacing: 130) {
            VStack(alignment: .leading, spacing: 10) {
                Image(.appleHealth)
                    .resizable()
                    .frame(width: 90, height: 90)
                    .shadow(color: .gray.opacity(0.3), radius: 10)
                    .padding(.bottom, 12)
                
                Text("Apple Health Integration")
                    .font(.title2)
                    .bold()
                
                Text(description)
                    .foregroundStyle(.secondary)
            }
            
            Button("Connect Apple Health") {
                isShowingHealthKitPermissions = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.pink)
        }
        .padding(30)
        .interactiveDismissDisabled()

        .healthDataAccessRequest(store: hkManager.store,
                                 shareTypes: hkManager.types,
                                 readTypes: hkManager.types,
                                 trigger: isShowingHealthKitPermissions) { result in
            switch result {
            case .success:
                Task {
                    do {
                        try await hkManager.fetchActiveEnergy()
                        try await hkManager.fetchStepCount()
                        try await hkManager.fetchWeights()
                        try await hkManager.fetchWeightsForDifferentials()
                        try await hkManager.fetchSleep()
                    } catch {
                        
                    }
                }
                dismiss()
                break
            case .failure:
                //handle error
                dismiss()
                break
            }
        }
    }
}

#Preview {
    HealthKitPermissionPrimingView()
        .environment(HealthKitManager())
}
