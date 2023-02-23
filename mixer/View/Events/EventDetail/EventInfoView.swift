//
//  EventInfoView.swift
//  mixer
//
//  Created by Peyton Lyons on 2/22/23.
//

import SwiftUI
import Kingfisher

struct EventInfoView: View {
    let event: CachedEvent
    let host: CachedHost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Divider()
            
            HostedBySection(type: event.type,
                            host: host,
                            ageLimit: event.ageLimit,
                            cost: event.cost,
                            hasAlcohol: event.alcoholPresence)
            
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
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.DesignCodeWhite)
                            .frame(width: 350, height: 45)
                        
                        Text("Show all \(event.amenities.count) amenities")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                }
            }
            
            Divider()
            
            Text("Where you'll be")
                .font(.title2)
                .bold()
            
            //            MapSnapshotView(location: coordinates)
            //                .cornerRadius(12)
        }
        .padding(.horizontal)
//        .frame(maxHeight: UIScreen.main.bounds.size.height)
    }
}

struct EventInfoView_Previews: PreviewProvider {
    static var previews: some View {
        EventInfoView(event: CachedEvent(from: Mockdata.event), host: CachedHost(from: Mockdata.host))
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
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("\(type.eventStringSing) by \(host.name)")
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
            
            NavigationLink(destination: HostDetailView(viewModel: HostDetailViewModel(host: host))) {
                KFImage(URL(string: host.hostImageUrl))
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    .frame(width: 63, height: 63)
            }
        }
    }
}
