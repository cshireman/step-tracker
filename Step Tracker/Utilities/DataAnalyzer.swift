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
