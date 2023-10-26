//
//  Event+Ext.swift
//  mixer
//
//  Created by Peyton Lyons on 10/25/23.
//

import SwiftUI

extension Event {
    var activePlannerIds: [String]? {
        var confirmedPlanners = plannerHostStatusMap.filter({ $0.value == .confirmed }).compactMap({ $0.key.plannerId })
        
        if let primaryPlanner = self.primaryPlannerKey?.plannerId {
            confirmedPlanners.append(primaryPlanner)
        }
        
        return confirmedPlanners.isEmpty ? nil : confirmedPlanners
    }
    
    var primaryPlannerKey: String? {
        return plannerHostStatusMap.first(where: { $0.value == .primary })?.key
    }
}
