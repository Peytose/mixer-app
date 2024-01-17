//
//  TimestampManager.swift
//  mixer
//
//  Created by Peyton Lyons on 1/16/24.
//

import SwiftUI

class TimestampManager {
    static let shared = TimestampManager()
    private var lastFetchedTimestamps = [String: Date]()

    func updateTimestamp(for key: String) {
        lastFetchedTimestamps[key] = Date()
    }

    func isDataFresh(for key: String, freshnessDuration: TimeInterval) -> Bool {
        guard let lastFetched = lastFetchedTimestamps[key] else { return false }
        return Date().timeIntervalSince(lastFetched) < freshnessDuration
    }
}
