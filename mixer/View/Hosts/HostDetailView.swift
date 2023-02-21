//
//  HostDetailView.swift
//  mixer
//
//  Created by Peyton Lyons on 1/27/23.
//

import SwiftUI
import Kingfisher
import CoreLocation
import FirebaseFirestore

struct HostDetailView: View {
    @ObservedObject var viewModel: HostDetailViewModel
    
    init(viewModel: HostDetailViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            StretchablePhotoBanner(imageUrl: viewModel.host.hostImageUrl)
            
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(viewModel.host.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    HStack(alignment: .center) {
                        Text("@\(viewModel.host.username)")
                            .textSelection(.enabled)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        HStack(spacing: 0) {
                            if let handle = viewModel.host.instagramHandle {
                                HostLinkIcon(url: "https://instagram.com/\(handle)", icon: "link")
                            }
                            
                            if let website = viewModel.host.website {
                                HostLinkIcon(url: website, icon: "globe")
                            }
                        }
                    }
                    
                    if let bio = viewModel.host.bio {
                        Text(bio)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                if let coordinates = viewModel.coordinates {
                    HostSubheading(text: "Located At")
                    
                    MapSnapshotView(location: coordinates)
                        .onTapGesture { viewModel.getDirectionsToLocation(coordinates: coordinates) }
                }
                
                if !viewModel.recentEvents.isEmpty {
                    HostSubheading(text: "Recent Events")
                    
                    ForEach(viewModel.recentEvents) { event in
                        RecentEventRow(imageUrl: event.eventImageUrl,
                                       title: event.title,
                                       date: event.startDate.getTimestampString(format: "MMMM d, yyyy"),
                                       attendance: event.attendance)
                    }
                }
            }
            .padding(.horizontal)
        }
        .background(Color.mixerBackground)
        .coordinateSpace(name: "scroll")
        .preferredColorScheme(.dark)
        .ignoresSafeArea()
    }
}

struct HostDetailView_Previews: PreviewProvider {
    static var previews: some View {
        HostDetailView(viewModel: HostDetailViewModel(host: CachedHost(from: Mockdata.host)))
    }
}

struct HostSubheading: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.title)
            .bold()
            .foregroundColor(.white)
    }
}

struct RecentEventRow: View {
    let imageUrl: String
    let title: String
    let date: String
    let attendance: Int?
    
    var body: some View {
        HStack(spacing: 15) {
            KFImage(URL(string: imageUrl))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            
            VStack(alignment: .leading) {
                Text(title)
                    .fontWeight(.semibold)
                
                
                HStack {
                    Text(date)
                        .font(.callout.weight(.semibold))
                        .foregroundColor(.secondary)
                    
                    if let attendance = attendance {
                        HStack(spacing: 2) {
                            Image(systemName: "person.3.fill")
                                .imageScale(.small)
                                .symbolRenderingMode(.hierarchical)
                            
                            Text("\(attendance)")
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                        }
                    }
                }
                
                Divider()
            }
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            
            Spacer()
        }
        .frame(height: 60)
    }
}

struct HostLinkIcon: View {
    let url: String
    let icon: String
    
    var body: some View {
        Link(destination: URL(string: url)!) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .foregroundColor(Color.mainFont)
                .frame(width: 25, height: 25)
                .padding(.horizontal, 10)
        }
    }
}
