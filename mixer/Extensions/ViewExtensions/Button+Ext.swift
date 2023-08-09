//
//  Button+Ext.swift
//  mixer
//
//  Created by Jose Martinez on 5/15/23.
//

import SwiftUI

struct SmallButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2)
            .fontWeight(.medium)
            .foregroundColor(configuration.isPressed ? .white.opacity(0.5) : .white )
            .padding(20)
            .contentShape(Rectangle())
    }
}
