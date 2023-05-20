//
//  DynamicLinkManager.swift
//  mixer
//
//  Created by Peyton Lyons on 5/19/23.
//

import SwiftUI

class DynamicLinkManager: ObservableObject {
    static let shared = DynamicLinkManager()
    @Published var profileToPresent: CachedUser? = nil
}
