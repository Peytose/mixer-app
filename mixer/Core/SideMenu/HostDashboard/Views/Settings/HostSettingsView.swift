//
//  HostSettingsView.swift
//  mixer
//
//  Created by Jose Martinez on 11/9/23.
//

import SwiftUI
import Kingfisher

struct HostSettingsView: View {
    //State variabables
    @State var imagePickerPresented = false
    @State var locationIsPrivate    = false
    
    //About variables
    @State var name                 = "MIT Theta Chi"
    @State var username             = "@mitthetachi"
    @State var instagram            = "@mitthetachi"
    @State var website              = "https://ox.mit.edu/main/"
    @State var email                = "mitthetachi@mit.edu"
    
    //Description variable
    @State var descriptionText      = "Best host at MIT "

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                List {
                    HostProfileImageButton()
                    nameSection
                    aboutSection
                    addressSection
                }
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
                .listStyle(.insetGrouped)
            }
            .background(Color.theme.backgroundColor)
            .navigationBar(title: "Host Settings", displayMode: .large)
        }
    }
}

extension HostSettingsView {
    var nameSection: some View {
        SettingsSectionContainer(header: "Name") {
            SettingsCell(value: name, isEditable: true) {}
        }
    }
    
    var aboutSection: some View {
        SettingsSectionContainer(header: "About") {
            SettingsCell(title: "Username", value: username, isEditable: false) {}
            
            SettingsCell(title: "Instagram", value: instagram, isEditable: true) {}
            
            SettingsCell(title: "Website", value: website, isEditable: true){}
            
            SettingsCell(title: "Email", value: email, isEditable: true){}
            
            SettingsCell(title: "Description", value: descriptionText, isLink: true){ EditTextView(title: "Description", text: $descriptionText, navigationTitle: "Edit Description") }
            
            SettingsCell(value: "Edit Members", isLink: true){
                ManageMembersView()
            }
        }
    }
    
    var addressSection: some View {
        SettingsSectionContainer(header: "Location", footer: "Choosing public allows mixer to displau your organization's location on the map and on your profile") {
            SettingsCell(value: "528 Beacon St Boston, MA 02215", isLink: true) { EditAddressView() }
            HStack {
                Text("Public")
                Spacer()
                Toggle("", isOn: $locationIsPrivate)
            }
        }
    }
}

struct HostProfileImageButton: View {
//    @Binding var imagePickerPresented: Bool
//    let profileImageUrl: URL?
    
    var body: some View {
        VStack(alignment: .center) {
            Button {} label: {
//                KFImage(profileImageUrl)
                Image("avatar4")
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

fileprivate struct SettingsCell<Content: View>: View {
    var title: String
    @State var value: String
    var isEditable: Bool
    var isLink: Bool
    var content: Content
    @State var showAlert = false
    
    init(title: String = "", value: String, isEditable: Bool = false, isLink: Bool = false, @ViewBuilder content: () -> Content) {
        self.title = title
        _value = State(initialValue: value) // Initialize State
        self.isEditable = isEditable
        self.isLink = isLink
        self.content = content()
    }
    
    var body: some View {
        if isEditable {
            
            Button { showAlert.toggle() } label: {
                HStack {
                    if !title.isEmpty {
                        Text(title)
                        Spacer()
                    }

                    Text(value)
                        .foregroundStyle(!title.isEmpty ? .secondary : Color.white)
//                        .line
                    
                    if title.isEmpty {
                        Spacer()
                    }
                    
                    Image(systemName: "pencil")
                        .foregroundColor(.secondary)
                    
                }
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            }
            .buttonStyle(.plain)
            .alert("", isPresented: $showAlert) {
                TextField("Placeholder", text: $value)
                        
                if #available(iOS 16.0, *) {
                    Button("Save") {
//                        staticContent = content
//                        viewModel.save(for: saveType)
                    }
                    Button("Cancel", role: .cancel, action: {})
                }
            } message: { Text("Message") }
            
        } else if isLink {
            NavigationLink(destination: content) {
                HStack {
                    if !title.isEmpty {
                        Text(title)
                        Spacer()
                    }
                    
                    Text(value)
                        .foregroundStyle(!title.isEmpty ? .secondary : Color.white)
                    
                }
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            }
        } else {
            HStack {
                if !title.isEmpty {
                    Text(title)
                    Spacer()
                }
                
                Text(value)
                    .foregroundStyle(!title.isEmpty ? .secondary : Color.white)
                
            }
            .lineLimit(1)
            .minimumScaleFactor(0.8)
        }
    }
}

struct HostSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        HostSettingsView()
            .preferredColorScheme(.dark)
    }
}
