//
//  Binding+Ext.swift
//  mixer
//
//  Created by Peyton Lyons on 3/22/23.
//

import SwiftUI

extension Binding where Value == Bool {
    var not: Binding<Value> {
        Binding<Value>(
            get: { !self.wrappedValue },
            set: { self.wrappedValue = !$0 }
        )
    }
}

extension Binding where Value == [String: Bool] {
    func binding(for key: String) -> Binding<Bool> {
        return Binding<Bool>(
            get: { self.wrappedValue[key] ?? false },
            set: { newValue in self.wrappedValue[key] = newValue }
        )
    }
}
