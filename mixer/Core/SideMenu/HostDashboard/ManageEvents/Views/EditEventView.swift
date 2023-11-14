//
//  EditEventView.swift
//  mixer
//
//  Created by Jose Martinez on 11/14/23.
//

import SwiftUI
import Kingfisher

struct EditEventView: View {
    @State var imagePickerPresented      = false
    @State var locationIsPrivate         = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                List {
                    EventImageButton()
                    nameSection
                    aboutSection
                    addressSection
                }
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
                .listStyle(.insetGrouped)
            }
            .background(Color.theme.backgroundColor)
            .navigationBar(title: "Edit Event", displayMode: .inline)
        }
    }
}

extension EditEventView {
    var nameSection: some View {
        SettingsSection(header: "Title") {
            SettingsCell(value: "Neon Party", isEditable: true) {}
        }
    }
    
    var aboutSection: some View {
        SettingsSection(header: "About") {
            SettingsCell(value: "Description", isLink: true) {}
            
            SettingsCell(value: "Notes", isLink: true) {}
                        
            SettingsCell(value: "Amenities", isLink: true) {}
            
            SettingsCell(value: "Date & Time", isLink: true){}
        }
    }
    
    var addressSection: some View {
        SettingsSection(header: "Location") {
            SettingsCell(value: "528 Beacon St Boston, MA 02215", isLink: true){}
        }
    }
}

fileprivate struct EventImageButton: View {
//    @Binding var imagePickerPresented: Bool
//    let profileImageUrl: URL?
    
    var body: some View {
        VStack(alignment: .center) {
            Button {} label: {
//                KFImage(profileImageUrl)
                Image("avatar4")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 200, height: 200)
                    .padding(2)
                    .background(.white, in: Rectangle())
                    .cornerRadius(12)
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

fileprivate struct SettingsSection<Content: View>: View {
    var header: String
    var footer: String
    var content: Content
    
    init(header: String = "", footer: String = "", @ViewBuilder content: () -> Content) {
        self.header = header
        self.footer = footer
        self.content = content()
    }
    
    var body: some View {
        Section(header: Text(header), footer: Text(footer)) {
            content
        }
        .listRowBackground(Color.theme.secondaryBackgroundColor)
    }
}

fileprivate struct SettingsCell<Content: View>: View {
    var title: String
    var value: String
    var isEditable: Bool
    var isLink: Bool
    var content: Content
    
    init(title: String = "", value: String, isEditable: Bool = false, isLink: Bool = false, @ViewBuilder content: () -> Content) {
        self.title = title
        self.value = value
        self.isEditable = isEditable
        self.isLink = isLink
        self.content = content()
    }
    
    var body: some View {
        if isEditable {
            HStack {
                if !title.isEmpty {
                    Text(title)
                    Spacer()
                }
                
                
                
                Text(value)
                    .foregroundStyle(!title.isEmpty ? .secondary : Color.white)
                
                if title.isEmpty {
                    Spacer()
                }
                
                Image(systemName: "pencil")
                    .foregroundColor(.secondary)
                
            }
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            
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

struct EditEventView_Previews: PreviewProvider {
    static var previews: some View {
        EditEventView()
            .preferredColorScheme(.dark)
    }
}
