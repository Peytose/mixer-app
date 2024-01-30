//
//  SettingsSection.swift
//  mixer
//
//  Created by Peyton Lyons on 11/18/23.
//

import SwiftUI

struct SettingsSection<ViewModel: SettingsConfigurable>: View {
    let setting: SettingsSectionModel
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        Section {
            ForEach(setting.rows) { row in
                SettingsRow(row: row, viewModel: viewModel)
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
