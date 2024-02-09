//
//  NotificationCategoryCell.swift
//  mixer
//
//  Created by Peyton Lyons on 2/4/24.
//

import SwiftUI

struct NotificationCategoryCell: View {
    var text: String
    var isSecondaryLabel: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.footnote)
                .fontWeight(isSecondaryLabel ? .medium : .semibold)
                .foregroundColor(isSecondaryLabel ? .secondary : .white)
                .padding(.vertical, 10)
                .padding(.horizontal, 12) // Adjust padding as needed
                .background(isSecondaryLabel ? Color.clear : Color.theme.mixerIndigo)
                .cornerRadius(3)
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.secondary, lineWidth: isSecondaryLabel ? 1 : 0)
                )
        }
        .contentShape(Rectangle())
    }
}
