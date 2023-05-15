//
//  Frame+Ext.swift
//  mixer
//
//  Created by Jose Martinez on 5/15/23.
//

import SwiftUI

extension View {
    func textFieldFrame() -> some View {
        self
            .frame(width: DeviceTypes.ScreenSize.width * 0.9)
    }
}
