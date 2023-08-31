//
//  NameAndLinksRow.swift
//  mixer
//
//  Created by Peyton Lyons on 8/1/23.
//

import SwiftUI
import Combine

struct NameAndLinksRow: View {
    let host: Host
    var namespace: Namespace.ID?
    @State private var timer: AnyCancellable?
    @State private var showUsername = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(showUsername ? "@\(host.username)" : "\(host.name)")
                .largeTitle()
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .textSelection(.enabled)
                .matchedGeometryEffect(id: "name-\(host.username)",
                                       in: namespace ?? Namespace().wrappedValue)
                .onAppear {
                    timer = Timer.publish(every: Double.random(in: 3...7), on: .main, in: .common)
                        .autoconnect()
                        .sink { _ in
                            withAnimation(.easeInOut) {
                                self.showUsername.toggle()
                            }
                        }
                }
                .onDisappear {
                    timer?.cancel()
                }
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        showUsername.toggle()
                    }
                }
            
            Spacer()
            
            if let handle = host.instagramHandle {
                HostLinkIcon(url: "https://instagram.com/\(handle)",
                             icon: "instagram",
                             isAsset: true)
                    .matchedGeometryEffect(id: "insta-\(host.username)",
                                           in: namespace ?? Namespace().wrappedValue)
            }
            
            if let website = host.website {
                HostLinkIcon(url: website,
                             icon: "globe")
                    .matchedGeometryEffect(id: "website-\(host.username)",
                                           in: namespace ?? Namespace().wrappedValue)
            }
        }
    }
}

struct NameAndLinksRow_Previews: PreviewProvider {
    @Namespace static var namespace
    
    static var previews: some View {
        NameAndLinksRow(host: dev.mockHost, namespace: namespace)
    }
}

fileprivate struct HostLinkIcon: View {
    let url: String
    let icon: String
    var isAsset = false
    
    var body: some View {
        Link(destination: URL(string: url)!) {
            if isAsset {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            } else {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color.white)
                    .frame(width: 24, height: 24)
            }
        }
    }
}
