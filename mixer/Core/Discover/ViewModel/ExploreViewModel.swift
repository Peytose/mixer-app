//
//  ExploreViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 1/27/23.
//

import SwiftUI
import FirebaseFirestore
import Firebase
import Combine

enum EventSection: Int, CustomStringConvertible, CaseIterable {
    case current
    case upcoming
    
    var description: String {
        switch self {
        case .current: return "Current Events"
        case .upcoming: return "Upcoming Events"
        }
    }
}

final class ExploreViewModel: ObservableObject {
    @Published var selectedEventSection = EventSection.current
    
    
    func separateEventsForSection(_ events: [Event]) -> [Event] {
        var separatedEvents = [Event]()
        
        if selectedEventSection == .current {
            separatedEvents = events.filter({ $0.startDate > Timestamp() })
        } else if selectedEventSection == .upcoming {
            separatedEvents = events.filter({ $0.startDate < Timestamp() })
        }
        
        print("")
        return separatedEvents.sortedByStartDate()
    }
}
