//
//  EventArray+Ext.swift
//  mixer
//
//  Created by Peyton Lyons on 7/3/23.
//

import Foundation

extension Array where Element == CachedEvent {
    func sortedByStartDate() -> [CachedEvent] {
        return self.sorted {
            return $0.timePosted > $1.timePosted
        }
    }
}
