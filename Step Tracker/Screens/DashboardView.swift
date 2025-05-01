//
//  DashboardView.swift
//  Step Tracker
//
//  Created by Chris Shireman on 4/20/25.
//

import SwiftUI
import Charts

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

struct DashboardView: View {
    @Environment(HealthKitManager.self) private var hkManager
    
    @State private var selectedStat: HealthMetricContext = .steps
    @State private var isShowingPermissionPrimingSheet: Bool = false
    @State private var isShowingAlert: Bool = false
    
    @State private var fetchError: STError = .noData
    
    var isSteps: Bool { selectedStat == .steps }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Picker("Selected Stat", selection: $selectedStat) {
                        ForEach(HealthMetricContext.allCases) {
                            Text($0.title)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    switch selectedStat {
                    case .steps:
                        StepBarChart(chartData: ChartHelper.convert(data: hkManager.stepData))
                        StepPieChart(chartData: ChartMath.averageWeekdayCount(for: hkManager.stepData))
                    case .weight:
                        WeightLineChart(chartData: ChartHelper.convert(data: hkManager.weightData))
                        WeightBarChart(chartData: ChartMath.averageDailyWeightDiffs(for: hkManager.weightDiffData))
                    case .activeEnergy:
                        ActiveEnergyChart(chartData: ChartHelper.convert(data: hkManager.activeEnergyData))
                        ActiveEnergyPieChart(chartData: ChartMath.averageWeekdayCount(for: hkManager.activeEnergyData))
                    case .sleep:
                        SleepBarChart(chartData: ChartHelper.convert(data: hkManager.sleepData))
                        SleepPieChart(chartData: ChartMath.averageWeekdayCount(for: hkManager.sleepData))
                    }
                }
                .padding()
            }
            .padding()
            .task {
                do {
                    try await hkManager.fetchActiveEnergy()
                    try await hkManager.fetchStepCount()
                    try await hkManager.fetchWeights()
                    try await hkManager.fetchWeightsForDifferentials()
                    try await hkManager.fetchSleep()
                } catch STError.authNotDetermined {
                    isShowingPermissionPrimingSheet = true
                } catch STError.noData {
                    fetchError = .noData
                    isShowingAlert = true
                } catch {
                    fetchError = .unableToCompleteRequest
                    isShowingAlert = true
                }
                
            }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(metric: metric)
            }
            .sheet(isPresented: $isShowingPermissionPrimingSheet) {
                //fetch health data
            } content: {
                HealthKitPermissionPrimingView()
            }
            .alert(isPresented: $isShowingAlert, error: fetchError) { fetchError in
                //Actions
            } message: { fetchError in
                Text(fetchError.failureReason ?? "")
            }

        }
        .tint(isSteps ? .pink : .indigo)
    }

}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
