//
//  Array+Ext.swift
//  Step Tracker
//
//  Created by Chris Shireman on 5/9/25.
//

import Foundation

extension Array where Element == Double {
    var average: Double {
        guard !self.isEmpty else { return 0 }
        let sum = self.reduce(0, +)
        return sum / Double(self.count)
    }
}
