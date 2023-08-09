//
//  ExploreViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 1/27/23.
//

import SwiftUI
import FirebaseFirestore
import Firebase

enum EventSection: String, CaseIterable {
    case current  = "Current Event"
    case upcoming = "Upcoming Events"
}

final class ExploreViewModel: ObservableObject {
    @Published var eventSection = EventSection.current
    
    
    func separateEventsForSection(_ events: [Event]) -> [Event] {
        var separatedEvents = [Event]()
        
        if eventSection == .current {
            separatedEvents = events.filter({ $0.startDate > Timestamp() })
        } else if eventSection == .upcoming {
            separatedEvents = events.filter({ $0.startDate < Timestamp() })
        }
        
        print("")
        return separatedEvents.sortedByStartDate()
    }
    
    
    @ViewBuilder
    func stickyHeader() -> some View {
        HStack {
            ForEach(EventSection.allCases, id: \.self) { [self] section in
                VStack(spacing: 8) {
                    Text(section.rawValue)
                        .font(.title3.weight(.semibold))
                        .foregroundColor(eventSection == section ? .white : .gray)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(eventSection == section ? Color.theme.mixerIndigo : .clear)
                        .padding(.horizontal,8)
                        .frame(height: 4)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        self.eventSection = section
                    }
                }
            }
        }
        .padding(.horizontal)
        .background(Color.theme.backgroundColor)
    }
}
