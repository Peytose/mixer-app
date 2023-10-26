//
//  Event+Ext.swift
//  mixer
//
//  Created by Peyton Lyons on 10/25/23.
//

import SwiftUI

extension Event {
    var activePlannerKeys: [String] {
        let confirmedPlanners = plannerHostStatusMap.filter { $0.value == .confirmed }.map { $0.key }
        let primaryPlanner = plannerHostStatusMap.filter { $0.value == .primary }.map { $0.key }
        return confirmedPlanners + primaryPlanner
    }
    
    var primaryPlannerKey: String? {
        return plannerHostStatusMap.first(where: { $0.value == .primary })?.key
    }
}
