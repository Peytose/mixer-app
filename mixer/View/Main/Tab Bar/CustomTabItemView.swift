//
//  CustomTabItemView.swift
//  mixer
//
//  Created by Jose Martinez on 1/11/23.
//

import SwiftUI
import TabBar

struct CustomTabItemStyle: TabItemStyle {
    public func tabItem(icon: String, title: String, isSelected: Bool) -> some View {
        VStack(spacing: 0) {
            if icon == "magnifyingglass" {
                Image(systemName: icon )
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? Color.mainFont : .systemGray)
                    .scaleEffect(isSelected ? 1.2 : 1.1)
                    .frame(width: 32.0, height: 32.0)
                    .frame(width: 60)
                    .contentShape(Rectangle())
            } else {
                Image(systemName: isSelected ? "\(icon).fill" : icon )
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? Color.mainFont : .systemGray)
                    .scaleEffect(isSelected ? 1.2 : 1.1)
                    .frame(width: 32.0, height: 32.0)
                    .frame(width: 60)
                    .contentShape(Rectangle())
            }
            Text(title)
                .font(.caption)
                .foregroundColor(isSelected ? Color.mainFont : .systemGray)
                .scaleEffect(isSelected ? 1.1 : 1)
        }
        .padding(.bottom, 30)
    }
}

