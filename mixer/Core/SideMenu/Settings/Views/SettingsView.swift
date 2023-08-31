//
//  SettingsView.swift
//  mixer
//
//  Created by Jose Martinez on 12/18/22.
//

import SwiftUI
import FirebaseAuth
import Kingfisher

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State var imagePickerPresented      = false
    let settings: [SettingsSectionModel] = DataLoader.load("profile_settings.json")
    
    var body: some View {
        ZStack {
            Color.theme.backgroundColor
                .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                List {
                    if let imageUrl = viewModel.user?.profileImageUrl {
                        UserProfileImageButton(imagePickerPresented: $imagePickerPresented,
                                               profileImageUrl: URL(string: imageUrl))
                    }
                    
                    ForEach(settings) { setting in
                        SettingsSection(setting: setting)
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
        .cropImagePicker(show: $imagePickerPresented, croppedImage: $viewModel.selectedImage)
        .onChange(of: viewModel.selectedImage) { _ in viewModel.save(for: .image) }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                PresentationBackArrowButton()
            }
        }
    }
}

struct UserProfileImageButton: View {
    @Binding var imagePickerPresented: Bool
    let profileImageUrl: URL?

    var body: some View {
        VStack(alignment: .center) {
            Button { imagePickerPresented = true } label: {
                KFImage(profileImageUrl)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .padding(2)
                    .background(.white, in: Circle())
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "pencil")
                            .imageScale(.large)
                            .foregroundColor(.white)
                            .padding(5)
                            .background(Color.theme.secondaryBackgroundColor, in: Circle())
                            .background(.white, in: Circle().stroke(lineWidth: 2))
                            .offset(x: -4, y: -4)
                    }
            }
        }
        .frame(maxWidth: .infinity)
        .listRowBackground(Color.clear)
    }
}

fileprivate struct SettingsSection: View {
    let setting: SettingsSectionModel

    var body: some View {
        Section {
            ForEach(setting.rows) { row in
                SettingsRow(row: row)
                    .listRowBackground(Color.theme.secondaryBackgroundColor)
            }
        } header: {
            Text(setting.header)
                .fontWeight(.semibold)
        } footer: {
            if let footer = setting.footer {
                Text(footer)
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
