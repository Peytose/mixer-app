//
//  SettingsChangeSocialsView.swift
//  mixer
//
//  Created by Jose Martinez on 4/6/23.
//

import SwiftUI

struct SettingsChangeSocialsView: View {
    @ObservedObject var viewModel: ProfileSettingsViewModel
    @State var name: String
    @State var showAlert = false
    @State var temp = ""

    var body: some View {
        List {
            socialsSection
        }
        .scrollContentBackground(.hidden)
        .background(Color.mixerBackground)
        .navigationTitle("Edit Name")
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden)
        .preferredColorScheme(.dark)
    }
    
    var socialsSection: some View {
        Section(header: Text("Name"), footer: Text("Add your Instagram accounts to your profile. Enter the username exactly as it appears on Instagram")) {
            HStack {
                Image("Instagram_Glyph_Gradient 1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("jose_miguel_martinezzz")
                        .lineLimit(1)
                        .minimumScaleFactor(0.2)
                    
                    Text("Instagram Username")
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
            .alert("Instagram", isPresented: $showAlert) {
                TextField("mixerpartyapp", text: $temp)
                    .foregroundColor(.black)
                
                if #available(iOS 16.0, *) {
                    Button("Save") { viewModel.saveInsta(temp) }
                    Button("Cancel", role: .cancel, action: {})
                }
            } message: { Text("Please enter your username") }
                .listRowBackground(Color.mixerSecondaryBackground)
        }
    }
}
