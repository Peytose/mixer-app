//
//  Notification+Ext.swift
//  mixer
//
//  Created by Peyton Lyons on 8/27/23.
//

import SwiftUI

extension Notification {
    var timestampString: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: self.timestamp.dateValue(), to: Date()) ?? ""
    }
}
