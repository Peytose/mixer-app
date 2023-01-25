//
//  HostSettingsChangeAddressView.swift
//  mixer
//
//  Created by Jose Martinez on 1/20/23.
//

import SwiftUI
import MapItemPicker

struct HostSettingsChangeAddressView: View {
    @State var address = ""
    @State private var showingPicker = false
    
    var body: some View {
        List {
            nameSection
                .mapItemPicker(isPresented: $showingPicker) { item in
                    if let name = item?.name {
                        print("Selected \(name)")
                    }
                }
        }
        .scrollContentBackground(.hidden)
        .background(Color.mixerBackground)
        .navigationTitle("Change Address")
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden)
        .preferredColorScheme(.dark)
        .toolbar {
            ToolbarItem() {
                Button(action: {
                    showingPicker.toggle()
                }, label: {
                    Text("Edit")
                        .foregroundColor(.blue)
                })
            }
        }
    }
    
    var nameSection: some View {
        Section(header: Text("Name"), footer: Text("")) {
            
            Text("528 Beacon St\nBoston, MA 02215")
                .lineLimit(2)
                .minimumScaleFactor(0.2)
                .listRowBackground(Color.mixerSecondaryBackground)
        }
    }
}

struct HostSettingsChangeAddressView_Previews: PreviewProvider {
    static var previews: some View {
        HostSettingsChangeAddressView()
    }
}
