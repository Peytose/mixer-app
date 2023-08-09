//
//  SettingsModel.swift
//  mixer
//
//  Created by Peyton Lyons on 7/18/23.
//

import SwiftUI

enum RowType: String, Codable {
    case editable = "editable"
    case menu     = "menu"
    case readOnly = "readOnly"
    case toggle   = "toggle"
    case mail     = "mail"
    case link     = "link"
}

struct SettingsSectionModel: Codable, Identifiable {
    let id: Int
    let header: String
    let footer: String?
    let rows: [SettingsRowModel]
}

struct SettingsRowModel: Codable, Identifiable, Hashable {
    let id: Int
    let type: RowType
    let title: String
    var icon: String?
    var alertTitle: String?
    var alertMessage: String?
    var alertPlaceholder: String?
    var subject: String?
    var url: String?
}
