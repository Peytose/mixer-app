//
//  SettingsConfigurable.swift
//  mixer
//
//  Created by Peyton Lyons on 2/24/24.
//

import SwiftUI

protocol SettingsConfigurable: ObservableObject {
    associatedtype Content: View
    var showAlert: Bool { get set }
    var chosenRow: SettingsRowModel? { get set }
    func content(for title: String) -> Binding<String>
    func save(for type: SettingSaveType)
    func saveType(for title: String) -> SettingSaveType
    func toggle(for title: String) -> Binding<Bool>
    func url(for title: String) -> String
    func shouldShowRow(with title: String) -> Bool
    func action(for title: String) -> Void
    @ViewBuilder func destination(for title: String) -> Content
}

extension SettingsConfigurable {
    func shouldShowRow(with title: String) -> Bool { return true }
    
    
    func visibleRowsCount(in setting: SettingsSectionModel) -> Int {
        setting.rows.filter { shouldShowRow(with: $0.title) }.count
    }
}
