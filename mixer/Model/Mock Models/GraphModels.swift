//
//  GraphMetric.swift
//  mixer
//
//  Created by Jose Martinez on 1/16/23.
//

import SwiftUI

// MARK: Site Analytics View Model and Sample Data
struct GraphMetric: Identifiable {
    var id = UUID().uuidString
    var hour: Date
    var number: Double
    var animate: Bool = false
}
extension Date {
    // MARK: To Update Date For Particular Hour
    func updateHour(value: Int)->Date{
        let calendar = Calendar.current
        return calendar.date(bySettingHour: value, minute: 0, second: 0, of: self) ?? .now
    }
}

var followers: [GraphMetric] = [
    GraphMetric(hour: Date().updateHour(value: 10), number: 750),
    GraphMetric(hour: Date().updateHour(value: 11), number: 368),
    GraphMetric(hour: Date().updateHour(value: 12), number: 298),
    GraphMetric(hour: Date().updateHour(value: 13), number: 328),
    GraphMetric(hour: Date().updateHour(value: 14), number: 450),
    GraphMetric(hour: Date().updateHour(value: 15), number: 678),
    GraphMetric(hour: Date().updateHour(value: 16), number: 998),
    GraphMetric(hour: Date().updateHour(value: 17), number: 786),
    GraphMetric(hour: Date().updateHour(value: 18), number: 198),
    GraphMetric(hour: Date().updateHour(value: 19), number: 645),
    GraphMetric(hour: Date().updateHour(value: 20), number: 346),
]

var guests: [GraphMetric] = [
    GraphMetric(hour: Date().updateHour(value: 22), number: 89),
    GraphMetric(hour: Date().updateHour(value: 23), number: 102),
    GraphMetric(hour: Date().updateHour(value: 24), number: 90),
]
