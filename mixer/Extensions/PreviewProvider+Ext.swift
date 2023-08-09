//
//  PreviewProvider+Ext.swift
//  mixer
//
//  Created by Peyton Lyons on 7/28/23.
//

import SwiftUI
import Firebase

extension PreviewProvider {
    static var dev: DeveloperPreview {
        return DeveloperPreview.shared
    }
}

class DeveloperPreview {
    static let shared = DeveloperPreview()
    
    let mockUser = User(id: NSUUID().uuidString,
                        dateJoined: Timestamp(date: Date()),
                        name: "Peyton Lyons",
                        displayName: "Pyrone",
                        username: "peyton123",
                        email: "test@example.edu",
                        profileImageUrl: "https://images.squarespace-cdn.com/content/v1/53ed0e3ce4b0c296acaeae80/1584577511464-8FDZYWQVXUI1OBS4VTZP/Bonneville14082-Edit-DHWEB%2BNick%2BFerguson%2BDenver%2BBroncos%2BHeadshot%2BPhotography%2Bby%2BAaron%2BLucy%2BDenver%2BColorado%2BHeadshots%2BPhotographer.jpg?format=2500w",
                        birthday: Timestamp(date: Date(timeIntervalSince1970: 1028578547)),
                        university: "MIT",
                        gender: .man,
                        accountType: .host,
                        relationshipStatus: RelationshipStatus.taken,
                        major: StudentMajor.computerScience,
                        instagramHandle: "mixerpartyapp",
                        bio: "This is an example bio. Here it is. I'm making it purposely long, so I can see how it looks on a profile.",
                        showAgeOnProfile: false,
                        isHost: true,
                        associatedHosts: [])
    
    let mockEvent = Event(id: NSUUID().uuidString,
                          hostUuid: "",
                          hostName: "Theta Chi",
                          timePosted: Timestamp(),
                          eventImageUrl: "https://www.instagram.com/p/CqBwaJ3gcyU/media?size=l",
                          title: "Neon Party",
                          description: "Neon party at Theta Chi, need we say more?",
                          type: .kickback,
                          note: "",
                          address: "528 Beacon St, Boston, MA 02215",
                          altAddress: "Theta Chi",
                          geoPoint: GeoPoint(latitude: 42.35071,
                                             longitude: -71.09097),
                          amenities: [.alcohol,
                                      .bathrooms,
                                      .beer,
                                      .drinkingGames,
                                      .water,.dj,
                                      .danceFloor,
                                      .coatCheck],
                          checkInMethods: [CheckInMethod.qrCode],
                          containsAlcohol: true,
                          startDate: Timestamp(),
                          endDate: Timestamp(),
                          registrationDeadlineDate: Timestamp(),
                          guestLimit: 300,
                          guestInviteLimit: 5,
                          memberInviteLimit: 10,
                          isInviteOnly: true,
                          isManualApprovalEnabled: true,
                          isGuestlistEnabled: true,
                          isWaitlistEnabled: false,
                          averageRating: 4.7)
    
    let mockHost = Host(id: NSUUID().uuidString,
                        mainUserId: "",
                        dateJoined: Timestamp(),
                        name: "MIT Theta Chi",
                        username: "thetachi",
                        hostImageUrl: "https://www.instagram.com/p/CleaBwQOeKV/media?size=l",
                        university: "MIT",
                        type: .fraternity,
                        typesOfEvents: [EventType.kickback, EventType.mixer],
                        instagramHandle: "mitthetachi",
                        website: "http://ox.mit.edu/main/",
                        tagline: "The best frat in the greater Boston area",
                        description: "We like to throw parties every friday.",
                        address: "528 Beacon St, Boston, MA 02215",
                        location: GeoPoint(latitude: 42.35071,
                                           longitude: -71.09097),
                        memberIds: [])
}
