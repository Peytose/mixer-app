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
    var delay: CGFloat          = 0.3
    var width: CGFloat          = 350
    var height: CGFloat         = 220
    var isInvited: Bool         = false
    @State private var mapPreviewImageView: Image?
    
    var body: some View {
        Group {
            if let previewImage = mapPreviewImageView {
                ZStack(alignment: .center) {
                    previewImage
                        .blur(radius: isInvited ? 0 : 6)
                    
                    Image(systemName: isInvited ? "mappin.and.ellipse" : "exclamationmark.lock.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.mixerIndigo)
                        .shadow(radius: 7)
                        .frame(width: isInvited ? 20 : 40)
                }
            } else {
                LoadingView()
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
        
        let bgQueue = DispatchQueue.global(qos: .background)
        let snapshotter = MKMapSnapshotter(options: mapOptions)
        snapshotter.start(with: bgQueue, completionHandler: { snapshot, error in
            if let error = error {
                print("DEBUG: Error generating snapshot. \(error.localizedDescription)")
                return
            }
            
            guard let snapshot = snapshot else { return }
            self.mapPreviewImageView = Image(uiImage: snapshot.image)
        })
    }
}

struct testView: View {
    let coordinates = CLLocationCoordinate2D(latitude: 37.332077, longitude: -122.02962) // Apple Park, California
    
    var body: some View {
        VStack { MapSnapshotView(location: coordinates) }
    }
}

struct testView_Previews: PreviewProvider {
    static var previews: some View {
        testView()
    }
}
