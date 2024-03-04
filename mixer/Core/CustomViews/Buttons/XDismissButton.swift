//
//  XDismissButton.swift
//  mixer
//
//  Created by Jose Martinez on 12/21/22.
//

import SwiftUI

struct XDismissButton: View {
    let action: () -> Void
    var hasBackground: Bool = false // Default value is false

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(hasBackground ? .black : .white)
                .padding(10)
                .background(hasBackground ? Color.white : .clear) // Apply background color conditionally
                .clipShape(Circle())
                .contentShape(Rectangle())
        }
    }
}

