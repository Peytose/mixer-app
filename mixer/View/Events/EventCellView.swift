//
//  EventCellView.swift
//  mixer
//
//  Created by Peyton Lyons on 1/27/23.
//
//
import SwiftUI
import Kingfisher

struct EventCellView: View {
    let event: CachedEvent
    let hasStarted: Bool
    var namespace: Namespace.ID
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading) {
                Spacer()
                
                //MARK: Title and host
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.title)
                        .primaryHeading()
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    
                    Text("Hosted by \(event.hostName)")
                        .footnote()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .padding(.leading, 8)
                //blur behind text
                .background { backgroundBlur }
            }
            //image
            .background { image }
            //mask to create desired rounded corners
            .mask(
                RoundedRectangle(cornerRadius: 30)
            )
            
            //More info section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(hasStarted ? "Ends at \(event.endDate.getTimestampString(format: "h:mm a"))": event.startDate.getTimestampString(format: "EEEE, h:mm a"))
                            .secondarySubheading()
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                        
                        Text("\(event.type.rawValue)")
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
            .background(Color.mixerBackground.opacity(0.1))
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
        EventCellView(event: CachedEvent(from: Mockdata.event), hasStarted: false, namespace: namespace)
            .preferredColorScheme(.dark)
    }
}
