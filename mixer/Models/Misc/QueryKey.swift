//
//  QueryKey.swift
//  mixer
//
//  Created by Peyton Lyons on 1/16/24.
//

import Foundation

struct QueryKey {
    var collectionPath: String
    var filters: [String] = [] // Simplified representation of filters
    var orders: [String] = [] // Simplified representation of order-by clauses
    var limit: Int?

    var key: String {
        var components = [collectionPath]
        components.append(contentsOf: filters)
        components.append(contentsOf: orders)
        if let limit = limit {
            components.append("Limit:\(limit)")
        }
        return components.joined(separator: "-")
    }
}
