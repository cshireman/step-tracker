//
//  ChartContainer.swift
//  Step Tracker
//
//  Created by Chris Shireman on 4/30/25.
//

import SwiftUI

enum ChartType {
    case stepBar(average: Int)
    case stepWeekdayPie
    case weightLine(average: Double)
    case weightDiffBar
    case activityBar(average: Int)
    case activityWeekdayPie
    case sleepBar(average: Int)
    case sleepWeekdayPie
}

struct ChartContainer<Content: View>: View {
    let chartType: ChartType
    
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading) {
            if isNav {
                navigationLinkView
            } else {
                titleView
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 12)
            }
            
            content()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
    
    var navigationLinkView: some View {
        NavigationLink(value: context) {
            HStack {
                titleView
                Spacer()
                Image(systemName: "chevron.right")
            }
        }
        .foregroundStyle(.secondary)
        .padding(.bottom, 12)
        .accessibilityHint("Tap for data in list view")
        .accessibilityRemoveTraits(.isButton)
    }
    
    var titleView: some View {
        VStack(alignment: .leading) {
            Label(title, systemImage: symbol)
                .font(.title3.bold())
                .foregroundStyle(context.color)
            
            Text(subtitle)
                .font(.caption)
        }
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityElement(children: .ignore)
    }
    
    var isNav: Bool {
        switch chartType {
        case .stepBar(_), .weightLine(_), .activityBar(_):
            return true
        default:
            return false
        }
    }
    
    var context: HealthMetricContext {
        switch chartType {
        case .stepBar(_), .stepWeekdayPie:
            return .steps
        case .weightLine(_), .weightDiffBar:
            return .weight
        case .activityBar(_), .activityWeekdayPie:
            return .activeEnergy
        case .sleepBar(_), .sleepWeekdayPie:
            return .sleep
        }
    }
    
    var title: String {
        switch chartType {
        case .stepBar(_):
            "Steps"
        case .stepWeekdayPie:
            "Averages"
        case .weightLine(_):
            "Weight"
        case .weightDiffBar:
            "Average Weight Change"
        case .activityBar(_):
            "Activity"
        case .activityWeekdayPie:
            "Average Activity"
        case .sleepBar(_):
            "Sleep Score"
        case .sleepWeekdayPie:
            "Average Sleep Score"
        }
    }
    
    var symbol: String {
        switch chartType {
        case .stepBar(_):
            "figure.walk"
        case .weightLine(_), .weightDiffBar:
            "figure"
        case .activityBar(_):
            "figure.running"
        case .stepWeekdayPie, .activityWeekdayPie, .sleepWeekdayPie:
            "calendar"
        case .sleepBar(_):
            "bed.double"
        }
    }
    
    var subtitle: String {
        switch chartType {
        case .stepBar(let average):
            "Avg: \(average.formatted()) steps"
        case .stepWeekdayPie:
            "Last 28 Days"
        case .weightLine(let average):
            "Avg: \(average.formatted(.number.precision(.fractionLength(1)))) lbs"
        case .weightDiffBar:
            "Per Weekday (Last 28 Days)"
        case .activityBar(let average):
            "Avg: \(average.formatted()) calories"
        case .activityWeekdayPie:
            "Last 28 Days"
        case .sleepBar(let average):
            "Avg: \(average.formatted())"
        case .sleepWeekdayPie:
            "Last 28 Days"
        }
    }
    
    var accessibilityLabel: String {
        switch chartType {
        case .stepBar(let average):
            "Bar chart, step count, last 28 days, average steps per day: \(average) steps"
        case .stepWeekdayPie:
            "Pie chart, average steps per weekday"
        case .weightLine(let average):
            "Line chart, weight, average weight: \(average.formatted(.number.precision(.fractionLength(1)))) lbs"
        case .weightDiffBar:
            "Bar chart, average weight difference per weekday"
        case .activityBar(let average):
            "Bar chart, activity, last 28 days, average calories burned per day: \(average) calories"
        case .activityWeekdayPie:
            "Pie chart, average calories burned per weekday"
        case .sleepBar(let average):
            "Bar chart, sleet, average sleep score: \(average)"
        case .sleepWeekdayPie:
            "Pie chart, avertage sleep score per weekday"
        }
    }
}

#Preview {
    ChartContainer(chartType: .stepBar(average: 15000)) {
        Text("Chart Goes Here")
            .frame(minHeight: 150)
    }
}
