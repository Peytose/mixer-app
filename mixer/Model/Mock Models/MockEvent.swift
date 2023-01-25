//
//  MockEvent.swift
//  mixer
//
//  Created by Jose Martinez on 1/5/23.
//

import Foundation

struct MockEvent: Identifiable {
    let id = UUID()
    var hostName: String
    var fullHostName: String
    var visibility: String
    var title: String
    var attendance: String
    var date: String
    var shortDate: String
    var stickyMonth: String
    var stickyDay: String
    var duration: String
    var startTime: String
    var wetOrDry: String
    var description: String
    var theme: String
    var attireDescription: String
    var flyer: String
    var school: String
    var address: String
    var type: String
    var hasNote: Bool
    var note: String
    var schoolValues: [Double]
    var genderValues: [Double]
    var relationshipValues: [Double]
    var schoolNames: [String]
}
var events = [
    MockEvent(hostName: "MIT Theta Chi", fullHostName: "MIT Theta Chi Fraternity", visibility: "Invite Only", title: "Neon Party", attendance: "196", date: "Friday, January 20", shortDate: "Friday, 10:00 PM", stickyMonth: "Jan", stickyDay: "24", duration: "10:00 PM - 1:00 AM", startTime: "10:00 PM", wetOrDry: "Wet", description: "Neon party at Theta Chi this friday night, need we say more?", theme: "Neon/Black light", attireDescription: "Normal party clothes (wear neon if possible)", flyer: "theta-chi-party-poster", school: "MIT", address: "528 Beacon St, Boston MA", type: "Frat Party", hasNote: false, note: "", schoolValues: [90, 42, 25, 28, 11], genderValues: [122, 58, 16], relationshipValues: [158, 24, 14], schoolNames: ["BU", "NEU", "Harvard", "MIT", "Other"]),
    MockEvent(hostName: "MIT Theta Chi", fullHostName: "MIT Theta Chi Fraternity", visibility: "Open", title: "Theta SpooChi", attendance: "455", date: "Friday, January 27", shortDate: "Friday, 10:00 PM", stickyMonth: "Jan", stickyDay: "27", duration: "10:00 PM - 1:00 AM", startTime: "10:00 PM", wetOrDry: "Wet", description: "Halloween Party. Come with a costume or no entry", theme: "Halloween", attireDescription: "Costumes only (No costume, no entry!)", flyer: "theta-chi-party-poster-2", school: "MIT", address: "528 Beacon St, Boston MA", type: "Frat Party", hasNote: true, note: "Guests must come in a halloween costume or they will be turned away at the door", schoolValues: [169, 121, 75, 49, 41], genderValues: [299, 80, 76], relationshipValues: [158, 24, 14], schoolNames: ["BU", "NEU", "Wellesley", "MIT", "Other"]),
    MockEvent(hostName: "MIT Theta Chi", fullHostName: "MIT Theta Chi Fraternity", visibility: "Open", title: "Rolling Loud Party", attendance: "250", date: "Friday, February 3", shortDate: "Friday, 10:00 PM", stickyMonth: "Feb", stickyDay: "3", duration: "10:00 PM - 1:00 AM", startTime: "10:00 PM", wetOrDry: "Wet", description: "Theta Chi's take on rolling loud. Will be playing music from hip hop artists featured at this year's Rolling Loud Miami concert. We will also be throwing water bags at the crowd so be ready to get wet", theme: "Rave Party", attireDescription: "Hip-Hop Concert attire (Rolling Loud Clothes)", flyer: "theta-chi-party-poster-3", school: "MIT", address: "528 Beacon St, Boston MA", type: "Frat Party", hasNote: true, note: "Be prepared to get wet as in order to get into the spirit of things, we will be throwing bags of water into the crowd", schoolValues: [90, 42, 25, 28, 11], genderValues: [122, 58, 16], relationshipValues: [158, 24, 14], schoolNames: ["BU", "NEU", "Harvard", "MIT", "Other"]),
    MockEvent(hostName: "MIT Theta Chi", fullHostName: "MIT Theta Chi Fraternity", visibility: "Invite Only", title: "Rush Jungle Party", attendance: "502", date: "Friday, February 10", shortDate: "Friday, 10:00 PM", stickyMonth: "Feb", stickyDay: "10", duration: "10:00 PM - 1:00 AM", startTime: "10:00 PM", wetOrDry: "Wet", description: "Theta Chi is the king of the jungle. Pull up for some free 🦍🧃", theme: "Jungle Themed Party", attireDescription: "Safari/Jungle Clothes", flyer: "theta-chi-party-poster-4", school: "MIT", address: "528 Beacon St, Boston MA", type: "Frat Party", hasNote: false, note: "Only MIT Freshman and friends of the house will get entry, as this is an MIT Rush Event", schoolValues: [90, 42, 25, 28, 11], genderValues: [122, 58, 16], relationshipValues: [158, 24, 14], schoolNames: ["BU", "NEU", "Harvard", "MIT", "Other"]),
    MockEvent(hostName: "MIT Phi Sigma Kappa", fullHostName: "MIT Phi Sigma Kappa Fraternity", visibility: "Invite Only", title: "Tropical Party", attendance: "389", date: "Saturday, February 11", shortDate: "Saturday, 10:00 PM", stickyMonth: "Feb", stickyDay: "11", duration: "10:00 PM - 1:00 AM", startTime: "10:00 PM", wetOrDry: "Wet", description: "Join Phi Sig this weekend for a troppical themed party! JJ will be served 😎", theme: "Tropical Themed Party", attireDescription: "Wear your best tropical clothes or hawaiian shirts", flyer: "theta-chi-party-poster-5", school: "MIT", address: "528 Beacon St, Boston MA", type: "Frat Party", hasNote: false, note: "", schoolValues: [90, 42, 25, 28, 11], genderValues: [122, 58, 16], relationshipValues: [158, 24, 14], schoolNames: ["BU", "NEU", "Harvard", "MIT", "Other"]),
]
