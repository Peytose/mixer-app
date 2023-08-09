//
//  HapticManager.swift
//  mixer
//
//  Created by Peyton Lyons on 4/27/23.
//

import UIKit

struct HapticManager {
    static func playSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    static func playLightImpact() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
}
