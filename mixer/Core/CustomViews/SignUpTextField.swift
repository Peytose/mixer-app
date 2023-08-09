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
    let title: String?
    var note: String?
    let placeholder: String
    var footnote: String?
    let keyboard: UIKeyboardType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let title = title {
                Text(title)
                    .largeTitle(weight: .semibold)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
            }
            
            if let note = note {
                Text(note)
                    .body()
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                TextField(placeholder, text: $input, onEditingChanged: { (editingChanged) in
                    withAnimation(.easeIn(duration: 0.02)) {
                        isEditing = editingChanged
                    }
                })
                .textFieldStyle(keyboardType: keyboard, disableAutocorrection: true)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(lineWidth: isEditing ? 3 : 1)
                        .foregroundColor(Color.theme.mixerIndigo)
                }
                
                if let footnote = footnote {
                    Text(footnote)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
        }
        .textFieldFrame()
    }
}

struct SignUpTextField_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.theme.backgroundColor
                .ignoresSafeArea()
            
            SignUpTextField(input: .constant(""), title: "Title", note: "Note", placeholder: "Header", footnote: "This is a footnote", keyboard: .default)
        }
        .preferredColorScheme(.dark)
    }
}
