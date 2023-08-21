//
//  MapSnapshotView.swift
//  mixer
//
//  Created by Jose Martinez on 12/21/22.
//

import SwiftUI
import MapKit

struct MapSnapshotView<CoordinateItem: CoordinateRepresentable>: View {
    @Binding var location: CoordinateItem?
    var regionSpan: CLLocationDegrees = 0.001
    var loadingDelay: CGFloat = 0.3
    var snapshotWidth: CGFloat = 350
    var snapshotHeight: CGFloat = 220
    
    @State private var mapPreviewImage: Image?
    
    var body: some View {
        ZStack {
            if let image = mapPreviewImage {
                ZStack(alignment: .center) {
                    image
                    
                    Image(systemName: "pin.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
                        .shadow(radius: 10)
                        .frame(width: 16)
                }
                .cornerRadius(16)
            } 
        }
        .onChange(of: location) { newValue in
            // Regenerate the snapshot when coordinates change
            if let coordinate = newValue?.coordinate {
                generateSnapshot(coordinate: coordinate, width: snapshotWidth, height: snapshotHeight)
            }
        }
        .onAppear {
            if let coordinate = location?.coordinate {
                print("DEBUG: genering snapshot ...")
                generateSnapshot(coordinate: coordinate, width: snapshotWidth, height: snapshotHeight)
            } else {
                print("DEBUG: did not generate snapshot ...")
            }
        }
    }
}

extension MapSnapshotView {
    private func generateSnapshot(coordinate: CLLocationCoordinate2D, width: CGFloat, height: CGFloat) {
        let region = MKCoordinateRegion(center: coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: regionSpan,
                                                               longitudeDelta: regionSpan))

        let snapshotOptions = MKMapSnapshotter.Options()
        snapshotOptions.region = region
        snapshotOptions.size = CGSize(width: width, height: height)
        snapshotOptions.showsBuildings = true
        snapshotOptions.traitCollection = UITraitCollection(userInterfaceStyle: .dark)

        let bgQueue = DispatchQueue.global(qos: .background)
        let snapshotter = MKMapSnapshotter(options: snapshotOptions)
        snapshotter.start(with: bgQueue) { snapshot, error in
            if let error = error {
                print("Error generating snapshot: \(error.localizedDescription)")
                return
            }

            guard let snapshot = snapshot else { return }
            mapPreviewImage = Image(uiImage: snapshot.image)
        }
    }
}
