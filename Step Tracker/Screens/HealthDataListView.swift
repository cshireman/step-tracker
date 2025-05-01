//
//  Healt.swift
//  Step Tracker
//
//  Created by Chris Shireman on 4/23/25.
//

import SwiftUI

struct HealthDataListView: View {
    @Environment(HealthKitManager.self) private var hkManager
    @State private var isShowingAddData: Bool = false
    @State private var addDataDate: Date = .now
    @State private var valueToAdd: String = ""
    
    @State private var isShowingAlert: Bool = false
    @State private var writeError: STError = .noData
    
    var metric: HealthMetricContext
    var listData: [HealthMetric] {
        switch metric {
        case .steps:
            return hkManager.stepData
        case .weight:
            return hkManager.weightData
        case .activeEnergy:
            return hkManager.activeEnergyData
        case .sleep:
            return hkManager.sleepData
        }
    }
    
    var body: some View {
        List(listData.reversed()) { data in
            HStack {
                Text(data.date, format: .dateTime.month().day().year())
                Spacer()
                Text(data.value, format: .number.precision(.fractionLength(metric == .steps ? 0 : 1)))
            }
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
                    Text(metric.title)
                    Spacer()
                    TextField("Value", text: $valueToAdd)
                        .keyboardType(metric == .steps ? .numberPad : .decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 140)
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
                        Task {
                            guard let value = Double(valueToAdd) else {
                                writeError = .invalidInput
                                isShowingAlert = true
                                valueToAdd = ""
                                return
                            }
                            
                            switch metric {
                            case .steps:
                                do {
                                    try await hkManager.addStepData(for: addDataDate, value: value)
                                    try await hkManager.fetchStepCount()
                                    isShowingAddData = false
                                } catch STError.sharingDenied(let quantityType) {
                                    writeError = .sharingDenied(quantityType: quantityType)
                                    isShowingAlert = true
                                } catch {
                                    writeError = .unableToCompleteRequest
                                    isShowingAlert = true
                                }
                            case .weight:
                                do {
                                    try await hkManager.addWeightData(for: addDataDate, value: value)
                                    try await hkManager.fetchWeights()
                                    try await hkManager.fetchWeightsForDifferentials()
                                    isShowingAddData = false
                                } catch STError.sharingDenied(let quantityType) {
                                    writeError = .sharingDenied(quantityType: quantityType)
                                    isShowingAlert = true
                                } catch {
                                    writeError = .unableToCompleteRequest
                                    isShowingAlert = true
                                }
                            case .activeEnergy:
                                do {
                                    try await hkManager.addActiveEneryData(for: addDataDate, value: value)
                                    try await hkManager.fetchActiveEnergy()
                                    try await hkManager.fetchWeightsForDifferentials()
                                    isShowingAddData = false
                                } catch STError.sharingDenied(let quantityType) {
                                    writeError = .sharingDenied(quantityType: quantityType)
                                    isShowingAlert = true
                                } catch {
                                    writeError = .unableToCompleteRequest
                                    isShowingAlert = true
                                }
                            default:
                                break
                            }
                            
                            
                        }
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
}

#Preview {
    NavigationStack {
        HealthDataListView(metric: .steps)
            .environment(HealthKitManager())
    }
}
