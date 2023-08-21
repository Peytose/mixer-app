//
//  CustomStringConvertible.swift
//  mixer
//
//  Created by Peyton Lyons on 8/7/23.
//

import Foundation

extension CustomStringConvertible where Self: CaseIterable & Codable {
    static func enumCase(from descriptionue: String) -> Self? {
        for item in Self.allCases {
            if item.description == descriptionue {
                return item
            }
        }
        return nil
    }
}
