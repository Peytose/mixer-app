//
//  SettingsView.swift
//  mixer
//
//  Created by Jose Martinez on 12/18/22.
//

import SwiftUI
import FirebaseAuth
import Kingfisher
import FirebaseFirestoreSwift
import FirebaseFirestore
import PhotosUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    let settings: [SettingsSectionModel] = DataLoader.load("profile_settings.json")
    
    var body: some View {
        ZStack {
            Color.theme.backgroundColor
                .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                List {
                    if let imageUrl = viewModel.user?.profileImageUrl {
                        ChangeProfileImageButton(profileImageUrl: URL(string: imageUrl),
                                                 saveFunc: viewModel.save(for:))
                    }
                    
                    ForEach(settings) { setting in
                        SettingsSection(setting: setting,
                                        viewModel: viewModel)
                            .environmentObject(viewModel)
                    }
                    
                    LogoutSection()
                    
                    FooterSection(text: viewModel.getDateJoined())
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
            }
        }
        .navigationBar(title: "Settings", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                PresentationBackArrowButton()
            }
        }
    }
}

fileprivate struct LogoutSection: View {
    var body: some View {
        Section {
            Button { AuthViewModel.shared.signOut() } label: {
                Text("Logout").foregroundColor(.blue)
            }
            .listRowBackground(Color.theme.secondaryBackgroundColor)
        }
    }
}

fileprivate struct FooterSection: View {
    let text: String

    var body: some View {
        Section(footer: EasterEggView(text: text)) { }
    }
}

fileprivate struct EasterEggView: View {
    let text: String
    
    var body: some View {
        HStack {
            Spacer()
            
            VStack {
                Text(text)

                Text("🦫 🐏")
            }
            .font(.body)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .offset(x: 0, y: 110)
            .background(Color.clear)
            
            Spacer()
        }
    }
}
