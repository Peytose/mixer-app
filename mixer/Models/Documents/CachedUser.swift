////
////  User.swift
////  mixer
////
////  Created by Peyton Lyons on 3/8/23.
////
//
//import SwiftUI
//import Firebase
//import FirebaseFirestoreSwift
//import CoreLocation
//
//struct User: Hashable, Identifiable, Codable {
//    // Metadata
//    var id: String?
//    var dateJoined: Timestamp
//    
//    // Basic Information
//    var name: String
//    var displayName: String
//    let username: String
//    let email: String
//    var profileImageUrl: String
//    var birthday: Timestamp
//    var universityData: [String: String]
//    
//    // Additional Information
//    var datingStatus: DatingStatus?
//    var major: StudentMajor?
//    var userOptions: [String: Bool]
//    var instagramHandle: String?
//    var bio: String?
//    var age: Int?
//    
//    // Flags
//    var relationshiptoUser: UserRelationship?
//    var isHost: Bool?     = false
//    var isSignedUp: Bool? = false
//    var isCurrentUser: Bool { return AuthViewModel.shared.userSession?.uid == id }
//    
//    // Associated Data
//    var hostPrivileges: [String: HostPrivileges]?
//    var memberHosts: [Host]?
//    
//    init(from user: User) {
//        self.id                 = user.id
//        self.dateJoined         = user.dateJoined
//        self.name               = user.name
//        self.displayName        = user.displayName
//        self.username           = user.username
//        self.email              = user.email
//        self.profileImageUrl    = user.profileImageUrl
//        self.birthday           = user.birthday
//        self.universityData     = user.universityData
//        
//        if let datingStatus = user.datingStatus {
//            self.datingStatus = datingStatus
//        }
//        
//        if let major = user.major {
//            self.major = major
//        }
//        
//        self.userOptions        = user.userOptions
//        self.instagramHandle    = user.instagramHandle
//        self.bio                = user.bio
//        
//        if let age = Calendar.current.dateComponents([.year], from: user.birthday.dateValue(), to: Date()).year {
//            self.age            = age
//        }
//        
//        self.hostPrivileges     = user.hostPrivileges
//    }
//}
