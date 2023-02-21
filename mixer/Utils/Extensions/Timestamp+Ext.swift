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
}
