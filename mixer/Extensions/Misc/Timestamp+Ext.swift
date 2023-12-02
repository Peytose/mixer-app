//
//  Timestamp+Ext.swift
//  mixer
//
//  Created by Peyton Lyons on 1/29/23.
//

import SwiftUI
import FirebaseFirestore
import Firebase

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
    
    
    func calculateAge() -> Int {
        let calendar = Calendar.current
        let birthDate = self.dateValue()
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: now)
        return ageComponents.year ?? 0
    }
}

extension Timestamp: Comparable {
    public static func < (lhs: Timestamp, rhs: Timestamp) -> Bool {
        if lhs.seconds == rhs.seconds {
            return lhs.nanoseconds < rhs.nanoseconds
        } else {
            return lhs.seconds < rhs.seconds
        }
    }
}
