//
//  EventManager.swift
//  mixer
//
//  Created by Peyton Lyons on 2/6/23.
//

import SwiftUI

final class EventManager: ObservableObject {
    @Published var currentAndFutureEvents: [CachedEvent] = []
    @Published var pastEvents: [CachedEvent]  = []
    var selectedEvent: CachedEvent?
}
