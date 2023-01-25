//
//  UserProfileViewModel.swift
//  mixer
//
//  Created by Jose Martinez on 12/18/22.
//

import CloudKit
import SwiftUI

//MockViewModels
    @MainActor final class UserProfileViewModel: ObservableObject {
        @Published var firstName             = ""
        @Published var lastName              = ""
        @Published var avatar                = UIImage(named: "kingfisher-2.jpg")
        @Published var email                 = ""
        @Published var phone                 = ""
        @Published var birthday              = Date.now
        @Published var gender                = ""
        @Published var university            = ""
        @Published var hasHostStatus         = false
        @Published var isCheckedIn           = false
        @Published var isShowingPhotoPicker  = false
        @Published var isLoading             = false
        @Published var isShowingUpdateButton = false
        @Published var alertItem: AlertItem?
        @Published var contentHasScrolled    = false
        @Published var expandMenu            = false
        @Published var showNavigationBar     = true
        
        private var existingProfileRecord: CKRecord?

    }
