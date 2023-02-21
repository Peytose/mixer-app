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
            .font(.system(size: 17, weight: .bold))
            .foregroundColor(.secondary)
            .padding(8)
            .background(.ultraThinMaterial)
            .backgroundColor(opacity: 0.2)
            .clipShape(Circle())
    }
}

struct XDismissButton_Previews: PreviewProvider {
    static var previews: some View {
        XDismissButton()
            .preferredColorScheme(.dark)
    }
}
