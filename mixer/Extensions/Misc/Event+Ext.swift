//
//  Event+Ext.swift
//  mixer
//
//  Created by Peyton Lyons on 10/25/23.
//

import SwiftUI

extension Event {
    var activePlannerIds: [String]? {
        // Extract confirmed planners, splitting the combined key to get the user ID part
        var confirmedPlanners = plannerHostStatusMap.filter { $0.value == .confirmed }.compactMap { $0.key.split(separator: "-").first.map(String.init) }
        
        // If there's a primary planner, extract its user ID part and append
        if let primaryPlannerId = self.primaryPlannerId {
            confirmedPlanners.append(primaryPlannerId)
        }
        
        return confirmedPlanners.isEmpty ? nil : confirmedPlanners
    }
    
    var pendingPlannerIds: [String]? {
        // Extract pending planners, splitting the combined key to get the user ID part
        let pendingPlanners = plannerHostStatusMap.filter { $0.value == .pending }.compactMap { $0.key.split(separator: "-").first.map(String.init) }
        
        return pendingPlanners.isEmpty ? nil : pendingPlanners
    }
    
    var primaryPlannerId: String? {
        // Find the primary planner and split its combined key to get the user ID part
        if let primaryPlannerCombinedKey = plannerHostStatusMap.first(where: { $0.value == .primary })?.key.split(separator: "-").first.map(String.init) {
            return primaryPlannerCombinedKey
        }
        return nil
    }
    
    // Active Host IDs: Hosts that have confirmed planners
    var activeHostIds: [String]? {
        let activeHosts = plannerHostStatusMap.filter { $0.value == .confirmed }.compactMap { $0.key.split(separator: "-").last.map(String.init) }
        return activeHosts.isEmpty ? nil : activeHosts
    }

    // Pending Host IDs: Hosts that have planners pending confirmation
    var pendingHostIds: [String]? {
        let pendingHosts = plannerHostStatusMap.filter { $0.value == .pending }.compactMap { $0.key.split(separator: "-").last.map(String.init) }
        return pendingHosts.isEmpty ? nil : pendingHosts
    }

    // All Planner IDs: Combines both confirmed and pending planners, ensuring no duplicates
    var allPlannerIds: [String]? {
        let allPlanners = Set(plannerHostStatusMap.compactMap { $0.key.split(separator: "-").first.map(String.init) })
        return allPlanners.isEmpty ? nil : Array(allPlanners)
    }

    // All Host IDs: Combines both hosts of confirmed and pending planners, ensuring no duplicates
    var allHostIds: [String]? {
        let allHosts = Set(plannerHostStatusMap.compactMap { $0.key.split(separator: "-").last.map(String.init) })
        return allHosts.isEmpty ? nil : Array(allHosts)
    }
}
