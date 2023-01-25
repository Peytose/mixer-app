//
//  Animation+Ext.swift
//  mixer
//
//  Created by Jose Martinez on 12/21/22.
//

import SwiftUI

extension Animation {
    static let openCard = Animation.spring(response: 0.5, dampingFraction: 0.75)
    static let closeCard = Animation.spring(response: 0.7, dampingFraction: 0.75)
    static let flipCard = Animation.spring(response: 0.35, dampingFraction: 0.7)
    static let tabSelection = Animation.spring(response: 0.3, dampingFraction: 0.7)
}
