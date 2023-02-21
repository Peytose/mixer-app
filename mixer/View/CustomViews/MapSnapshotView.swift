//
//  MapSnapshotView.swift
//  mixer
//
//  Created by Jose Martinez on 12/21/22.
//

import SwiftUI
import MapKit

struct MapSnapshotView: View {
    let location: CLLocationCoordinate2D
    var span: CLLocationDegrees = 0.001
    var delay: CGFloat = 0.3
    var width: CGFloat = 350
    var height: CGFloat = 220
    @State private var snapshotImage: UIImage? = nil
    
    var body: some View {
        Group {
            if let image = snapshotImage {
                Image(uiImage: image)
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .background(Color(UIColor.secondarySystemBackground))
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                generateSnapshot(width: width, height: height)
            }
        }
    }
    
    func generateSnapshot(width: CGFloat, height: CGFloat) {
        let region = MKCoordinateRegion(
            center: self.location,
            span: MKCoordinateSpan(
                latitudeDelta: self.span,
                longitudeDelta: self.span
            )
        )
        
        let mapOptions = MKMapSnapshotter.Options()
        mapOptions.region = region
        mapOptions.size = CGSize(width: width, height: height)
        mapOptions.showsBuildings = true
        mapOptions.traitCollection = UITraitCollection(userInterfaceStyle: .dark)
        
        let snapshotter = MKMapSnapshotter(options: mapOptions)
        snapshotter.start { (snapshotOrNil, errorOrNil) in
            if let error = errorOrNil {
                print(error)
                return
            }
            if let snapshot = snapshotOrNil {
                self.snapshotImage = snapshot.image
            }
        }
    }
}

struct testView: View {
    let coordinates = CLLocationCoordinate2D(latitude: 37.332077, longitude: -122.02962) // Apple Park, California
    var body: some View {
        VStack {
            MapSnapshotView(location: coordinates)
        }
    }
}

struct testView_Previews: PreviewProvider {
    static var previews: some View {
        testView()
    }
}
