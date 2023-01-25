//
//  HostSettingsView.swift
//  mixer
//
//  Created by Jose Martinez on 1/20/23.
//

import SwiftUI

struct HostSettingsView: View {
    var body: some View {
        NavigationView {
            List {
                section
            }
            .scrollContentBackground(.hidden)
            .background(Color.mixerBackground)
            .navigationTitle("Host Settings")
            .scrollIndicators(.hidden)
            .preferredColorScheme(.dark)
        }
    }
    
    var section: some View {
        Section {
            NavigationLink {
                HostProfileSettingsView()
            } label: {
                HStack(alignment: .top, spacing: 15) {
                    Image("profile-banner-2")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text("MIT Theta Chi")
                            .font(.title2.weight(.medium))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        
                        Text("@mitthetachi")
                            .font(.body.weight(.medium))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                }
            }

            NavigationLink {
                HostMemberSettingsView()
            } label: {
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
                        .stroke()
                        .foregroundColor(.mixerSecondaryBackground)
                        .frame(width: 28, height: 46)
                        .overlay {
                            Image("mock-user-2")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                        }
                    
                    Circle()
                        .fill(Color.mixerBackground)
                        .frame(width: 30, height: 46)
                        .overlay {
                            Text("+29")
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                    
                    Text("Members")
                        .font(.headline)
                        .padding(.leading, 14)
                }
                .padding(.vertical, -5)
            }
        }
        .listRowBackground(Color.mixerSecondaryBackground)

    }
}


struct HostSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        HostSettingsView()
    }
}
