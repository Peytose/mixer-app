//
//  MockData.swift
//  mixer
//
//  Created by Peyton Lyons on 11/12/22.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct Mockdata {
    static var user: User {
        return User(uid: "",
                    dateJoined: Timestamp(date: Date()),
                    username: "test_user",
                    email: "test@email.edu",
                    profileImageUrl: "https://images.squarespace-cdn.com/content/v1/53ed0e3ce4b0c296acaeae80/1584577511464-8FDZYWQVXUI1OBS4VTZP/Bonneville14082-Edit-DHWEB%2BNick%2BFerguson%2BDenver%2BBroncos%2BHeadshot%2BPhotography%2Bby%2BAaron%2BLucy%2BDenver%2BColorado%2BHeadshots%2BPhotographer.jpg?format=2500w",
                    name: "William",
                    birthday: Timestamp(date: Date(timeIntervalSince1970: 1028578547)),
                    university: "Mississippi State University",
                    instagramHandle: "mixerpartyapp",
                    bio: "This is an example bio. Here it is. I'm making it purposely long, so I can see how it looks on a profile.")
    }
    
    static var event: Event {
        return Event(hostUuid: "",
                     hostUsername: "mitthetachi",
                     timePosted: Timestamp(),
                     title: "Neon Party",
                     description: "Neon party at Theta Chi, need we say more?",
                     eventImageUrl: "https://www.instagram.com/p/CqBwaJ3gcyU/media?size=l",
                     type: EventType.kickback,
                     address: "528 Beacon St, Boston, MA 02215",
                     amenities: [],
                     startDate: Timestamp(),
                     endDate: Timestamp(),
                     attendance: 50,
                     capacity: 100,
                     guestLimit: "10",
                     guestInviteLimit: "1",
                     memberInviteLimit: "5",
                     eventOptions: [EventOption.containsAlcohol.rawValue: false,
                                    EventOption.isInviteOnly.rawValue: true,
                                    EventOption.isManualApprovalEnabled.rawValue: false,
                                    EventOption.isGuestLimitEnabled.rawValue: false,
                                    EventOption.isWaitlistEnabled.rawValue: false,
                                    EventOption.isMemberInviteLimitEnabled.rawValue: true,
                                    EventOption.isGuestInviteLimitEnabled.rawValue: true,
                                    EventOption.isRegistrationDeadlineEnabled.rawValue: false,
                                    EventOption.isCheckInOptionsEnabled.rawValue: true])
    }
    
    static var host: Host {
        return Host(dateJoined: Timestamp(),
                    name: "MIT Theta Chi",
                    username: "mitthetachi",
                    hostImageUrl: "https://www.instagram.com/p/CleaBwQOeKV/media?size=l",
                    university: "MIT",
                    typesOfEventsHeld: [.kickback, .mixer],
                    instagramHandle: "mitthetachi",
                    website: "http://ox.mit.edu/main/",
                    address: "528 Beacon St, Boston, MA 02215",
                    bio: "The best frat in the greater Boston area",
                    memberUUIDs: [],
                    hostType: .fraternity)
    }
}
