//
//  CustomTabBarStyle.swift
//  mixer
//
//  Created by Jose Martinez on 1/11/23.
//

import SwiftUI
import TabBar

struct CustomTabBarStyle: TabBarStyle {
    
    
//    public func tabBar(with geometry: GeometryProxy, itemsContainer: @escaping () -> AnyView) -> some View {
//        itemsContainer()
//            .background(Color.theme.secondaryBackgroundColor)
//            .cornerRadius(25.0)
//            .frame(height: 60.0)
//            .frame(maxWidth: DeviceTypes.ScreenSize.width, alignment: .center)
//            .padding(.horizontal, 50)
//            .padding(.bottom, 16.0 + geometry.safeAreaInsets.bottom)
//    }
    
    public func tabBar(with geometry: GeometryProxy, itemsContainer: @escaping () -> AnyView) -> some View {
        itemsContainer()
    }
}
