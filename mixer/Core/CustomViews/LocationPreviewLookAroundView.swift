//
//  LocationPreviewLookAroundView.swift
//  mixer
//
//  Created by Peyton Lyons on 12/7/23.
//

import SwiftUI
import MapKit

@available(iOS 17.0, *)
struct LocationPreviewLookAroundView: View {
    @State private var lookAroundScene: MKLookAroundScene?
    var selectedItem: MixerMapItem
    
    var body: some View {
        LookAroundPreview(initialScene: lookAroundScene)
            .overlay(alignment: .bottomTrailing) {
                HStack {
                    Text("\(selectedItem.title)")
                }
                .font(.caption)
                .foregroundColor(.white)
                .padding(18)
            }
            .onAppear {
                getLookAroundScene()
            }
            .onChange(of: selectedItem) {
                getLookAroundScene()
            }
    }
    
    func getLookAroundScene() {
        lookAroundScene = nil
        Task {
            let request = MKLookAroundSceneRequest(coordinate: selectedItem.coordinate)
            lookAroundScene = try? await request.scene
        }
    }
}
