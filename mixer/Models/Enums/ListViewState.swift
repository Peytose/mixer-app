//
//  ListViewState.swift
//  mixer
//
//  Created by Peyton Lyons on 8/23/23.
//

import SwiftUI

enum ListViewState: Int, Equatable {
    case loading
    case empty
    case list
    
    static func ==(lhs: ListViewState, rhs: ListViewState) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
