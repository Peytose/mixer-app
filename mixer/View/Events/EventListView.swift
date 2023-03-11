//
//  EventListView.swift
//  mixer
//
//  Created by Peyton Lyons on 1/26/23.
//

import SwiftUI

struct EventListView: View {
    var events: [CachedEvent] = []
    let hasStarted: Bool
    let namespace: Namespace.ID
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if !events.isEmpty {
                ForEach(events) { event in
                    NavigationLink(destination: EventDetailView(viewModel: EventDetailViewModel(event: event),
                                                                namespace: namespace)) {
                        CustomStickyHeaderView(headerView: { CellDateView(event: event, hasStarted: hasStarted) },
                                               contentView: { EventCellView(event: event, hasStarted: hasStarted) })
                        
                    }
                    .frame(height: 380)
                }
            } else {
                Text("Nothin' to see here. 🙅‍♂️")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .frame(width: UIScreen.main.bounds.width / 1.3, height: 300, alignment: .center)
            }
        }
    }
}

fileprivate struct CellDateView: View {
    let event: CachedEvent
    let hasStarted: Bool
    
    var body: some View {
        Rectangle()
            .fill(Color.mixerBackground)
            .ignoresSafeArea()
            .overlay {
                VStack(alignment: .center) {
                    Text(hasStarted ? event.startDate.getTimestampString(format: "h:mm") : event.startDate.getTimestampString(format: "MMM"))
                        .font(.headline)
                        .fontWeight(.regular)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    
                    Text(hasStarted ? event.startDate.getTimestampString(format: "a") : event.startDate.getTimestampString(format: "d"))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
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
