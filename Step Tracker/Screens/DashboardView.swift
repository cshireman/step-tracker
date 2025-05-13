//
//  DashboardView.swift
//  Step Tracker
//
//  Created by Chris Shireman on 4/20/25.
//

import SwiftUI
import Charts

struct DashboardView: View {
    @Environment(HealthKitManager.self) private var hkManager
    @Environment(HealthKitData.self) private var hkData
    
    @State private var selectedStat: HealthMetricContext = .steps
    @State private var isShowingPermissionPrimingSheet: Bool = false
    @State private var isShowingAlert: Bool = false
    
    @State private var fetchError: STError = .noData
    
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
                        StepBarChart(chartData: ChartHelper.convert(data: hkData.stepData))
                        StepPieChart(chartData: ChartHelper.averageWeekdayCount(for: hkData.stepData))
                    case .weight:
                        WeightLineChart(chartData: ChartHelper.convert(data: hkData.weightData))
                        WeightBarChart(chartData: ChartHelper.averageDailyWeightDiffs(for: hkData.weightDiffData))
                    case .activeEnergy:
                        ActiveEnergyChart(chartData: ChartHelper.convert(data: hkData.activeEnergyData))
                        ActiveEnergyPieChart(chartData: ChartHelper.averageWeekdayCount(for: hkData.activeEnergyData))
                    case .sleep:
                        SleepBarChart(chartData: ChartHelper.convert(data: hkData.sleepData))
                        SleepPieChart(chartData: ChartHelper.averageWeekdayCount(for: hkData.sleepData))
                    }
                }
                .padding()
            }
            .padding()
            .onAppear {
                fetchHealthData()
            }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(metric: metric)
            }
            .fullScreenCover(isPresented: $isShowingPermissionPrimingSheet) {
                fetchHealthData()
            } content: {
                HealthKitPermissionPrimingView()
            }
            .alert(isPresented: $isShowingAlert, error: fetchError) { fetchError in
                //Actions
            } message: { fetchError in
                Text(fetchError.failureReason ?? "")
            }

        }
        .tint(selectedStat == .steps ? .pink : .indigo)
    }

    private func fetchHealthData() {
        Task {
            do {
                async let steps = hkManager.fetchStepCount()
                async let weights = hkManager.fetchWeights(daysBack: 28)
                async let weightDiffs = hkManager.fetchWeights(daysBack: 29)
                async let activeEnergy = hkManager.fetchActiveEnergy()
                async let sleep = hkManager.fetchSleep()
                
                try await hkData.stepData = steps
                try await hkData.weightData = weights
                try await hkData.weightDiffData = weightDiffs
                try await hkData.activeEnergyData = activeEnergy
                try await hkData.sleepData = sleep
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
    }
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
