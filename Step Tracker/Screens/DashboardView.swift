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
                
                try await hkManager.stepData = steps
                try await hkManager.weightData = weights
                try await hkManager.weightDiffData = weightDiffs
                try await hkManager.activeEnergyData = activeEnergy
                try await hkManager.sleepData = sleep
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
