//
//  ProfileSettingsView.swift
//  mixer
//
//  Created by Jose Martinez on 12/18/22.
//

import SwiftUI
import FirebaseAuth
import Kingfisher

struct ProfileSettingsView: View {
    @Environment(\.presentationMode) var mode
    @ObservedObject var viewModel: ProfileViewModel
    @State var isShowingMailView: Bool     = false
    @State var isPublic: Bool              = false
    @State var showAlert: Bool             = false
    @State var imagePickerPresented: Bool  = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                List {
                    VStack(alignment: .center) {
                        Button { imagePickerPresented = true } label: {
                            KFImage(URL(string: viewModel.user.profileImageUrl))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 150, height: 150)
                                .clipShape(Circle())
                                .padding(2)
                                .background(Color.mainFont, in: Circle())
                                .overlay(alignment: .bottomTrailing) {
                                    Image(systemName: "pencil")
                                        .imageScale(.large)
                                        .foregroundColor(.white)
                                        .padding(5)
                                        .background(Color.mixerSecondaryBackground, in: Circle())
                                        .background(Color.mainFont, in: Circle().stroke(lineWidth: 2))
                                }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)

                    Section(header: Text("Profile").fontWeight(.semibold),
                            footer: Text("Right now, you can only edit your name and bio.")) {
                        EditableRow(viewModel: viewModel,
                                    rowTitle: "Name",
                                    rowContent: viewModel.user.name,
                                    alertTitle: "Name Change",
                                    alertMessage: "Please enter your preferred name.",
                                    alertPlaceholder: "Preferred name",
                                    icon: "person",
                                    value: $viewModel.name,
                                    saveType: .name)
                        .listRowBackground(Color.mixerSecondaryBackground)
                        
                        EditableRow(viewModel: viewModel,
                                    rowTitle: "Bio",
                                    rowContent: viewModel.user.bio ?? "",
                                    alertTitle: "Bio Change",
                                    alertMessage: "Please enter your new bio.",
                                    alertPlaceholder: "New Bio",
                                    icon: "signature",
                                    value: $viewModel.bio,
                                    saveType: .bio)
                        .listRowBackground(Color.mixerSecondaryBackground)

                        EditableRow(viewModel: viewModel,
                                    rowTitle: "Instagram",
                                    rowContent: viewModel.user.instagramHandle ?? "",
                                    alertTitle: "Instagram Change",
                                    alertMessage: "Please enter your new instagram username.",
                                    alertPlaceholder: "Your handle",
                                    icon: "instagram",
                                    value: $viewModel.instagramHandle,
                                    saveType: .instagram)
                        .listRowBackground(Color.mixerSecondaryBackground)
                        
                        SettingRow(title: "Username",
                                   content: viewModel.user.username,
                                   icon: "a.magnify")
                        .listRowBackground(Color.mixerSecondaryBackground)
                        
                        SettingRow(title: "Email",
                                   content: viewModel.user.email,
                                   icon: "envelope")
                        .listRowBackground(Color.mixerSecondaryBackground)
                        
                        SettingRow(title: "Phone",
                                   content: viewModel.phoneNumber,
                                   icon: "flipphone")
                        .listRowBackground(Color.mixerSecondaryBackground)
                        
                    }
                    
                    Section(header: Text("Privacy").fontWeight(.semibold)) {
                        Toggle("Show age on profile?", isOn: $isPublic.animation())
                            .font(.body.weight(.medium))
                            .foregroundColor(isPublic ? .white : .secondary)
                            .listRowBackground(Color.mixerSecondaryBackground)
                    }
                    .listRowBackground(Color.mixerSecondaryBackground)
                    
                    Section(header: Text("Feedback & Support").fontWeight(.semibold),
                            footer: Text("Yes, these are the same link. We're lazy ...")) {
                        LinkRow(linkUrl: viewModel.supportLink,
                                title: "Feature Request",
                                icon: "wand.and.stars")
                        .listRowBackground(Color.mixerSecondaryBackground)
                        .sheet(isPresented: $isShowingMailView) {
                            MailView(isShowing: self.$isShowingMailView, subject: "Feature Request")
                        }
                        
                        LinkRow(linkUrl: viewModel.supportLink,
                                title: "Report a Bug",
                                icon: "ant")
                        .listRowBackground(Color.mixerSecondaryBackground)
                        .sheet(isPresented: $isShowingMailView) {
                            MailView(isShowing: self.$isShowingMailView, subject: "Bug Report")
                        }
                        
                        LinkRow(linkUrl: viewModel.supportLink,
                                title: "Questions",
                                icon: "questionmark.circle")
                        .listRowBackground(Color.mixerSecondaryBackground)
                        .sheet(isPresented: $isShowingMailView) {
                            MailView(isShowing: self.$isShowingMailView, subject: "Question")
                        }
                    }

                    Section(header: Text("Legal & Policies").fontWeight(.semibold),
                            footer: Text("")) {
                        LinkRow(linkUrl: viewModel.supportLink,
                                title: "Privacy Policy",
                                icon: "lock.doc")
                        .listRowBackground(Color.mixerSecondaryBackground)
                        
                        
                        LinkRow(linkUrl: viewModel.supportLink,
                                title: "Terms of Service",
                                icon: "doc.plaintext")
                        .listRowBackground(Color.mixerSecondaryBackground)
                    }
                    
                    Section {
                        SettingRow(title: "Version",
                                   content: viewModel.getVersion(),
                                   icon: "info.circle")
                    }
                    .listRowBackground(Color.mixerSecondaryBackground)
                    
                    Section {
                        Button { AuthViewModel.shared.signOut() } label: {
                            Text("Logout").foregroundColor(.blue)
                        }
                        .listRowBackground(Color.mixerSecondaryBackground)
                    }

                    
                    Section(footer: EasterEggView(text: viewModel.getDateJoined())) { }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $imagePickerPresented) {
                ImagePicker(image: $viewModel.selectedImage)
            }
            .onChange(of: viewModel.selectedImage) { _ in viewModel.save(for: .image) }
            .background(Color.mixerBackground.edgesIgnoringSafeArea(.all))
        }
    }
}


struct ProfileSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSettingsView(viewModel: ProfileViewModel(user: CachedUser(from: Mockdata.user)))
            .preferredColorScheme(.dark)
    }
}

fileprivate struct EditableRow: View {
    @ObservedObject var viewModel: ProfileViewModel
    let rowTitle: String
    let rowContent: String
    let alertTitle: String
    let alertMessage: String
    let alertPlaceholder: String
    let icon: String
    @State var showAlert = false
    @Binding var value: String
    let saveType: ProfileViewModel.ProfileSaveType
    
    var body: some View {
        Button { showAlert.toggle() } label: {
            HStack {
                SettingNameAndIcon(icon: icon, title: rowTitle)
                
                Spacer()
                
                Text(rowContent)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Image(systemName: "pencil")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.secondary)
                    .frame(width: 14, height: 14)
            }
        }
        .alert(alertTitle, isPresented: $showAlert) {
            TextField(alertPlaceholder, text: $value)
                .foregroundColor(.primary)
            
            if #available(iOS 16.0, *) {
                Button("Save") { viewModel.save(for: saveType) }
                Button("Cancel", role: .cancel, action: {})
            }
        } message: { Text(alertMessage) }
    }
}

fileprivate struct SettingRow: View {
    let title: String
    let content: String
    let icon: String
    
    var body: some View {
        HStack {
            SettingNameAndIcon(icon: icon, title: title)
            
            Spacer()
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

struct LinkRow: View {
    let linkUrl: String
    let title: String
    let icon: String
    
    var body: some View {
        if let url = URL(string: linkUrl) {
            Link(destination: url) {
                HStack {
                    SettingNameAndIcon(icon: icon, title: title)
                    
                    Spacer()
                    
                    SettingIcon(icon: "link", color: .secondary)
                }
            }
        }
    }
}

fileprivate struct SettingIcon: View {
    let icon: String
    let color: Color
    
    var body: some View {
        if icon == "instagram" {
            Image("Instagram_Glyph_Gradient 1")
                .resizable()
                .scaledToFit()
                .foregroundColor(color)
                .frame(width: 18, height: 18)
                .fontWeight(.medium)
        } else {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .foregroundColor(color)
                .frame(width: 18, height: 18)
                .fontWeight(.medium)
        }
    }
}

fileprivate struct SettingNameAndIcon: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            SettingIcon(icon: icon, color: .mainFont)
            
            Text(title)
                .font(.body)
                .foregroundColor(.white)
        }
    }
}

fileprivate struct EasterEggView: View {
    let text: String
    
    var body: some View {
        HStack {
            Spacer()
            
            Text(text)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .offset(x: 0, y: 100)
                .background(Color.clear)
            
            Spacer()
        }
        // set the background color of the custom view
    }
}
