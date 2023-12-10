//
//  EditEventView.swift
//  mixer
//
//  Created by Jose Martinez on 11/14/23.
//

import SwiftUI
import Kingfisher

struct EditEventView: View {
    @ObservedObject var viewModel: EditEventViewModel
    @Binding var showEditEventView: Bool
    @State var imagePickerPresented     = false
    @State var locationIsPrivate        = false
    let settings: [SettingsSectionModel] = DataLoader.load("event_settings.json")
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                List {
                    ChangeImageButton(imageUrl: viewModel.eventImageUrl,
                                      imageContext: .eventFlyer) { uiImage in
                        viewModel.save(for: .image(uiImage))
                    }
                    
                    ForEach(settings) { setting in
                        SettingsSection(setting: setting, viewModel: viewModel)
                    }
                }
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
                .listStyle(.insetGrouped)
            }
            .background(Color.theme.backgroundColor)
            .navigationBarBackButtonHidden(true)
            .navigationBar(title: "Edit Event", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    XDismissButton { showEditEventView.toggle() }
                }
            }
        }
    }
}

struct SettingsSectionContainer<Content: View>: View {
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
