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
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color.secondary, lineWidth: isSecondaryLabel ? 1 : 0)
                    .background(isSecondaryLabel ? .clear : Color.theme.mixerIndigo)
                    .cornerRadius(3)
                
                Text(text)
                    .font(.footnote)
                    .foregroundColor(isSecondaryLabel ? .secondary : .white)
            }
        }
        .frame(width: 100, height: 32)
        .contentShape(Rectangle())
    }
}
