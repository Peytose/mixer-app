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
    @Environment(\.presentationMode) var mode
    @ObservedObject private var viewModel: ProfileSettingsViewModel
    @Binding var user: User
    
    init(user: Binding<User>) {
        self._user = user
        self.viewModel = ProfileSettingsViewModel(user: self._user.wrappedValue)
        self._name = State(initialValue: _user.wrappedValue.name)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.leading)
                .padding(.top)
            
            List {
                Section(header: Text("Personal Information").fontWeight(.semibold),
                        footer: Text("Right now, you can only edit your name.")) {
                    EditableRow(viewModel: viewModel,
                                rowTitle: "Name",
                                rowContent: name,
                                alertTitle: "Name Change",
                                alertMessage: "Please enter your preferred name.",
                                alertPlaceholder: "Preferred name",
                                icon: "signature")
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
                
                Section(header: Text("Support").fontWeight(.semibold),
                        footer: Text("Yes, these are the same link. We're lazy ...")) {
                    LinkRow(linkUrl: viewModel.supportLink,
                            title: "Feature Request",
                            icon: "wand.and.stars")
                    .listRowBackground(Color.mixerSecondaryBackground)
                    
                    LinkRow(linkUrl: viewModel.supportLink,
                            title: "Report a Bug",
                            icon: "ant")
                    .listRowBackground(Color.mixerSecondaryBackground)
                    
                    LinkRow(linkUrl: viewModel.supportLink,
                            title: "Questions",
                            icon: "questionmark.circle")
                    .listRowBackground(Color.mixerSecondaryBackground)
                }
                
                Section(header: Text("LEGAL").fontWeight(.semibold)) {
                    LinkRow(linkUrl: "https://mixer.llc/privacy-policy/",
                            title: "Privacy Policy",
                            icon: "lock.doc")
                    
                    LinkRow(linkUrl: "https://mixer.llc/",
                            title: "Terms of Service",
                            icon: "list.bullet.rectangle.portrait")
                }
                .listRowBackground(Color.mixerSecondaryBackground)
                
                Section {
                    SettingRow(title: "Version",
                               content: viewModel.getVersion(),
                               icon: "info.circle")
                }
                .listRowBackground(Color.mixerSecondaryBackground)
                
                Section {
                    Button { AuthViewModel.shared.signOut() } label: {
                        Text("Logout").foregroundColor(.black)
                    }
                }
                
                Section(footer: EasterEggView(text: viewModel.getDateJoined())) { }
            }
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
        }
        .onReceive(viewModel.$uploadComplete) { completed in
            if completed {
                self.mode.wrappedValue.dismiss()
                self.user.name = viewModel.user.name
            }
        }
        .background(Color.mixerBackground.edgesIgnoringSafeArea(.all))
        .overlay(alignment: .topTrailing) {
            Button { mode.wrappedValue.dismiss() } label: { XDismissButton() }
                .padding(.trailing)
                .padding(.top)
        }
    }
}


struct ProfileSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSettingsView(user: .constant(Mockdata.user))
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
                
                Image(systemName: "chevron.right")
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
    }
}

fileprivate struct SettingNameAndIcon: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            SettingIcon(icon: icon, color: .mixerIndigo)
            
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
