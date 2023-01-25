//
//  CustomTabBarStyle.swift
//  mixer
//
//  Created by Jose Martinez on 1/11/23.
//

import SwiftUI
import TabBar

struct CustomTabBarStyle: TabBarStyle {
    let gradient = LinearGradient(gradient: Gradient(colors: [Color.black, Color.black.opacity(1), Color.black.opacity(1), Color.black.opacity(0.975), Color.black.opacity(0.85), Color.black.opacity(0.3), Color.black.opacity(0)]), startPoint: .bottom, endPoint: .top)
    var height: CGFloat = 370
    
    public func tabBar(with geometry: GeometryProxy, itemsContainer: @escaping () -> AnyView) -> some View {
        itemsContainer()
            .frame(height: 80)
            .background(content: {
                Rectangle()
                    .fill(Color.mixerBackground)
                    .mask(gradient)
                    .frame(height: height)
                    .allowsHitTesting(false)
            })
    }
    
}
