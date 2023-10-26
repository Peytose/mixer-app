//
//  EventCellView.swift
//  mixer
//
//  Created by Peyton Lyons on 1/27/23.
//
//

import SwiftUI
import FirebaseFirestore
import Kingfisher

struct EventCellView: View {
    let event: Event
    var namespace: Namespace.ID

    var dateInfoString: String {
        let currentTimestamp = Timestamp(date: Date())
        let oneWeekBefore = Timestamp(date: Calendar.current.date(byAdding: .day, value: -7, to: event.startDate.dateValue())!)
        
        if oneWeekBefore > currentTimestamp {
            return event.startDate.getTimestampString(format: "EEEE, MMM d, h:mm a")
        } else if event.startDate > currentTimestamp {
            return event.startDate.getTimestampString(format: "EEEE h:mm a")
        } else if event.endDate > currentTimestamp {
            return "Ends at \(event.endDate.getTimestampString(format: "h:mm a"))"
        } else {
            return "Happened back on \(event.startDate.getTimestampString(format: "MMM d"))"
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading) {
                Spacer()
                
                //MARK: Title and host(s)
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.title)
                        .primaryHeading()
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    
                    Text("Hosted by \(event.hostNames.joinedWithCommasAndAnd())")
                        .footnote()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .padding(.leading, 8)
                .background { backgroundBlur }
            }
            .background { image }
            .mask(RoundedRectangle(cornerRadius: 30))
            
            //More info section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(dateInfoString)
                            .secondarySubheading()
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                        
                        Text("\(event.type.description)")
                            .subheadline()
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        if let amenities = event.amenities {
                            if amenities.contains(where: { $0.rawValue.contains("Beer") || $0.rawValue.contains("Alcoholic Drinks") }) {
                                Image(systemName: "drop.fill")
                                    .font(.title2)
                                
                                Text("Wet Event")
                                    .caption()
                            } else {
                                ZStack {
                                    Image(systemName: "drop.fill")
                                        .font(.title2)
                                    
                                    Text("/")
                                        .font(.title)
                                        .foregroundColor(.red)
                                        .rotationEffect(Angle(degrees: 30))
                                }
                                
                                Text("Dry Event")
                                    .caption()
                            }
                        }
                    }
                }
                
                Text(event.description)
                    .subheadline(color: .white.opacity(0.8))
                    .lineLimit(3)
                    .minimumScaleFactor(0.75)
                    .multilineTextAlignment(.leading)
            }
            .padding(.trailing)
        }
    }
}

extension EventCellView {
    var backgroundBlur: some View {
        Rectangle()
            .fill(.ultraThinMaterial.opacity(0.98))
            .background(Color.theme.backgroundColor.opacity(0.1))
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(-1)
            .blur(radius: 9)
            .padding(.horizontal, -20)
            .padding(.bottom, -10)
            .padding(.top, 3)
    }
    
    var image: some View {
        KFImage(URL(string: event.eventImageUrl))
            .resizable()
            .aspectRatio(contentMode: .fill)
            .matchedGeometryEffect(id: event.eventImageUrl, in: namespace)
    }
}

struct EventCellView_Previews: PreviewProvider {
    @Namespace static var namespace
    static var previews: some View {
        EventCellView(event: dev.mockEvent, namespace: namespace)
            .preferredColorScheme(.dark)
    }
}
