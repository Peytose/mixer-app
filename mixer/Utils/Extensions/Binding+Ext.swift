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
