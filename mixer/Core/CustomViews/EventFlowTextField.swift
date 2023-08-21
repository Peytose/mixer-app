//
//  EventFlowTextField.swift
//  mixer
//
//  Created by Jose Martinez on 4/6/23.
//

import SwiftUI

struct EventFlowTextField: View {
    // Properties related to labels and inputs
    var title: String?
    let placeholder: String
    var footnote: String?
    
    // Properties related to input states
    @Binding var input: String
    
    // UI configurations
    let keyboardType: UIKeyboardType
    private var borderLineWidth: CGFloat {
        input.isEmpty ? 1 : 3
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title = title {
                Text(title)
                    .primaryHeading()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                TextField(placeholder, text: $input)
                    .tint(Color.theme.mixerIndigo)
                    .keyboardType(keyboardType)
                    .disableAutocorrection(true)
                    .padding(EdgeInsets(top: 12, leading: 10, bottom: 12, trailing: 10))
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(lineWidth: borderLineWidth)
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
