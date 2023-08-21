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
        EmptyView()
    }
}
