//
//  Keyboard+Ext.swift
//  mixer
//
//  Created by Jose Martinez on 3/18/23.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
