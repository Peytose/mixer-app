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
                if viewModel.shouldShowRow(with: row.title) {
                    SettingsRow(row: row, viewModel: viewModel)
                        .listRowBackground(Color.theme.secondaryBackgroundColor)
                }
            }
        } header: {
            if viewModel.visibleRowsCount(in: setting) > 0 {
                Text(setting.header)
                    .fontWeight(.semibold)
            }
        } footer: {
            if let footer = setting.footer, viewModel.visibleRowsCount(in: setting) > 0 {
                Text(footer)
            }
        }
    }
}
