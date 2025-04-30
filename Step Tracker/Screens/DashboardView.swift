//
//  DashboardView.swift
//  Step Tracker
//
//  Created by Chris Shireman on 4/20/25.
//

import SwiftUI
import Charts

enum HealthMetricContext: CaseIterable, Identifiable {
    case steps, weight

    var id: Self { self }
    
    var title: String {
        switch self {
        case .steps:
            return "Steps"
        case .weight:
            return "Weight"
        }
    }
}

struct DashboardView: View {
    @Environment(HealthKitManager.self) private var hkManager
    
    @State private var selectedStat: HealthMetricContext = .steps
    @State private var isShowingPermissionPrimingSheet: Bool = false
    
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
                        StepBarChart(selectedStat: selectedStat, chartData: hkManager.stepData)
                        StepPieChart(chartData: ChartMath.averageWeekdayCount(for: hkManager.stepData))
                    case .weight:
                        WeightLineChart(selectedStat: selectedStat, chartData: hkManager.weightData)
                        WeightBarChart(selectedStat: selectedStat, chartData: ChartMath.averageDailyWeightDiffs(for: hkManager.weightDiffData))
                    }
                }
                .padding()
            }
            .padding()
            .task {
                do {
                    try await hkManager.fetchStepCount()
                    try await hkManager.fetchWeights()
                    try await hkManager.fetchWeightsForDifferentials()
                } catch STError.authNotDetermined {
                    isShowingPermissionPrimingSheet = true
                } catch STError.noData {
                    print("❌ No data available")
                } catch {
                    print("❌ Unable to complete request")
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

        }
        .tint(isSteps ? .pink : .indigo)
    }

}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
