//
//  MapClusterView.swift
//  mixer
//
//  Created by Jose Martinez on 12/21/22.
//

import SwiftUI
import MapKit

struct MapClusterView: UIViewRepresentable {


var forDisplay = data
@State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 42.35071, longitude: -71.09097),
                                               span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
)


class Coordinator: NSObject, MKMapViewDelegate {
    
    var parent: MapClusterView

    init(_ parent: MapClusterView) {
        self.parent = parent
    }
    
/// showing annotation on the map
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? LandmarkAnnotation else { return nil }
        return AnnotationView(annotation: annotation, reuseIdentifier: AnnotationView.ReuseID)
    }

}



func makeCoordinator() -> Coordinator {
    MapClusterView.Coordinator(self)
}


func makeUIView(context: Context) -> MKMapView {
    ///  creating a map
    let view = MKMapView()
    /// connecting delegate with the map
    view.delegate = context.coordinator
    view.setRegion(region, animated: false)
    view.mapType = .mutedStandard
    view.pointOfInterestFilter = MKPointOfInterestFilter(including: [.university, .school, .airport, .library, .publicTransport, .restaurant, .restroom])
    
    for points in forDisplay {
        let annotation = LandmarkAnnotation(coordinate: points.coordinate)
        view.addAnnotation(annotation)
    }
    

    return view
    
}

func updateUIView(_ uiView: MKMapView, context: Context) {
    
}
}

struct SampleData: Identifiable {
var id = UUID()
var latitude: Double
var longitude: Double
var coordinate: CLLocationCoordinate2D {
CLLocationCoordinate2D(
    latitude: latitude,
    longitude: longitude)
 }
}

var data = [
SampleData(latitude: 42.350713, longitude: -71.0908864),
SampleData(latitude: 42.3502155, longitude: -71.0861443),
SampleData(latitude: 42.3519622, longitude: -71.0863661),
SampleData(latitude: 42.3506797, longitude: -71.0910707),
SampleData(latitude: 42.3503271, longitude: -71.0973859),
SampleData(latitude: 42.3507046, longitude: -71.0909822),
SampleData(latitude: 42.356121, longitude: -71.0973739),
SampleData(latitude: 42.3485221862793, longitude: -71.12267303466797)

]


class LandmarkAnnotation: NSObject, MKAnnotation {
let coordinate: CLLocationCoordinate2D
init(
     coordinate: CLLocationCoordinate2D
) {
    self.coordinate = coordinate
    super.init()
}
}


/// here posible to customize annotation view
let clusterID = "clustering"

class AnnotationView: MKMarkerAnnotationView {

static let ReuseID = "cultureAnnotation"

/// setting the key for clustering annotations
override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    clusteringIdentifier = clusterID
}


required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
}

override func prepareForDisplay() {
    super.prepareForDisplay()
    displayPriority = .defaultLow
 }
}
