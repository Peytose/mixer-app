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
            .resizable()
            .scaledToFit()
            .foregroundStyle(Color.white)
            .frame(width: 17, height: 17)
            .padding()
            .contentShape(Rectangle())
            .onTapGesture {
                action()
            }
    }
}

#Preview {
    EllipsisButton() {}
}
