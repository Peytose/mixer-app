//
//  HostSettingsChangeSocialsView.swift
//  mixer
//
//  Created by Jose Martinez on 1/20/23.
//

import SwiftUI

struct HostSettingsChangeSocialsView: View {
    @State var instagramURL = ""
    @State var websiteURL = ""
    
    var body: some View {
        List {
            nameSection
        }
        .scrollContentBackground(.hidden)
        .background(Color.mixerBackground)
        .navigationTitle("Change Social Links")
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden)
        .preferredColorScheme(.dark)
        .toolbar {
            ToolbarItem() {
                Button(action: {}, label: {
                    Text("Done")
                        .foregroundColor(.blue)
                })
            }
        }
    }
    
    var nameSection: some View {
        Section(header: Text("Name"), footer: Text("Copy full link and paste as is")) {
            VStack(alignment: .leading, spacing: 0) {
                TextField("", text: $instagramURL)
                    .placeholder(when: instagramURL.isEmpty) {
                        Text(verbatim: "https://instagram.com/mitthetachi?igshid=Zjc2ZTc4Nzk=")
                            .foregroundColor(.white)
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
                
                Text("Instagram profile URL")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .listRowBackground(Color.mixerSecondaryBackground)

            
            VStack(alignment: .leading, spacing: 0) {
                TextField("", text: $websiteURL)
                    .placeholder(when: websiteURL.isEmpty) {
                        Text(verbatim: "http://ox.mit.edu/main/")
                            .foregroundColor(.white)
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
                
                Text("Website URL")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .listRowBackground(Color.mixerSecondaryBackground)

        }
    }
}

struct HostSettingsChangeSocialsView_Previews: PreviewProvider {
    static var previews: some View {
        HostSettingsChangeSocialsView()
    }
}
