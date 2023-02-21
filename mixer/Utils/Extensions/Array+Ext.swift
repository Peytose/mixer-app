//
//  Array+Ext.swift
//  mixer
//
//  Created by Peyton Lyons on 2/14/23.
//

import SwiftUI

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}
