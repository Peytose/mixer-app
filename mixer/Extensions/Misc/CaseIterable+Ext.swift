//
//  CaseIterable+Ext.swift
//  mixer
//
//  Created by Peyton Lyons on 2/24/24.
//

import Foundation

extension CaseIterable where Self: Equatable {
    func advanced(by n: Int) -> Self {
        let all = Array(Self.allCases)
        let idx = (all.firstIndex(of: self)! + n) % all.count
        if idx >= 0 {
            return all[idx]
        } else {
            return all[all.count + idx]
        }
    }
}
