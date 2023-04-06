//
//  SettingsChangeNameView.swift
//  mixer
//
//  Created by Jose Martinez on 4/6/23.
//

import SwiftUI

struct SettingsChangeNameView: View {
    @ObservedObject var viewModel: ProfileSettingsViewModel
    @State var name: String
    @State var showAlert = false
    @State var temp = ""

    var body: some View {
        List {
            nameSection
        }
        .scrollContentBackground(.hidden)
        .background(Color.mixerBackground)
        .navigationTitle("Edit Name")
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden)
        .preferredColorScheme(.dark)
    }
    
    var nameSection: some View {
        Section(header: Text("Name"), footer: Text("To ensure a smooth check-in process at events, your actual name can't be changed. Please note that only hosts can see your actual name for safety purposes.")) {
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(name)
                        .lineLimit(1)
                        .minimumScaleFactor(0.2)
                    
                    Text("Display Name")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "pencil")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.secondary)
                    .frame(width: 14, height: 14)
            }
            .onTapGesture(perform: {
                showAlert.toggle()
            })
            .alert("Display Name Change", isPresented: $showAlert) {
                TextField("New Name", text: $temp)
                    .foregroundColor(.black)
                
                if #available(iOS 16.0, *) {
                    Button("Save") { viewModel.saveName(temp) }
                    Button("Cancel", role: .cancel, action: {})
                }
            } message: { Text("Please enter your new display name") }
                .listRowBackground(Color.mixerSecondaryBackground)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(name)
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
                
                Text("Name")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .listRowBackground(Color.mixerSecondaryBackground)
        }
    }
}

//struct SettingsChangeNameView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsChangeNameView(viewModel: ProfileSettingsViewModel, name: "Dog")
//    }
//}
