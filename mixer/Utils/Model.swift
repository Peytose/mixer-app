//
//  Model.swift
//  mixer
//
//  Created by Jose Martinez on 12/18/22.
//

import SwiftUI
import Combine

class Model: ObservableObject {
    // Tab Bar
    @Published var showTab: Bool = true

    // Navigation Bar
    @Published var showNav: Bool = true

    // Modal
    @Published var selectedModal: Modal = .signUp
    @Published var showModal: Bool = false
    @Published var dismissModal: Bool = false

    // Detail View
    @Published var showDetail: Bool = false
    @Published var selectedCourse: Int = 0
    @Published var selectedEvent: Int = 0
}


enum Modal: String {
    
    case signUp
    case signIn
    
}
