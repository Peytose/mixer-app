//
//  HostSettingsChangeEmailView.swift
//  mixer
//
//  Created by Jose Martinez on 1/20/23.
//

import SwiftUI

struct HostSettingsChangeEmailView: View {
    @State var email = ""
    var body: some View {
        List {
            emailSection
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
    
    var emailSection: some View {
        Section(header: Text("Email"), footer: Text("Email is not public information and is only used by mixer to communicate with you")) {
                TextField("", text: $email)
                    .placeholder(when: email.isEmpty) {
                        Text(verbatim: "ThetaChi@mit.edu")
                            .foregroundColor(.white)
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
                    .listRowBackground(Color.mixerSecondaryBackground)
        }
    }
}

struct HostSettingsChangeEmailView_Previews: PreviewProvider {
    static var previews: some View {
        HostSettingsChangeEmailView()
    }
}
