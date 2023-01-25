//
//  SignUpTextField.swift
//  mixer
//
//  Created by Peyton Lyons on 11/16/22.
//

import SwiftUI

struct SignUpTextField: View {
    var title: String
    var input: Binding<String>
    var placeholder: String
    var footnote: String
    var keyboard: UIKeyboardType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .foregroundColor(.mainFont)
                .font(.title.weight(.semibold))
                .lineLimit(2)
                .minimumScaleFactor(0.75)
                .padding(.bottom, 5)
            
            TextField(placeholder, text: input)
                .keyboardType(keyboard)
                .disableAutocorrection(true)
                .foregroundColor(Color.mainFont)
                .font(.system(size: 25))
                .tint(Color.purple)
                .padding(.bottom, -5)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray)
            
            Text(footnote)
                .foregroundColor(.secondary)
                .font(.footnote)
        }
        .frame(width: 300)
    }
}

struct SignUpTextField_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            SignUpTextField(title: "Peyton, is this a placeholder?", input: .constant(""), placeholder: "Placeholder", footnote: "This is a footnote placeholder.", keyboard: .default)
        }
        .preferredColorScheme(.dark)
    }
}
