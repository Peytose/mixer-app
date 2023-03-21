//
//  Card.swift
//  mixer
//
//  Created by Jose Martinez on 3/20/23.
//

import SwiftUI
import Foundation


struct Card: Identifiable {
    var id  = UUID()
    var image : String
    var title : String
}

var testData:[Card] = [
// Card( image: "blank",title: "Trying to join Netflix", description: "You can't sign up for Netflix in the app. We know it's a hassle."),

 Card(image: "landingPage-image-1-blur-7", title: "One notification every day"),
 
 Card( image: "landingPage-image-1-blur-8",title: "One notification every day"),
 
 Card( image: "landingPage-image-1-blur-9",title: "One notification every day"),
 
 Card( image: "screen3",title: "Comment and react with your friends"),

]
