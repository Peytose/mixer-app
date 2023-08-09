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
    let footnote: String?
    
    // Properties related to input states
    @Binding var input: String
    @Binding var isNoteAdded: Bool
    @State private var isEditing    = false
    
    // UI configurations
    let keyboardType: UIKeyboardType
    var showNoteToggle: Bool = false
    private var borderLineWidth: CGFloat {
        isEditing ? 3 : 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                if let title = title {
                    Text(title)
                        .primaryHeading()
                    
                    Spacer()
                    
                    if showNoteToggle {
                        Toggle("Add Notes", isOn: $isNoteAdded)
                            .toggleStyle(iOSCheckboxToggleStyle())
                            .buttonStyle(.plain)
                    }
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                TextField(placeholder, text: $input)
                    .keyboardType(keyboardType)
                    .disableAutocorrection(true)
                    .onChange(of: input) { _ in
                        withAnimation(.easeIn(duration: 0.02)) {
                            isEditing.toggle()
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(lineWidth: borderLineWidth)
                            .foregroundColor(Color.theme.mixerIndigo)
                    )
                
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


struct EventFlowTextField_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            EventFlowTextField(title: "",
                               placeholder: "",
                               footnote: "",
                               input: .constant(""),
                               isNoteAdded: .constant(true),
                               keyboardType: .default,
                               showNoteToggle: true)
        }
        .preferredColorScheme(.dark)
    }
}
