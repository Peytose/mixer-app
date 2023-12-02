//
//  HostSettingsView.swift
//  mixer
//
//  Created by Jose Martinez on 11/9/23.
//

import SwiftUI
import Kingfisher

struct HostSettingsView: View {
    @StateObject var viewModel: HostSettingsViewModel
    @State private var imagePickerPresented = false
    @State var locationIsPrivate            = false
    let settings: [SettingsSectionModel] = DataLoader.load("host_settings.json")
    
    init(host: Host) {
        self._viewModel = StateObject(wrappedValue: HostSettingsViewModel(host: host))
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                List {
                    ChangeProfileImageButton(profileImageUrl: URL(string: viewModel.hostImageUrl),
                                             saveFunc: viewModel.save(for:))
                    
                    ForEach(settings) { setting in
                        SettingsSection(setting: setting, viewModel: viewModel)
                    }
                }
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
                .listStyle(.insetGrouped)
            }
            .background(Color.theme.backgroundColor)
            .navigationBar(title: "Host Settings", displayMode: .inline)
        }
    }
}
