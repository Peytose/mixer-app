//
//  PlannerStatus.swift
//  mixer
//
//  Created by Peyton Lyons on 10/24/23.
//

import Foundation

enum PlannerStatus: Int, Codable, CaseIterable {
    case primary = -1   // The main or primary planner responsible for the event
    case pending        // Planner has been added but hasn't confirmed yet
    case confirmed      // Planner has accepted and confirmed their role
    case declined       // Planner has declined their role in the event
}
