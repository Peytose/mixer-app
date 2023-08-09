//
//  Optional+Ext.swift
//  mixer
//
//  Created by Peyton Lyons on 7/18/23.
//

import SwiftUI

extension Binding where Value == Bool? {
    func unwrappedOrFalse() -> Binding<Bool> {
        return Binding<Bool>(
            get: { self.wrappedValue ?? false },
            set: { newValue in
                self.wrappedValue = newValue
            }
        )
    }
}

extension Binding where Value == String? {
    func unwrappedOrEmpty() -> Binding<String> {
        return Binding<String>(
            get: { self.wrappedValue ?? "" },
            set: { newValue in
                self.wrappedValue = newValue
            }
        )
    }
}
