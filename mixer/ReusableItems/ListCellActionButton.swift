//
//  ListCellActionButton.swift
//  mixer
//
//  Created by Peyton Lyons on 8/30/23.
//

import SwiftUI

struct ListCellActionButton: View {
    var text: String
    var isSecondaryLabel: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.footnote)
                .frame(width: 100, height: 32)
                .foregroundColor(isSecondaryLabel ? .secondary : .white)
                .background(isSecondaryLabel ? .clear : Color.theme.mixerIndigo)
                .cornerRadius(3)
                .overlay {
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.secondary, lineWidth: isSecondaryLabel ? 1 : 0)
                }
        }
        .fixedSize()
    }
}
