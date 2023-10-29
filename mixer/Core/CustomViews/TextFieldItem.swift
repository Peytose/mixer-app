//
//  TextFieldItem.swift
//  mixer
//
//  Created by Peyton Lyons on 10/28/23.
//

import SwiftUI

struct TextFieldItem: View {
    var title: String?
    let placeholder: String
    @Binding var input: String
    var limit: Int?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            EventFlowTextField(title: title,
                               placeholder: placeholder,
                               input: $input,
                               keyboardType: .default)
            .autocorrectionDisabled()
            
            if let limit = limit {
                CharactersRemainView(currentCount: input.count,
                                     limit: limit)
            }
        }
    }
}

#Preview {
    TextFieldItem(title: "", placeholder: "", input: .constant(""))
}
