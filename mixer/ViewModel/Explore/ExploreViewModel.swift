//
//  ExploreViewModel.swift
//  mixer
//
//  Created by Peyton Lyons on 1/27/23.
//

import SwiftUI
import FirebaseFirestore
import Firebase

final class ExploreViewModel: ObservableObject {
    @Published var eventSection = EventSection.today
    @Published var isRefreshing = false
    @Published var todayEvents  = [CachedEvent]()
    @Published var futureEvents = [CachedEvent]()
    @Published var hosts        = [CachedHost]()
    
    enum EventSection: String, CaseIterable {
        case today = "Events Today"
        case future = "Future Events"
    }
    
    
    @ViewBuilder func stickyHeader() -> some View {
        HStack {
            ForEach(EventSection.allCases, id: \.self) { [self] section in
                VStack(spacing: 8) {
                    
                    Text(section.rawValue)
                        .font(.title3.weight(.semibold))
                        .foregroundColor(eventSection == section ? .white : .gray)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    
                    ZStack{
                        if eventSection == section {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(Color.mixerIndigo)
                        }
                        else {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(.clear)
                        }
                    }
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
        .padding(.top, 70)
        .padding(.bottom, 0)
    }
    
    
    @MainActor func refresh() {
        self.isRefreshing = true
        EventCache.shared.clearCache()
        HostCache.shared.clearCache()

        getHosts()
        getTodayEvents()
        getFutureEvents()

        self.isRefreshing = false
    }
    
    
    @MainActor func getHosts() {
        Task {
            do {
                self.hosts = try await HostCache.shared.fetchHosts(filter: .all)
            } catch {
                print("DEBUG: Error getting hosts for explore. \(error.localizedDescription)")
            }
        }
    }
    
    @MainActor func getTodayEvents() {
        Task {
            self.todayEvents = await UserService.getTodayEvents()
        }
    }
    
    
    @MainActor func getFutureEvents() {
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let endOfToday = Calendar.current.startOfDay(for: tomorrow)
        
        Task {
            do {
                self.futureEvents = try await EventCache.shared.fetchEvents(filter: .unfinished)
                    .filter({ $0.startDate.compare(Timestamp(date: endOfToday)) == .orderedDescending})
                    .sorted(by: { event1, event2 in
                        event1.startDate.compare(event2.startDate) == .orderedAscending
                    })
                print("DEBUG: ✅future events: \(todayEvents)")
            } catch {
                print("DEBUG: Error getting future events for explore. \(error)")
            }
        }
    }
}
