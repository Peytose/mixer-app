//
//  XDismissButton.swift
//  mixer
//
//  Created by Jose Martinez on 12/21/22.
//

import SwiftUI

struct XDismissButton: View {
    var body: some View {
        Image(systemName: "xmark")
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundColor(.secondary)
            .padding(10)
            .contentShape(Rectangle())
    }
}

struct XDismissButton_Previews: PreviewProvider {
    static var previews: some View {
        XDismissButton()
            .preferredColorScheme(.dark)
    }
}
