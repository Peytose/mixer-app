//
//  Constants.swift
//  mixer
//
//  Created by Peyton Lyons on 11/11/22.
//

import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import UIKit

let COLLECTION_USERS: CollectionReference = Firestore.firestore().collection("users")
let COLLECTION_HOSTS: CollectionReference = Firestore.firestore().collection("hosts")
let COLLECTION_RELATIONSHIPS: CollectionReference = Firestore.firestore().collection("relationships")
let COLLECTION_FOLLOWERS: CollectionReference = Firestore.firestore().collection("followers")
let COLLECTION_FOLLOWING: CollectionReference = Firestore.firestore().collection("following")
let COLLECTION_UNIVERSITIES: CollectionReference = Firestore.firestore().collection("universities")
let COLLECTION_EVENTS: CollectionReference = Firestore.firestore().collection("events")
let COLLECTION_WAITLISTS: CollectionReference = Firestore.firestore().collection("waitlists")
let COLLECTION_NOTIFICATIONS: CollectionReference = Firestore.firestore().collection("notifications")

enum RecordType {
    static let host     = "HostOrganization"
    static let profile  = "UserProfile"
    static let event    = "EventRecord"
}

enum PlaceholderImage {
    static let avatar     = UIImage(named: "default-avatar")!
    static let square     = UIImage(named: "default-square-asset")!
    static let crest      = UIImage(named: "Theta Chi Crest")!
    static let banner     = UIImage(named: "default-banner-asset")!
    static let university = UIImage(named: "default-university-asset")!
    static let event      = UIImage(named: "theta-chi-party-poster")!
}

enum ImageDimension {
    case square, banner
    
    var placeHolder: UIImage {
        switch self {
            case .square:
                return PlaceholderImage.square
            case .banner:
                return PlaceholderImage.banner
        }
    }
}

enum DeviceTypes {
    enum ScreenSize {
        static let width                = UIScreen.main.bounds.size.width
        static let height               = UIScreen.main.bounds.size.height
        static let maxLength            = max(ScreenSize.width, ScreenSize.height)
    }
    
    static let idiom                    = UIDevice.current.userInterfaceIdiom
    static let nativeScale              = UIScreen.main.nativeScale
    static let scale                    = UIScreen.main.scale

    static let isiPhone8Standard        = idiom == .phone && ScreenSize.maxLength == 667.0 && nativeScale == scale
}
