//
//  LocationManager.swift
//  mixer
//
//  Created by Peyton Lyons on 7/30/23.
//

import CoreLocation

class LocationManager: NSObject, ObservableObject {
    @Published var locations: [MixerMapItem] = []
    var selectedLocation: MixerMapItem?
}
