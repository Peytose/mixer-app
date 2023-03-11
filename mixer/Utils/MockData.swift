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
        return User(username: "test_user",
                    email: "test@email.edu",
                    profileImageUrl: "https://images.squarespace-cdn.com/content/v1/53ed0e3ce4b0c296acaeae80/1584577511464-8FDZYWQVXUI1OBS4VTZP/Bonneville14082-Edit-DHWEB%2BNick%2BFerguson%2BDenver%2BBroncos%2BHeadshot%2BPhotography%2Bby%2BAaron%2BLucy%2BDenver%2BColorado%2BHeadshots%2BPhotographer.jpg?format=2500w",
                    name: "William",
                    birthday: Timestamp(date: Date(timeIntervalSince1970: 1028578547)),
                    university: "Mississippi State University",
                    dateJoined: Timestamp(date: Date()),
                    bio: "This is an example bio. Here it is. I'm making it purposely long, so I can see how it looks on a profile.")
    }
    
    static var event: Event {
        return Event(hostUuid: "",
                     hostUsername: "mitthetachi",
                     title: "Welcome to the Jungle",
                     description: "This is an example description!!",
                     eventImageUrl: "https://www.instagram.com/p/CiCVZrfuZkK/media?size=l",
                     startDate: Timestamp(date: Date()),
                     endDate: Timestamp(date: Date()),
                     address: "528 Beacon St, Boston, MA 02215",
                     type: EventType.kickback,
                     isInviteOnly: false,
                     isFull: true,
                     amenities: [EventAmenities.snacks, EventAmenities.alcohol, EventAmenities.outdoorSpace, EventAmenities.soundSystem, EventAmenities.security, EventAmenities.smokingArea, EventAmenities.food, EventAmenities.bathrooms, EventAmenities.nonAlcohol, EventAmenities.firePit, EventAmenities.rooftop, EventAmenities.danceFloor, EventAmenities.dj, EventAmenities.lighting, EventAmenities.drinkingGames],
                     tags: ["example", "test"],
                     ageLimit: 21,
                     capacity: 250,
                     alcoholPresence: true)
    }
    
    static var host: Host {
        return Host(name: "MIT Theta Chi",
                    ownerUuid: "",
                    username: "mitthetachi",
                    hostImageUrl: "https://www.instagram.com/p/CleaBwQOeKV/media?size=l",
                    university: "MIT",
                    typesOfEventsHeld: [.kickback, .mixer],
                    instagramHandle: "mitthetachi",
                    website: "http://ox.mit.edu/main/",
                    address: "528 Beacon St, Boston, MA 02215",
                    bio: "The best frat in the greater Boston area")
    }
}
