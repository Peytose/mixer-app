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
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let annotation = annotation as? LandmarkAnnotation,
                  let myData = data.filter({$0.coordinate == annotation.coordinate}).first
            else { return nil }
            mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: CustomAnnotationView.ReuseID)
            let customAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: CustomAnnotationView.ReuseID, for: annotation) as! CustomAnnotationView
            customAnnotationView.configure(with: myData)
            return customAnnotationView
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
var background: String
var coordinate: CLLocationCoordinate2D {
CLLocationCoordinate2D(
    latitude: latitude,
    longitude: longitude)
 }
}

var data = [
    SampleData(latitude: 42.350713, longitude: -71.0908864, background: "profile-banner-2"),
SampleData(latitude: 42.3502155, longitude: -71.0861443, background: "profile-banner-3"),
SampleData(latitude: 42.3519622, longitude: -71.0863661, background: "profile-banner-4"),
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



class CustomAnnotationView: MKAnnotationView {
    static let ReuseID = "cultureAnnotation"

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with data: SampleData) {
        let image = Image(data.background)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 35, height: 35)
            .clipShape(Circle())
            .padding(2)
            .background(Color.mainFont)
            .clipShape(Circle())
            
        let hostingController = UIHostingController(rootView: image)
        addSubview(hostingController.view)
        hostingController.view.frame = bounds
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
