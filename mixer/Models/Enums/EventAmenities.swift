//
//  EventAmenities.swift
//  mixer
//
//  Created by Peyton Lyons on 8/15/23.
//

import Foundation
import SwiftUI

enum AmenityCategory: String, CaseIterable {
    case keyAmenities       = "Key Amenities"
    case refreshments       = "Refreshments"
    case entertainment      = "Entertainment"
    case furnitureEquipment = "Furniture Equipment"
    case outdoorAreas       = "Outdoor Areas"
    case convenientFeatures = "Convenient Features"
}

enum EventAmenities: String, Codable, CaseIterable {
    case alcohol       = "Alcoholic Drinks"
    case nonAlcohol    = "Non-Alcoholic Drinks"
    case beer          = "Beer"
    case water         = "Water"
    case snacks        = "Snacks"
    case food          = "Food"
    case dj            = "DJ"
    case liveMusic     = "Live Music"
    case danceFloor    = "Dance Floor"
    case karaoke       = "Karaoke"
    case videoGames    = "Video Games"
    case indoorGames   = "Indoor Games"
    case outdoorGames  = "Outdoor Games"
    case drinkingGames = "Drinking Games"
    case seating       = "Seating"
    case soundSystem   = "Sound System"
    case projector     = "Projector"
    case lighting      = "Lighting"
    case outdoorSpace  = "Outdoor Space"
    case pool          = "Pool"
    case hotTub        = "Hot Tub"
    case firePit       = "Fire Pit"
    case grillBBQ      = "Grill/BBQ"
    case rooftop       = "Rooftop"
    case garden        = "Garden"
    case security      = "Security"
    case freeParking   = "Free Parking"
    case paidParking   = "Paid Parking"
    case coatCheck     = "Coat Check"
    case bathrooms     = "Bathrooms"
    case smokingArea   = "Smoking Area"
    
    var category: AmenityCategory {
        switch self {
        case .bathrooms, .beer, .water, .dj, .danceFloor: return .keyAmenities
            case .alcohol, .nonAlcohol, .snacks, .food: return .refreshments
            case .liveMusic, .karaoke, .videoGames,
                 .indoorGames, .outdoorGames, .drinkingGames: return .entertainment
            case .seating, .soundSystem, .projector, .lighting: return .furnitureEquipment
            case .outdoorSpace, .pool, .hotTub, .firePit, .grillBBQ, .rooftop, .garden: return .outdoorAreas
            case .security, .freeParking, .paidParking, .coatCheck, .smokingArea: return .convenientFeatures
        }
    }
    
    var displayIcon: AnyView {
        switch self {
            case .beer: return AnyView(Text("🍺"))
            case .water: return AnyView(Text("💦"))
            case .smokingArea: return AnyView(Text("🚬"))
            case .dj: return AnyView(Text("🎧"))
            case .coatCheck: return AnyView(Text("🧥"))
            case .nonAlcohol: return AnyView(Text("🧃"))
            case .food: return AnyView(Text("🍕"))
            case .danceFloor: return AnyView(Text("🕺"))
            case .snacks: return AnyView(Text("🍪"))
            case .drinkingGames: return AnyView(Text("🏓"))
            default: return AnyView(Image(systemName: self.icon))
        }
    }

    
    var icon: String {
        switch self {
        case .alcohol: return "wineglass.fill"
        case .nonAlcohol: return "cup.and.saucer.fill"
        case .beer: return "mug.fill"
        case .water: return "drop.fill"
        case .snacks: return "carrot.fill"
        case .food: return "fork.knife"
        case .dj: return "music.note.list"
        case .liveMusic: return "music.quarternote.3"
        case .danceFloor: return "figure.socialdance"
        case .karaoke: return "music.mic"
        case .videoGames: return "gamecontroller.fill"
        case .indoorGames: return "figure.cooldown"
        case .outdoorGames: return "figure.basketball"
        case .drinkingGames: return "drop.fill"
        case .seating: return "sofa.fill"
        case .soundSystem: return "hifispeaker.2.fill"
        case .projector: return "videoprojector.fill"
        case .lighting: return "lightbulb.2.fill"
        case .outdoorSpace: return "leaf.fill"
        case .pool: return "figure.pool.swim"
        case .hotTub: return "bathtub.fill"
        case .firePit: return "flame.fill"
        case .grillBBQ: return "cooktop.fill"
        case .rooftop: return "stairs"
        case .garden: return "camera.macro"
        case .security: return "lock.shield"
        case .freeParking, .paidParking: return "parkingsign"
        case .coatCheck: return "tag.fill"
        case .bathrooms: return "toilet.fill"
        case .smokingArea: return "smoke.fill"
        }
    }
}
