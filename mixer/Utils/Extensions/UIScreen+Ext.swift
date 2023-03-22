//
//  UIScreen+Ext.swift
//  mixer
//
//  Created by Jose Martinez on 3/21/23.
//

import SwiftUI

extension UIScreen {
    static var iPhoneViewWidth: CGFloat {
        (UIScreen.main.bounds.width - 100)
    }
}

extension UIScreen {
    static var iPhoneViewHeight: CGFloat {
        (UIScreen.main.bounds.height / 2)
    }
}
