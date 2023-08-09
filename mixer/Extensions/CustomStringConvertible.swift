//
//  CustomStringConvertible.swift
//  mixer
//
//  Created by Peyton Lyons on 8/7/23.
//

import Foundation

extension CustomStringConvertible where Self: CaseIterable & Codable {
    static func enumCase(from stringValue: String) -> Self? {
        for item in Self.allCases {
            if item.stringVal == stringValue {
                return item
            }
        }
        return nil
    }
}
