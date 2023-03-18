//
//  SignUpTextField.swift
//  mixer
//
//  Created by Peyton Lyons on 11/16/22.
//

import SwiftUI

struct SignUpTextField: View {
    @Binding var input: String
    
    var title: String?
    var placeholder: String
    var footnote: String?
    var keyboard: UIKeyboardType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            if let title = title {
                Text(title)
                    .foregroundColor(.mainFont)
                    .font(.title)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .padding(.bottom, 10)
            }
            
            TextField(placeholder, text: $input)
                .keyboardType(keyboard)
                .disableAutocorrection(true)
                .foregroundColor(Color.mainFont)
                .font(.title2)
                .tint(Color.mixerIndigo)
                .padding(.bottom, -5)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray)
            
            if let footnote = footnote {
                Text(footnote)
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }
        }
        .frame(width: DeviceTypes.ScreenSize.width / 1.2)
    }
}

struct SignUpTextField2: View {
    @Binding var input: String
    @State var isEditing = false

    var title: String?
    var note: String?
    var placeholder: String
    var footnote: String?
    var textfieldHeader: String?
    var keyboard: UIKeyboardType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title = title {
                Text(title)
                    .font(.largeTitle)
                    .foregroundColor(.mainFont)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .padding(.bottom, 10)
            }
            
            if let note = note {
                Text(note)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .padding(.bottom)
                    .padding(.top, -6)


            }
            
            if let textfieldHeader = textfieldHeader {
                Text(textfieldHeader)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
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
                .keyboardType(keyboard)
                .disableAutocorrection(true)
                .foregroundColor(Color.mainFont)
                .font(.title3)
                .tint(Color.mixerIndigo)
                .padding(EdgeInsets(top: 12, leading: 10, bottom: 12, trailing: 10))
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(lineWidth: isEditing ? 3 : 1)
                }
            
            if let footnote = footnote {
                Text(footnote)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: DeviceTypes.ScreenSize.width * 0.9)
    }
}

struct SignUpTextField_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            SignUpTextField(input: .constant(""), title: "Peyton, is this a placeholder?", placeholder: "Placeholder", footnote: "This is a footnote placeholder.", keyboard: .default)
        }
        .preferredColorScheme(.dark)
        
        ZStack {
            Color.black
            SignUpTextField2(input: .constant(""), title: "Peyton, is this a placeholder?", note: "penis", placeholder: "Placeholder", footnote: "This is a footnote placeholder.", textfieldHeader: "Placeholder", keyboard: .default)
        }
        .preferredColorScheme(.dark)
    }
}
