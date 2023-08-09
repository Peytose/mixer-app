//
//  EventListView.swift
//  mixer
//
//  Created by Peyton Lyons on 1/26/23.
//

import SwiftUI

struct EventListView<CellView: View>: View {
    var events: [Event] = []
    let hasStarted: Bool
    var namespace: Namespace.ID
    @Binding var selectedEvent: Event?
    @Binding var showEventView: Bool
    let cellView: (Event, Bool, Namespace.ID) -> CellView
    
    init(events: [Event], hasStarted: Bool, namespace: Namespace.ID, selectedEvent: Binding<Event?>, showEventView: Binding<Bool>, cellView: @escaping (Event, Bool, Namespace.ID) -> CellView) {
        self.events = events
        self.hasStarted = hasStarted
        self.namespace = namespace
        self._selectedEvent = selectedEvent
        self._showEventView = showEventView
        self.cellView = cellView
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if !events.isEmpty {
                ForEach(events) { event in
                    CustomStickyHeader(headerView: {
                        CellDateView(event: event, hasStarted: hasStarted)
                    }, contentView: {
                        cellView(event, hasStarted, namespace)
                    })
                    .frame(height: 380)
                    .onTapGesture {
                        withAnimation(.openCard) {
                            self.selectedEvent = event
                            self.showEventView = true
                        }
                    }
                }
            } else {
                Text("Nothin' to see here 🙅‍♂️")
                    .foregroundColor(.secondary)
                    .frame(width: UIScreen.main.bounds.width / 1.3, height: 300, alignment: .center)
            }
        }
    }
}

fileprivate struct CellDateView: View {
    let event: Event
    let hasStarted: Bool
    
    var body: some View {
        Rectangle()
            .fill(Color.theme.backgroundColor)
            .ignoresSafeArea()
            .overlay {
                VStack(alignment: .center, spacing: 12) {
                    VStack {
                        Text(hasStarted ? event.startDate.getTimestampString(format: "h:mm") : event.startDate.getTimestampString(format: "MMM"))
                            .font(.headline)
                            .fontWeight(.regular)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                        
                        Text(hasStarted ? event.startDate.getTimestampString(format: "a") : event.startDate.getTimestampString(format: "d"))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    
                    Image(systemName: event.isInviteOnly ? "lock.fill" : "globe")
                        .imageScale(.large)
                        .padding(.top, -7)
                }
                .padding(.top, 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
    }
}

//struct EventListView_Previews: PreviewProvider {
//    @Namespace static var namespace
//
//    static var previews: some View {
//        EventListView(namespace: namespace, hasStarted: true)
//            .preferredColorScheme(.dark)
//    }
//}