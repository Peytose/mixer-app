//
//  Timestamp+Ext.swift
//  mixer
//
//  Created by Peyton Lyons on 1/29/23.
//

import SwiftUI
import FirebaseFirestore

extension Timestamp {
    func getTimestampString(format: String) -> String {
        let date = self.dateValue()
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    func notificationTimeString() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: self.dateValue(), to: Date()) ?? ""
    }
}
