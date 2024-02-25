//
//  MultilineTextField.swift
//  mixer
//
//  Created by Peyton Lyons on 2/23/24.
//

import SwiftUI

struct MultilineTextField: View {
    @FocusState private var isFocused
    @Binding var text: String
    var title: String?
    var placeholder: String
    var footnote: String?
    var keyboard: UIKeyboardType = .default
    var limit: Int = 100
    var lineLimit: Int = 3
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let title = title {
                Text(title)
                    .foregroundColor(.white)
                    .font(.title.weight(.semibold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .padding(.bottom, 10)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 5) {
                    TextField(placeholder, text: $text, axis: .vertical)
                        .focused($isFocused)
                        .lineLimit(lineLimit, reservesSpace: true)
                        .keyboardType(keyboard)
                        .disableAutocorrection(true)
                        .foregroundColor(.white)
                        .font(.body)
                        .tint(Color.theme.mixerIndigo)
                        .padding()
                        .background(alignment: .center) {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(lineWidth: isFocused ? 3 : 1)
                                .foregroundColor(Color.theme.mixerIndigo)
                        }
                    
                    CharactersRemainView(currentCount: text.count, limit: limit)
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
