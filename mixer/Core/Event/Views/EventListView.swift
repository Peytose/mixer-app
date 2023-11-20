//
//  EventListView.swift
//  mixer
//
//  Created by Peyton Lyons on 1/26/23.
//

import SwiftUI

struct EventListView<CellView: View>: View {
    @EnvironmentObject var eventManager: EventManager
    var events: [Event] = []
    var namespace: Namespace.ID
    let cellView: (Event, Namespace.ID) -> CellView
    
    init(events: [Event],
         namespace: Namespace.ID,
         cellView: @escaping (Event, Namespace.ID) -> CellView) {
        self.events = events
        self.namespace = namespace
        self.cellView = cellView
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if !events.isEmpty {
                ForEach(events) { event in
                    StickyDateHeader(headerView: {
                        CellDateView(event: event, hasStarted: event.isEventCurrentlyHappening())
                    }, contentView: {
                        cellView(event, namespace)
                    })
                    .frame(height: 380)
                    .onTapGesture {
                        withAnimation(.openCard) {
                            eventManager.selectedEvent = event
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
                VStack(alignment: .center, spacing: 5) {
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
                    
                    Image(systemName: event.isInviteOnly ? "door.left.hand.closed" : "door.left.hand.open")
                        .imageScale(.large)
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
