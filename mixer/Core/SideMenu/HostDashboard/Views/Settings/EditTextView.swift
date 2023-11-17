//
//  EditTextView.swift
//  mixer
//
//  Created by Jose Martinez on 11/16/23.
//

import SwiftUI

struct EditTextView: View {
    var title: String
    @Binding var text: String
    var navigationTitle: String
    
    var body: some View {
            List {
                textCell
            }
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .listStyle(.insetGrouped)
            .background(Color.theme.backgroundColor)
            .navigationBar(title: navigationTitle, displayMode: .inline)
    }
}

extension EditTextView {
    var textCell: some View {
        SettingsSectionContainer(header: title) {
            TextFieldCell(value: $text)
        }
    }
}

fileprivate struct TextFieldCell: View {
    @Binding var value: String
    
    var body: some View {
        HStack(alignment: .top) {
            TextField("New Text", text: $value, axis: .vertical)
                .lineLimit(8, reservesSpace: true)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.8)
    }
}

struct EditTextView_Previews: PreviewProvider {
    static var previews: some View {
        EditTextView(title: "Title", text: .constant("Example Description"), navigationTitle: "Navigation Bar Title")
            .preferredColorScheme(.dark)
    }
}
