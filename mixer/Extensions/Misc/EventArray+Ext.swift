//
//  EventArray+Ext.swift
//  mixer
//
//  Created by Peyton Lyons on 7/3/23.
//

import Foundation

extension Array where Element == Event {
    func sortedByTimePosted(_ ascending: Bool = true) -> [Event] {
        return self.sorted {
            if ascending {
                return $0.timePosted > $1.timePosted
            } else {
                return $0.timePosted < $1.timePosted
            }
        }
    }
    
    
    func sortedByStartDate(_ ascending: Bool = true) -> [Event] {
        return self.sorted {
            if ascending {
                return $0.startDate < $1.startDate
            } else {
                return $0.startDate > $1.startDate
            }
        }
    }
    
    
    func sortedByEndDate(_ ascending: Bool = true) -> [Event] {
        return self.sorted {
            if ascending {
                return $0.endDate < $1.endDate
            } else {
                return $0.endDate > $1.endDate
            }
        }
    }
}
