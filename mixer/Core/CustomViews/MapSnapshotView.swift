//
//  MapSnapshotView.swift
//  mixer
//
//  Created by Jose Martinez on 12/21/22.
//

import SwiftUI
import MapKit

struct MapSnapshotView: View {
    let locationCoordinates: CLLocationCoordinate2D
    var regionSpan: CLLocationDegrees = 0.001
    var loadingDelay: CGFloat = 0.3
    var snapshotWidth: CGFloat = 350
    var snapshotHeight: CGFloat = 220

    @State private var mapPreviewImage: Image?

    var body: some View {
        Group {
            if let image = mapPreviewImage {
                ZStack(alignment: .center) {
                    image

                    Image(systemName: "mappin")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color.theme.mixerIndigo)
                        .shadow(radius: 10)
                        .frame(width: 16)
                }
                .cornerRadius(16)
            } else {
                LoadingView()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + loadingDelay) {
                generateSnapshot(width: snapshotWidth, height: snapshotHeight)
            }
        }
    }

    
    private func generateSnapshot(width: CGFloat, height: CGFloat) {
        let region = MKCoordinateRegion(
            center: locationCoordinates,
            span: MKCoordinateSpan(latitudeDelta: regionSpan, longitudeDelta: regionSpan)
        )

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

struct MapSnapshotPreview: View {
    let coordinates = CLLocationCoordinate2D(latitude: 37.332077, longitude: -122.02962) // Apple Park, California

    var body: some View {
        VStack { MapSnapshotView(locationCoordinates: coordinates) }
    }
}

struct MapSnapshotPreview_Previews: PreviewProvider {
    static var previews: some View {
        MapSnapshotPreview()
    }
}

