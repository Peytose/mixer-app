//
//  Card.swift
//  mixer
//
//  Created by Jose Martinez on 3/20/23.
//

import SwiftUI
import Foundation


struct LaunchScreenCard: Identifiable {
    var id  = UUID()
    var image : String
    var title : String
}

var screens: [LaunchScreenCard] = [
    LaunchScreenCard( image: "landingPage-image-1", title: "Never miss an event again"),
    //Event picture
    
    LaunchScreenCard( image: "landingPage-image-3", title: "Discover hosts and events near you"),
    //Map picture
        
    LaunchScreenCard( image: "landingPage-image-2", title: "Follow and connect with hosts"),
    //Hosts picture
    
    LaunchScreenCard( image: "landingPage-image-4", title: "Add friends and never party alone"),
    //Friend profile picture

    LaunchScreenCard( image: "qrcode", title: "Fast and reliable check in"),
    //QRCode view
]
