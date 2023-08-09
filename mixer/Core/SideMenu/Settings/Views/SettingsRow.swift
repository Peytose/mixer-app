//
//  SettingsRow.swift
//  mixer
//
//  Created by Peyton Lyons on 7/19/23.
//

import SwiftUI

struct SettingsRow: View {
    let row: SettingsRowModel
    @EnvironmentObject var viewModel: SettingsViewModel
    
    var body: some View {
        switch row.type {
            case .editable:
                EditableSettingsRow(content: viewModel.content(for: row.title),
                                    row: row,
                                    saveType: viewModel.saveType(for: row.title))
            case .menu:
                MenuSettingsRow(content: viewModel.content(for: row.title),
                                row: row,
                                saveType: viewModel.saveType(for: row.title))
            case .readOnly:
                ReadOnlySettingsRow(row: row, content: viewModel.content(for: row.title).wrappedValue)
            case .toggle:
                ToggleSettingsRow(isOn: viewModel.toggle(for: row.title),
                                  row: row,
                                  saveType: viewModel.saveType(for: row.title))
            case .mail:
                MailSettingsRow(row: row)
            case .link:
                LinkSettingsRow(row: row,
                                url: viewModel.url(for: row.title))
        }
    }
}

struct MailSettingsRow: View {
    let row: SettingsRowModel
    @State private var isPresented: Bool = false
    
    var body: some View {
        Button { isPresented.toggle() } label: {
            HStack {
                if let icon = row.icon {
                    SettingsIconAndTitle(icon: icon, title: row.title)
                }
                
                Spacer()
                
                SettingIcon(icon: "chevron.right", color: .secondary)
            }
        }
        .sheet(isPresented: $isPresented) {
            if let subject = row.subject {
                MailViewModal(isShowing: $isPresented, subject: subject)
            }
        }
    }
}

struct LinkSettingsRow: View {
    let row: SettingsRowModel
    let url: String
    
    var body: some View {
        if let url = URL(string: url) {
            Link(destination: url) {
                HStack {
                    if let icon = row.icon {
                        SettingsIconAndTitle(icon: icon, title: row.title)
                    }
                    
                    Spacer()
                    
                    SettingIcon(icon: "link", color: .secondary)
                }
            }
        }
    }
}

struct EditableSettingsRow: View {
    @EnvironmentObject var viewModel: SettingsViewModel
    @Binding var content: String
    @State var staticContent: String
    let row: SettingsRowModel
    let saveType: ProfileSaveType
    @State private var showAlert: Bool = false
    
    init(content: Binding<String>, row: SettingsRowModel, saveType: ProfileSaveType) {
        self._content = content
        self.staticContent = content.wrappedValue
        self.row = row
        self.saveType = saveType
    }
    
    var body: some View {
        Button { showAlert.toggle() } label: {
            HStack {
                ReadOnlySettingsRow(row: row, content: staticContent)
                
                SettingIcon(icon: "pencil", color: .secondary)
            }
        }
        .alert(row.alertTitle ?? "", isPresented: $showAlert) {
            TextField(row.alertPlaceholder ?? "", text: $content)
                .foregroundColor(.primary)
                    
            if #available(iOS 16.0, *) {
                Button("Save") {
                    staticContent = content
                    viewModel.save(for: saveType)
                }
                Button("Cancel", role: .cancel, action: {})
            }
        } message: { Text(row.alertMessage ?? "") }
    }
}

struct MenuSettingsRow: View {
    @EnvironmentObject var viewModel: SettingsViewModel
    @Binding var content: String
    let row: SettingsRowModel
    let saveType: ProfileSaveType
    
    var body: some View {
        HStack {
            ReadOnlySettingsRow(row: row)
            
            Spacer()
            
            Menu("Change") {
                let enumCases = selectEnumCases(for: row.title)
                ForEach(enumCases.indices, id: \.self) { index in
                    Button {
                        content = enumCases[index].stringVal
                        viewModel.save(for: saveType)
                    } label: {
                        HStack {
                            Text(enumCases[index].stringVal)
                            
                            if enumCases[index].stringVal == content {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            .menuTextStyle()
        }
    }
}

extension MenuSettingsRow {
    func selectEnumCases(for title: String) -> [CustomStringConvertible] {
        switch title {
        case "Gender":
            return Gender.allCases
        case "Relationship Status":
            return RelationshipStatus.allCases
        case "Major":
            return StudentMajor.allCases
        default:
            fatalError("Invalid title")
        }
    }
}

struct ReadOnlySettingsRow: View {
    @EnvironmentObject var viewModel: SettingsViewModel
    let row: SettingsRowModel
    var content = ""
    
    var body: some View {
        HStack {
            if let icon = row.icon {
                SettingsIconAndTitle(icon: icon, title: row.title)
            }
            
            Spacer()
            
            if content != "" {
                Text(content)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
    }
}

struct ToggleSettingsRow: View {
    @EnvironmentObject var viewModel: SettingsViewModel
    @Binding var isOn: Bool
    let row: SettingsRowModel
    let saveType: ProfileSaveType
    
    var body: some View {
        Toggle(row.title, isOn: $isOn)
            .font(.body)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .onChange(of: isOn) { newValue in
                viewModel.showAgeOnProfile = newValue
                viewModel.save(for: saveType)
            }
    }
}

struct SettingsIconAndTitle: View {
    let icon: String
    let title: String

    var body: some View {
        HStack {
            SettingIcon(icon: icon, color: .white)

            Text(title)
                .font(.body)
                .foregroundColor(.white)
        }
    }
}

struct SettingIcon: View {
    let icon: String
    let color: Color
    
    var body: some View {
        if icon == "instagram" {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .fontWeight(.medium)
        } else if icon == "relationship" || icon == "diploma" {
            Image(icon)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .foregroundColor(color)
                .frame(width: 18, height: 18)
                .fontWeight(.medium)
        } else {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .foregroundColor(color)
                .frame(width: 18, height: 18)
                .fontWeight(.medium)
        }
    }
}