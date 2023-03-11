//
//  EventInfoView.swift
//  mixer
//
//  Created by Peyton Lyons on 2/22/23.
//

import SwiftUI
import Kingfisher
import CoreLocation

struct EventInfoView: View {
    let event: CachedEvent
    let host: CachedHost
    let unsave: () -> Void
    let save: () -> Void
    let coordinates: CLLocationCoordinate2D?
    @Binding var showAllAmenities: Bool
    var namespace: Namespace.ID
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            EventModal(event: event,
                       unsave: unsave,
                       save: save,
                       namespace: namespace)
            
            Divider()
            
            NavigationLink {
                HostDetailView(viewModel: HostDetailViewModel(host: host),
                               namespace: namespace)
            } label: {
                HostedBySection(type: event.type,
                                host: host,
                                ageLimit: event.ageLimit,
                                cost: event.cost,
                                hasAlcohol: event.alcoholPresence,
                                namespace: namespace)
            }
            
            Divider()
            
            Text(event.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(4)
            
            Divider()
            
            VStack(alignment: .leading) {
                Text("What this event offers")
                    .font(.title2)
                    .bold()
                
                ForEach(event.amenities.shuffled().prefix(upTo: 4), id: \.self) { amenity in
                    HStack {
                        Image(systemName: amenity.icon)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 15, height: 15)
                        
                        Text(amenity.rawValue)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }
                
                HStack {
                    Spacer()
                    
                    Button { showAllAmenities = true } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.DesignCodeWhite)
                                .frame(width: 350, height: 45)
                            
                            Text("Show all \(event.amenities.count) amenities")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                        }
                    }
                    
                    Spacer()
                }
            }
            
            Divider()
            
            if let coords = coordinates {
                Text("Where you'll be")
                    .font(.title2)
                    .bold()
                
                MapSnapshotView(location: coords, isInvited: !event.isInviteOnly)
//                    .onTapGesture { viewModel.getDirectionsToLocation(coordinates: coordinates) }
            }
        }
        .padding(.horizontal)
//        .frame(maxHeight: UIScreen.main.bounds.size.height)
    }
}

struct EventInfoView_Previews: PreviewProvider {
    @Namespace static var namespace
    
    static var previews: some View {
        EventInfoView(event: CachedEvent(from: Mockdata.event),
                      host: CachedHost(from: Mockdata.host),
                      unsave: {},
                      save: {},
                      coordinates: CLLocationCoordinate2D(latitude: 40, longitude: 50),
                      showAllAmenities: .constant(false),
                      namespace: namespace)
            .preferredColorScheme(.dark)
    }
}

fileprivate struct HostedBySection: View {
    let type: EventType
    let host: CachedHost
    var ageLimit: Int?
    var cost: Float?
    var hasAlcohol: Bool?
    let dot: Text = Text("•").font(.callout).foregroundColor(.secondary)
    var namespace: Namespace.ID
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("\(type.rawValue) at \(host.name)")
                    .font(.title2)
                    .bold()
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                
                HStack {
                    if let ageLimit = ageLimit {
                        Text("\(ageLimit)+")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if cost != nil || hasAlcohol != nil { dot }
                    }
                    
                    if let cost = cost {
                        Text("$\(cost.roundToDigits(2))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if hasAlcohol != nil { dot }
                    }
                    
                    if let hasAlcohol = hasAlcohol {
                        Text("\(hasAlcohol ? "Wet" : "Dry") event")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            KFImage(URL(string: host.hostImageUrl))
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
                .frame(width: 63, height: 63)
        }
    }
}

fileprivate struct EventModal: View {
    let event: CachedEvent
    let unsave: () -> Void
    let save: () -> Void
    var namespace: Namespace.ID
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack {
                HStack(alignment: .center) {
                    Text(event.title)
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.75)
                        .matchedGeometryEffect(id: event.title, in: namespace)
                    
                    Spacer()
                    
                    if event.hasStarted == false {
                        if let didSave = event.didSave {
                            Button { didSave ? unsave() : save() } label: {
                                Image(systemName: didSave ? "bookmark.fill" : "bookmark")
                                    .resizable()
                                    .scaledToFill()
                                    .foregroundColor(didSave ? Color.mixerPurple : .secondary)
                                    .frame(width: 17, height: 17)
                                    .padding(4)
                            }
                        }
                    }
                }
                
                HStack(spacing: 5) {
                    Image(systemName: "person.3.fill")
                        .symbolRenderingMode(.hierarchical)
                    
                    if let saves = event.saves {
                        Text("\(saves) interested")
                            .font(.body)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: -8) {
                        Circle()
                            .stroke()
                            .foregroundColor(.mixerSecondaryBackground)
                            .frame(width: 28, height: 46)
                            .overlay {
                                Image("profile-banner-1")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(Circle())
                            }
                        
                        Circle()
                            .stroke()
                            .foregroundColor(.mixerSecondaryBackground)
                            .frame(width: 28, height: 46)
                            .overlay {
                                Image("mock-user-1")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(Circle())
                            }
                        
                        Circle()
                            .fill(Color.mixerSecondaryBackground)
                            .frame(width: 28, height: 46)
                            .overlay {
                                Text("+99")
                                    .foregroundColor(.white)
                                    .font(.footnote)
                            }
                    }
                }
            }
            
            Divider()
            
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text(event.startDate.getTimestampString(format: "EEEE, MMMM d"))
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("\(event.startDate.getTimestampString(format: "h:mm a")) - \(event.endDate.getTimestampString(format: "h:mm a"))")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .matchedGeometryEffect(id: "\(event.title)-time", in: namespace)
                
                Spacer()
                
                VStack(alignment: .center, spacing: 4) {
                    Image(systemName: event.isInviteOnly ? "lock.fill" : "globe")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.secondary)
                        .frame(width: 22, height: 22)
                        .background(.ultraThinMaterial)
                        .backgroundStyle(cornerRadius: 10, opacity: 0.6)
                        .cornerRadius(10)
                    
                    Text(event.isInviteOnly ? "Invite Only" : "Public")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .matchedGeometryEffect(id: "\(event.title)-isInviteOnly", in: namespace)
            }
        }
        .padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
        .background {
            Rectangle()
                .fill(.ultraThinMaterial)
                .backgroundStyle(cornerRadius: 30)
        }
    }
}
