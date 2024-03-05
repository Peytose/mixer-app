//
//  EllipsisButton.swift
//  mixer
//
//  Created by Peyton Lyons on 11/5/23.
//

import SwiftUI

struct EllipsisButton: View {
    let action: () -> Void
    var size: Font = .title2
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(size)
                .foregroundColor(.white)
                .contentShape(Rectangle())
                .padding(10)
        }
    }
}

#Preview {
    EllipsisButton() {}
}
