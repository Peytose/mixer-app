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
        VStack(spacing: 15) {
            VStack(alignment: .leading) {
                Spacer()
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(event.title)
                        .font(.title).bold()
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    
                    Text("Hosted by \(event.hostName)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 15)
                .padding(.bottom, 5)
                .padding(.top, 8)
                .background(
                    Rectangle()
                        .fill(.ultraThinMaterial.opacity(0.98))
                        .background(Color.mixerBackground.opacity(0.1))
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .padding(-1)
                        .blur(radius: 9)
                        .padding(.horizontal, -20)
                        .padding(.bottom, -10)
                        .padding(.top, 3)
                )
            }
            .background(
                KFImage(URL(string: event.eventImageUrl))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .matchedGeometryEffect(id: event.eventImageUrl, in: namespace)
            )
            .mask(
                RoundedRectangle(cornerRadius: 20)
            )
            
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text(hasStarted ? "Ends at \(event.endDate.getTimestampString(format: "h:mm a"))": event.startDate.getTimestampString(format: "EEEE, h:mm a"))
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                        
                        Text("\(event.type.rawValue)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 6) {
                        if let amenities = event.amenities {
                            if amenities.contains(where: { $0.rawValue.contains("Beer") || $0.rawValue.contains("Alcoholic Drinks") }) {
                                Image(systemName: "drop.fill")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 18, height: 18)
                                
                                Text("Wet Event")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                    .offset(y: 2)
                            } else {
                                ZStack {
                                    Image(systemName: "drop.fill")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 18, height: 18)
                                    
                                    Text("/")
                                        .font(.title)
//                                        .fontWeight(.semibold)
                                        .foregroundColor(.red)
                                        .rotationEffect(Angle(degrees: 30))
                                }
                                
                                Text("Dry Event")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                    .offset(y: 2)
                            }
                        }
                    }
                }
                
                Text(event.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(3)
                    .minimumScaleFactor(0.75)
                    .multilineTextAlignment(.leading)
            }
            .padding(.trailing)
        }
    }
}

//struct EventCellView_Previews: PreviewProvider {
//    static var previews: some View {
//        EventCellView(event: Mockdata.event, hasStarted: false)
//            .preferredColorScheme(.dark)
//    }
//}
