//
//  ListCellActionButton.swift
//  mixer
//
//  Created by Peyton Lyons on 8/30/23.
//

import SwiftUI

struct ListCellActionButton: View {
    var text: String = ""
    var isIcon: Bool = false
    var isSecondaryLabel: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.secondary, lineWidth: isSecondaryLabel ? 1 : 0)
                    .background(isSecondaryLabel ? .clear : Color.theme.mixerIndigo)
                    .cornerRadius(10)
                
                if isIcon {
                    Image(systemName: text)
                        .imageScale(.small)
                        .foregroundColor(isSecondaryLabel ? .secondary : .white)
                } else {
                    Text(text)
                        .font(.caption)
                        .foregroundColor(isSecondaryLabel ? .secondary : .white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 18)
                }
            }
        }
        .buttonStyle(.borderless)
        .frame(width: isIcon ? 32 : 100, height: 32)
        .contentShape(Rectangle())
    }
}
