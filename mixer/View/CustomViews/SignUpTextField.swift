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

struct SignUpTextField_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            SignUpTextField(input: .constant(""), title: "Peyton, is this a placeholder?", placeholder: "Placeholder", footnote: "This is a footnote placeholder.", keyboard: .default)
        }
        .preferredColorScheme(.dark)
    }
}
