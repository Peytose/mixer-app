//
//  HostSettingsChangeNameView.swift
//  mixer
//
//  Created by Jose Martinez on 1/20/23.
//

import SwiftUI

struct HostSettingsChangeNameView: View {
    @State var name = ""
    var body: some View {
        List {
            nameSection
        }
        .scrollContentBackground(.hidden)
        .background(Color.mixerBackground)
        .navigationTitle("Change Name")
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
        Section(header: Text("Name"), footer: Text("Abbreviate when possible. e.g. MIT Theta Chi vs Massachusetts Institute of Technology Theta Chi")) {
                TextField("", text: $name)
                    .placeholder(when: name.isEmpty) {
                        Text("MIT Theta Chi")
                            .foregroundColor(.white)
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
                    .listRowBackground(Color.mixerSecondaryBackground)
        }
    }
}

struct HostSettingsChangeNameView_Previews: PreviewProvider {
    static var previews: some View {
        HostSettingsChangeNameView()
    }
}
