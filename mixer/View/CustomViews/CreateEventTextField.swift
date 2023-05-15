//
//  CreateEventTextField.swift
//  mixer
//
//  Created by Jose Martinez on 4/6/23.
//

import SwiftUI

struct CreateEventTextField: View {
    @Binding var input: String
    @State var isEditing = false
    
    var title: String?
    var note: String?
    var placeholder: String
    var footnote: String?
    var textfieldHeader: String?
    var keyboard: UIKeyboardType
    var hasToggle: Bool?
    @Binding var toggleBool: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                if let title = title {
                    Text(title)
                        .textFieldSmallTitle()
                    
                    Spacer()
                    
                    if hasToggle ?? false {
                        Toggle(isOn: $toggleBool.animation()) {
                            Text("Add Notes")
                        }
                        .toggleStyle(iOSCheckboxToggleStyle())
                        .buttonStyle(.plain)
                    }
                }
                
            }
            if let note = note {
                Text(note)
                    .textFieldNote()
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .padding(.bottom)
                    .padding(.top, -6)
            }
            
            if let textfieldHeader = textfieldHeader {
                Text(textfieldHeader)
                    .textFieldHeader()
            }
            
            TextField(placeholder, text: $input, onEditingChanged: { (editingChanged) in
                if editingChanged {
                    withAnimation(.easeIn(duration: 0.02)) {
                        isEditing = true
                    }
                } else {
                    withAnimation(.easeIn(duration: 0.02)) {
                        isEditing = false
                    }
                }
            })
            .textFieldStyle(keyboardType: keyboard)
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
        .textFieldFrame()
    }
}

struct CreateEventTextField_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            CreateEventTextField(input: .constant(""), title: "Peyton, is this a placeholder?", note: "penis", placeholder: "Placeholder", footnote: "This is a footnote placeholder.", textfieldHeader: "Placeholder", keyboard: .default, toggleBool: .constant(false))
        }
        .preferredColorScheme(.dark)
    }
}
