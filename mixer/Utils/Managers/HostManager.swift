//
//  HostManager.swift
//  mixer
//
//  Created by Peyton Lyons on 2/6/23.
//

import SwiftUI

final class HostManager: ObservableObject {
    @Published var hosts: [CachedHost] = []
    var selectedHost: CachedHost?
}
