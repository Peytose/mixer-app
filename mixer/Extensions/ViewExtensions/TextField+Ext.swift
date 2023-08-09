//
//  TextField+Ext.swift
//  mixer
//
//  Created by Jose Martinez on 5/15/23.
//

import SwiftUI

extension TextField {
    func textFieldStyle(keyboardType: UIKeyboardType, disableAutocorrection: Bool = false) -> some View {
        self
            .font(.title3)
            .foregroundColor(.white)
            .tint(Color.theme.mixerIndigo)
            .keyboardType(keyboardType)
            .disableAutocorrection(disableAutocorrection)
            .padding(EdgeInsets(top: 12, leading: 10, bottom: 12, trailing: 10))
        
    }
}
