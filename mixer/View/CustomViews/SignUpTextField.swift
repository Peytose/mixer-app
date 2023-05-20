//
//  SignUpTextField.swift
//  mixer
//
//  Created by Peyton Lyons on 11/16/22.
//

import SwiftUI

struct SignUpTextField: View {
    @State var isEditing = false
    @Binding var input: String

    var title: String?
    var note: String?
    var placeholder: String
    var footnote: String?
    var textfieldHeader: String?
    var keyboard: UIKeyboardType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let title = title {
                Text(title)
                    .textFieldTitle()
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
            }
            
            if let note = note {
                Text(note)
                    .textFieldNote()
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                if let textfieldHeader = textfieldHeader {
                    Text(textfieldHeader)
                        .textFieldHeader()
                }
                
                TextField(placeholder, text: $input, onEditingChanged: { (editingChanged) in
                    withAnimation(.easeIn(duration: 0.02)) {
                        isEditing = editingChanged
                    }
                })
                .textFieldStyle(keyboardType: keyboard, disableAutocorrection: true)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(lineWidth: isEditing ? 3 : 1)
                        .foregroundColor(Color.mixerIndigo)
                }
                
                if let footnote = footnote {
                    Text(footnote)
                        .textFieldFootnote()
                }
            }
        }
        .textFieldFrame()
    }
}

struct SignUpTextField_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            SignUpTextField(input: .constant(""), title: "Title", note: "Note", placeholder: "Header", footnote: "This is a footnote", textfieldHeader: "Placeholder", keyboard: .default)
        }
        .preferredColorScheme(.dark)
    }
}
