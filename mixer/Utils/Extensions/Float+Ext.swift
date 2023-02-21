//
//  Float+Ext.swift
//  mixer
//
//  Created by Peyton Lyons on 1/29/23.
//

import SwiftUI

extension Float {
    func roundToDigits(_ digits: Int) -> String {
        return String(format: "%.\(digits)f", self)
    }
}
