//
//  Healt.swift
//  Step Tracker
//
//  Created by Chris Shireman on 4/23/25.
//

import SwiftUI

struct HealthDataListView: View {
    @Environment(HealthKitManager.self) private var hkManager
    @Environment(HealthKitData.self) private var hkData
    
    @State private var isShowingAddData: Bool = false
    @State private var addDataDate: Date = .now
    @State private var valueToAdd: String = ""
    
    @State private var isShowingAlert: Bool = false
    @State private var writeError: STError = .noData
    
    var metric: HealthMetricContext
    var listData: [HealthMetric] {
        switch metric {
        case .steps:
            return hkData.stepData
        case .weight:
            return hkData.weightData
        case .activeEnergy:
            return hkData.activeEnergyData
        case .sleep:
            return hkData.sleepData
        }
    }
    
    var body: some View {
        List(listData.reversed()) { data in
            LabeledContent {
                Text(data.value, format: .number.precision(.fractionLength(metric == .steps ? 0 : 1)))
            } label: {
                Text(data.date, format: .dateTime.month().day().year())
                    .accessibilityLabel(data.date.accessibilityDate)
            }
            .accessibilityElement(children: .combine)
        }
        .navigationTitle(metric.title)
        .sheet(isPresented: $isShowingAddData) {
            addDataView
        }
        .toolbar {
            Button("Add Data", systemImage: "plus") {
                isShowingAddData = true
            }
        }
    }
    
    var addDataView: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $addDataDate, displayedComponents: .date)
                HStack {
                    LabeledContent(metric.title) {
                        TextField("Value", text: $valueToAdd)
                            .keyboardType(metric == .steps ? .numberPad : .decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 140)
                    }
                }
            }
            .navigationTitle(metric.title)
            .alert(isPresented: $isShowingAlert, error: writeError) { writeError in
                switch writeError {
                case .authNotDetermined:
                    EmptyView()
                case .sharingDenied(_):
                    Button("Settings") {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                    
                    Button("Cancel", role: .cancel) { }
                default:
                    EmptyView()
                }
                
            } message: { writeError in
                Text(writeError.failureReason ?? "")
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Data") {
                        saveValue()
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button("Dismiss") {
                        isShowingAddData = false
                    }
                }
            }
        }
    }
    
    private func saveValue() {
        Task {
            guard let value = Double(valueToAdd) else {
                writeError = .invalidInput
                isShowingAlert = true
                valueToAdd = ""
                return
            }
            
            do {
                switch metric {
                case .steps:
                    try await hkManager.addStepData(for: addDataDate, value: value)
                    
                    async let stepCount = hkManager.fetchStepCount()
                    try await hkData.stepData = stepCount
                case .weight:
                    try await hkManager.addWeightData(for: addDataDate, value: value)
                    async let weights = hkManager.fetchWeights(daysBack: 28)
                    async let weightDiffs = hkManager.fetchWeights(daysBack: 29)
                    
                    try await hkData.weightData = weights
                    try await hkData.weightDiffData = weightDiffs
                case .activeEnergy:
                    try await hkManager.addActiveEneryData(for: addDataDate, value: value)
                    async let activeEnergy = hkManager.fetchActiveEnergy()
                    try await hkData.activeEnergyData = activeEnergy
                default:
                    break
                }
                
                isShowingAddData = false
            } catch STError.sharingDenied(let quantityType) {
                writeError = .sharingDenied(quantityType: quantityType)
                isShowingAlert = true
            } catch {
                writeError = .unableToCompleteRequest
                isShowingAlert = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        HealthDataListView(metric: .steps)
            .environment(HealthKitManager())
    }
}
