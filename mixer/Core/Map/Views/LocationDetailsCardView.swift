//
//  LocationDetailsCardView.swift
//  mixer
//
//  Created by Peyton Lyons on 8/1/23.
//

import SwiftUI

struct LocationDetailsCardView: View {
    @EnvironmentObject var mapViewModel: MapViewModel
    @Namespace var namespace
    
    var body: some View {
        VStack {
            Capsule()
                .foregroundColor(Color(.systemGray5))
                .frame(width: 48, height: 6)
                .padding(.top, 8)
            
            // trip info
            HStack {
                VStack {
                    Circle()
                        .fill(Color(.systemGray3))
                        .frame(width: 8, height: 8)
                    
                    Rectangle()
                        .fill(Color(.systemGray3))
                        .frame(width: 1, height: 32)
                    
                    Rectangle()
                        .fill(Color.theme.mixerIndigo)
                        .frame(width: 8, height: 6)
                }
                
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        Text("Current location")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text(mapViewModel.pickupTime ?? "")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 10)
                    
                    HStack {
                        if let location = mapViewModel.selectedMixerMapItem {
                            Text(location.title)
                                .font(.headline)
                        }
                        
                        Spacer()
                        
                        Text(mapViewModel.dropOffTime ?? "")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.leading, 8)
            }
            .padding()
            
            Divider()
                .padding(.horizontal)
            
            NavigationLink(value: mapViewModel.selectedMixerMapItem?.state) {
                HStack {
                    Text("See more")
                        .fontWeight(.bold)
                    
                    Image(systemName: "arrow.right")
                        .imageScale(.small)
                }
                .frame(width: UIScreen.main.bounds.width / 3, height: 50)
                .background(Color.theme.mixerIndigo)
                .cornerRadius(10)
                .foregroundColor(.white)
            }
        }
        .padding(.bottom, 16)
        .background(Color.theme.backgroundColor)
        .cornerRadius(16)
        .navigationDestination(for: MapItemType.self) { state in
            switch state {
                case .event:
                if let event = EventManager.shared.selectedEvent {
                    EventDetailView(namespace: namespace)
                        .environmentObject(EventViewModel(event: event))
                }
                case .host:
                if let host = HostManager.shared.selectedHost {
                    HostDetailView(namespace: namespace)
                        .environmentObject(HostViewModel(host: host))
                }
            }
        }
    }
}

struct LocationDetailsCardView_Previews: PreviewProvider {
    static var previews: some View {
        LocationDetailsCardView()
            .environmentObject(MapViewModel())
    }
}
