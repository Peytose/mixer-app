//
//  ProfileSettingsView.swift
//  mixer
//
//  Created by Jose Martinez on 12/18/22.
//

import SwiftUI
import FirebaseAuth

struct ProfileSettingsView: View {
    @State private var name: String
    @State private var bio: String
    @State private var insta: String?
    @State var isPublic = false
    @State var showAlert = false
    @State private var isShowingMailView = false
    @State var temp = ""

    @Environment(\.presentationMode) var mode
    @ObservedObject private var viewModel: ProfileSettingsViewModel
    @Binding var user: CachedUser
    
    init(user: Binding<CachedUser>) {
        self._user = user
        self.viewModel = ProfileSettingsViewModel(user: self._user.wrappedValue)
        self._name = State(initialValue: _user.wrappedValue.name)
        self._insta = State(initialValue: _user.wrappedValue.instagramHandle)
        self._bio = State(initialValue: _user.wrappedValue.bio!)
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                List {
                    VStack(alignment: .center) {
                        Image("mock-user-1")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .padding(2)
                            .background(Color.mainFont, in: Circle())
                            .overlay {
                                Button {
                                    
                                } label: {
                                    Image(systemName: "pencil")
                                        .imageScale(.medium)
                                        .foregroundColor(.white)
                                        .padding(5)
                                        .background(Color.mixerSecondaryBackground, in: Circle())
                                        .background(Color.mainFont, in: Circle().stroke(lineWidth: 2))
                                }
                                .offset(x: 32, y: 32)
                            }
                        
                        Text("Jose Martinez")
                            .font(.title2.weight(.medium))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                    .padding(.bottom, -50)

                    Section(header: Text("Profile").fontWeight(.semibold),
                            footer: Text("Right now, you can only edit your name and bio.")) {
//                        EditableRow(viewModel: viewModel,
//                                    rowTitle: "Name",
//                                    rowContent: name,
//                                    alertTitle: "Name Change",
//                                    alertMessage: "Please enter your preferred name.",
//                                    alertPlaceholder: "Preferred name",
//                                    icon: "person")
//                        .listRowBackground(Color.mixerSecondaryBackground)
                        
                        NavigationLink {
                            SettingsChangeNameView(viewModel: viewModel, name: name)
                        } label: {
                            HStack {
                                SettingIcon(icon: "person", color: .white)
                                
                                Text("Name")
                                    .font(.body)
                                    .foregroundColor(.white)
                            }
                        }
                        .listRowBackground(Color.mixerSecondaryBackground)
                        .buttonStyle(.plain)

                        
//                        EditableRow(viewModel: viewModel,
//                                    rowTitle: "Bio",
//                                    rowContent: bio,
//                                    alertTitle: "Bio Change",
//                                    alertMessage: "Please enter your new bio.",
//                                    alertPlaceholder: "New Bio",
//                                    icon: "signature")
//                        .listRowBackground(Color.mixerSecondaryBackground)
                        
                        Button { showAlert.toggle() } label: {
                            HStack {
                                SettingNameAndIcon(icon: "signature", title: "Bio")
                                
                                Spacer()
                                
                                Text(bio)
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
                        .alert("Bio Change", isPresented: $showAlert) {
                            TextField("New Bio", text: $temp)
                                .foregroundColor(.black)
                            
                            if #available(iOS 16.0, *) {
                                Button("Save") { viewModel.saveBio(temp) }
                                Button("Cancel", role: .cancel, action: {})
                            }
                        } message: { Text("Please enter your new bio.") }
                            .listRowBackground(Color.mixerSecondaryBackground)

                        NavigationLink {
                            SettingsChangeSocialsView(viewModel: viewModel, name: insta ?? "")
                        } label: {
                            HStack {
                                Image("Instagram_Glyph_Gradient 1")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 18, height: 18)
                                
                                Text("Instagram")
                                    .font(.body)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("jose_miguel_martinezzz")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .listRowBackground(Color.mixerSecondaryBackground)
                        .buttonStyle(.plain)
                        
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
            .onReceive(viewModel.$uploadComplete) { completed in
                if completed {
                    self.mode.wrappedValue.dismiss()
                    self.user.name = viewModel.user.name
                    self.user.bio = viewModel.user.bio
                }
            }
            .background(Color.mixerBackground.edgesIgnoringSafeArea(.all))
        }
    }
}


struct ProfileSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSettingsView(user: .constant(CachedUser(from: Mockdata.user)))
            .preferredColorScheme(.dark)
    }
}

fileprivate struct EditableRow: View {
    @ObservedObject var viewModel: ProfileSettingsViewModel
    let rowTitle: String
    let rowContent: String
    let alertTitle: String
    let alertMessage: String
    let alertPlaceholder: String
    let icon: String
    @State var showAlert = false
    @State var temp = ""
    
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
            TextField(alertPlaceholder, text: $temp)
                .foregroundColor(.black)
            
            if #available(iOS 16.0, *) {
                Button("Save") { viewModel.saveName(temp) }
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
        Image(systemName: icon)
            .resizable()
            .scaledToFit()
            .foregroundColor(color)
            .frame(width: 18, height: 18)
            .fontWeight(.medium)
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
