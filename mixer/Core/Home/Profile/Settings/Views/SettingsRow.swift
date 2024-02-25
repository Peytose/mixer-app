//
//  SettingsRow.swift
//  mixer
//
//  Created by Peyton Lyons on 7/19/23.
//

import SwiftUI

struct SettingsRow<ViewModel>: View where ViewModel: SettingsConfigurable {
    let row: SettingsRowModel
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        if viewModel.shouldShowRow(with: row.title) {
            switch row.type {
            case .editable:
                EditableSettingsRow(content: viewModel.content(for: row.title).wrappedValue,
                                    row: row) {
                    viewModel.chosenRow = row
                    viewModel.action(for: row.title)
                }
            case .empty:
                MenuSettingsRow(content: viewModel.content(for: row.title),
                                row: row) {
                    viewModel.save(for: viewModel.saveType(for: row.title))
                }
            case .readOnly:
                if viewModel.content(for: row.title).wrappedValue != "" {
                    ReadOnlySettingsRow(row: row,
                                        content: viewModel.content(for: row.title).wrappedValue)
                }
            case .toggle:
                ToggleSettingsRow(isOn: viewModel.toggle(for: row.title),
                                  row: row) { [saveType = viewModel.saveType(for: row.title)] in
                    viewModel.save(for: saveType)
                }
            case .mail:
                MailSettingsRow(row: row)
            case .link:
                LinkSettingsRow(row: row,
                                url: viewModel.url(for: row.title))
            case .navigate:
                NavigableSettingsRow(row: row) {
                    viewModel.destination(for: row.title)
                }
            }
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
                
                SettingIcon(icon: "arrowshape.turn.up.right", color: .secondary)
            }
        }
        .sheet(isPresented: $isPresented) {
            if let subject = row.subject {
                MailViewModal(isShowing: $isPresented, subject: subject)
            }
        }
    }
}

struct NavigableSettingsRow<Content:View>: View {
    let row: SettingsRowModel
    var destination: () -> Content
    
    var body: some View {
        NavigationLink(destination: destination()) {
            HStack {
                if let icon = row.icon {
                    SettingsIconAndTitle(icon: icon, title: row.title)
                }
                
                Spacer()
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
    var content: String
    let row: SettingsRowModel
    let action: () -> Void
    
    var body: some View {
        Button { action() } label: {
            HStack {
                ReadOnlySettingsRow(row: row, content: content)
                
                SettingIcon(icon: "hand.tap", color: .secondary)
            }
        }
    }
}

struct MenuSettingsRow: View {
    @Binding var content: String
    let row: SettingsRowModel
    let saveAction: () -> Void
    
    var body: some View {
        HStack {
            ReadOnlySettingsRow(row: row)
            
            Spacer()
            
            Menu("Change") {
                let enumCases = selectEnumCases(for: row.title)
                ForEach(enumCases.indices, id: \.self) { index in
                    Button {
                        content = enumCases[index].description
                        saveAction()
                    } label: {
                        HStack {
                            Text(enumCases[index].description)
                            
                            if enumCases[index].description == content {
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
            return DatingStatus.allCases
        case "Major":
            return StudentMajor.allCases
        default:
            fatalError("Invalid title")
        }
    }
}

struct ReadOnlySettingsRow: View {
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
    @Binding var isOn: Bool
    let row: SettingsRowModel
    let saveAction: () -> Void
    
    var body: some View {
        Toggle(row.title, isOn: $isOn)
            .font(.body)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .onChange(of: isOn) { _ in
                saveAction()
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
