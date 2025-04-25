//
//  Date+Ext.swift
//  Step Tracker
//
//  Created by Chris Shireman on 4/25/25.
//

import Foundation

extension Date {
    var weekdayInt: Int {
        return Calendar.current.component(.weekday, from: self)
    }
    
    var weekdayTitle: String {
        self.formatted(.dateTime.weekday(.wide))
    }
}
