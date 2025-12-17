//
//  DataAnalyzer.swift
//  Step Tracker
//
//  Created by Chris Shireman on 12/16/25.
//

import Foundation
import FoundationModels
import Playgrounds

@available(iOS 26, *)
@Observable
final class DataAnalyzer {
    static let shared = DataAnalyzer()
    let model: SystemLanguageModel = .default

    private init() { }

    func analyzeHealthData() async {
        let session = LanguageModelSession(tools: [HealthDataTool()],
                                           instructions: "You are a high energy motivational fitness coach.  You love to analyze step count and weight data to surface valuable insights and motivate people along their fitness journey and help them with their fitness goals.")


        let prompt = """
            Use the fetchStepsAndWeight tool to get stats about the user’s recent step count and weight. 
            Each stat is labeled with a value such as stepsTotal: value. The numberOfDays stat represents how many 
            days are in the dataset.

            Use these stats to share interesting insights with the user about their weight and step count data. Always 
            mention their highest step count day to highlight an achievement. Always mention the total weight lost or 
            gained and provide encouragement along with some healthy tips about weight loss.

            The output should be 2 to 3 short paragraphs, human readable, and easy to digest. It should read as if a fitness 
            coach is talking to the user and cheering on their fitness journey. Focus mostly on data and insights 
            with a touch of motivational language. Only use an emoji after the final line of your response.
            """

        do {
            let response = try await session.respond(to: prompt)
            print(response.content)
        } catch {
            print(error.localizedDescription)
        }
    }
}

@available(iOS 26, *)
struct HealthDataTool: Tool {
    var name: String = "fetchStepsAndWeight"
    var description: String = "Fetch the user's recent step count and weight data from HealthKit."

    @Generable()
    struct Arguments { }

    func call(arguments: Arguments) async throws -> String {
        let hkManager = HealthKitManager()

        let steps = try await hkManager.fetchStepCount().map { $0.value }
        let weights = try await hkManager.fetchWeights(daysBack: 28).map { $0.value }

        let stepsHigh = Int(steps.max() ?? 0)
        let stepsLow = Int(steps.min() ?? 0)
        let stepsTotal = Int(steps.reduce(0, +))
        let stepsAvg = Int(Double(stepsTotal) / Double(steps.count).rounded(.up))

        let weightHigh = Int(weights.max() ?? 0)
        let weightLow = Int(weights.min() ?? 0)

        let weightDiff = (weights.first ?? 0) - (weights.last ?? 0)

        return """
            stepsHighestValue: \(stepsHigh),
            stepsLowestValue: \(stepsLow),
            stepsTotal: \(stepsTotal),
            stepsAverage: \(stepsAvg),
            weightHighestValue: \(weightHigh),
            weightLowestValue: \(weightLow),
            overallWeightDiff: \(weightDiff),
            numberOfDays: \(steps.count)
            """
    }
}

//@available(iOS 26, *)
//#Playground {
//    let session = LanguageModelSession()
//    let prompt = "What are the number of recommended steps per day for a 40 year old male?"
//
//    do {
//        let response = try await session.respond(to: prompt)
//        print(response.content)
//    } catch {
//        print(error)
//    }
//}
