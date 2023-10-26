//
//  Array+Ext.swift
//  mixer
//
//  Created by Peyton Lyons on 8/8/23.
//

import Foundation

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

extension Array where Element == String {
    func joinedWithCommasAndAnd() -> String {
        switch count {
        case 0:
            return ""
        case 1:
            return self[0]
        case 2:
            return "\(self[0]) and \(self[1])"
        default:
            let allButLast = self.dropLast().joined(separator: ", ")
            let last = self[count - 1]
            return "\(allButLast), and \(last)"
        }
    }
}
