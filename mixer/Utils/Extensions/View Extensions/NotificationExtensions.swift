//
//  NotificationExtensions.swift
//  mixer
//
//  Created by Jose Martinez on 5/13/23.
//

import SwiftUI

//Notification Extensions
extension View {
    //MARK: Regular Notification Modifiers
    func notificationBackground() -> some View {
        self
            .frame(width: DeviceTypes.ScreenSize.width - 20, height: 60)
            .background(Color.mixerSecondaryBackground)
            .cornerRadius(24)
    }
    
    func notificationContentFrame() -> some View {
        self
            .frame(width: DeviceTypes.ScreenSize.width - 60, height: 60, alignment: .leading)
    }
    
    
    //MARK: Short Notification Modifiers
    func notificationBackgroundShort() -> some View {
        self
            .frame(width: DeviceTypes.ScreenSize.width * 0.5, height: 60)
            .background(Color.mixerSecondaryBackground)
            .cornerRadius(24)
    }
    
    func notificationContentFrameShort() -> some View {
        self
            .frame(width: DeviceTypes.ScreenSize.width - 60, height: 60, alignment: .center)
    }
}
