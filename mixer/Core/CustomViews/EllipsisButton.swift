//
//  EllipsisButton.swift
//  mixer
//
//  Created by Peyton Lyons on 11/5/23.
//

import SwiftUI

struct EllipsisButton: View {
    var stroke: CGFloat = 1.3
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "ellipsis")
                .font(.callout)
                .foregroundColor(.white)
                .padding(10)
                .contentShape(Rectangle())
                .background {
                    Circle()
                        .stroke(lineWidth: stroke)
                        .foregroundColor(.white)
                }
        }
    }
}

#Preview {
    EllipsisButton() {}
}
