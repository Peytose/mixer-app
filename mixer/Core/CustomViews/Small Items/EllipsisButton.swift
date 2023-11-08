//
//  EllipsisButton.swift
//  mixer
//
//  Created by Peyton Lyons on 11/5/23.
//

import SwiftUI

struct EllipsisButton: View {
    let action: () -> Void
    
    var body: some View {
        Image(systemName: "ellipsis")
            .font(.callout)
            .foregroundColor(.white)
            .padding(10)
            .contentShape(Rectangle())
            .background {
                Circle()
                    .stroke(lineWidth: 1.3)
                    .foregroundColor(.white)
            }
            .onTapGesture {
                action()
            }
    }
}

#Preview {
    EllipsisButton() {}
}
