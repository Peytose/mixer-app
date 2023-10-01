//
//  DeadlineOption.swift
//  mixer
//
//  Created by Peyton Lyons on 9/9/23.
//

import SwiftUI
import FirebaseFirestore

enum DeadlineOption: Int, CaseIterable, CustomStringConvertible {
    case weekBefore
    case threeDaysBefore
    case oneDayBefore
    case twelveHoursBefore
    case sixHoursBefore
    case twoHoursBefore
    case oneHourBefore
    case custom
    
    var description: String {
        switch self {
        case .weekBefore:
            return "1 week before the event"
        case .threeDaysBefore:
            return "3 days before the event"
        case .oneDayBefore:
            return "1 day before the event"
        case .twelveHoursBefore:
            return "12 hours before the event"
        case .sixHoursBefore:
            return "6 hours before the event"
        case .twoHoursBefore:
            return "2 hours before the event"
        case .oneHourBefore:
            return "1 hour before the event"
        case .custom:
            return "Custom"
        }
    }
    
    
    func deadline(from startDate: Date) -> Date {
        let calendar = Calendar.current
        
        var dateComponents = DateComponents()
        switch self {
        case .weekBefore:
            dateComponents.day = -7
        case .threeDaysBefore:
            dateComponents.day = -3
        case .oneDayBefore:
            dateComponents.day = -1
        case .twelveHoursBefore:
            dateComponents.hour = -12
        case .sixHoursBefore:
            dateComponents.hour = -6
        case .twoHoursBefore:
            dateComponents.hour = -2
        case .oneHourBefore:
            dateComponents.hour = -1
        case .custom:
            return startDate // You'll handle custom values separately
        }
        
        return calendar.date(byAdding: dateComponents, to: startDate)!
    }
}
