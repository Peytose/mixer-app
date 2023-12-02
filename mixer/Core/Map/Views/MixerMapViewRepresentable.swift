//
//  MixerMapViewRepresentable.swift
//  mixer
//
//  Created by Peyton Lyons on 7/30/23.
//

import SwiftUI
import MapKit
import Kingfisher

//struct MixerMapViewRepresentable: UIViewRepresentable {
//    let mapView = MKMapView()
//    @Binding var mapState: MapViewState
//    @EnvironmentObject var mapViewModel: MapViewModel
//
//    func makeUIView(context: Context) -> some UIView {
//        mapView.delegate          = context.coordinator
//        mapView.isRotateEnabled   = false
//        mapView.showsUserLocation = true
//        mapView.userTrackingMode  = .follow
//        
//        return mapView
//    }
//    
//    
//    func updateUIView(_ uiView: UIViewType, context: Context) {
//        switch mapState {
//            case .noInput:
//                context.coordinator.clearMapViewAndRecenterOnUserLocation()
//                context.coordinator.addAnnotationsToMap(Array(mapViewModel.mapItems))
//                break
//            case .routeEventPreview, .routeHostPreview:
//                if let coordinate = mapViewModel.selectedMixerMapItem?.coordinate {
//                    context.coordinator.addAndSelectAnnotation(withCoordinate: coordinate)
//                    context.coordinator.configurePolyline(withDestinationCoordinate: coordinate)
//                }
//                break
//            default:
//                break
//        }
//    }
//    
//    
//    func makeCoordinator() -> MapCoordinator {
//        return MapCoordinator(parent: self)
//    }
//}
//
//extension MixerMapViewRepresentable {
//    class MapCoordinator: NSObject, MKMapViewDelegate {
//        // MARK: - Properties
//        var isInitialMapRegionSet = false
//        let parent: MixerMapViewRepresentable
//        var userLocationCoordinate: CLLocationCoordinate2D?
//        var currentRegion: MKCoordinateRegion?
//        
//        // MARK: - Lifecycle
//        init(parent: MixerMapViewRepresentable) {
//            self.parent = parent
//            super.init()
//        }
//        
//        // MARK: - MKMapViewDelegate
//        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//            self.userLocationCoordinate = userLocation.coordinate
//            let region = MKCoordinateRegion(
//                center: CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude,
//                                               longitude: userLocation.coordinate.longitude),
//                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//            )
//            
//            self.currentRegion = region
//            if !isInitialMapRegionSet {
//                parent.mapView.setRegion(region, animated: true)
//                isInitialMapRegionSet = true
//            }
//        }
//        
//        
//        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//            let polyline = MKPolylineRenderer(overlay: overlay)
//            polyline.strokeColor = UIColor(Color.theme.mixerIndigo)
//            polyline.lineWidth = 6
//            return polyline
//        }
//        
//        
//        @MainActor
//        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//            if let annotation = annotation as? MixerMapAnnotation {
//                let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotation.reuseIdentifier)
//                guard let imageUrl = annotation.imageUrl else { return view }
//                
//                Task {
//                    self.downloadImage(with: imageUrl) { image in
//                        view.image = image.resizeImage(toWidth: 40)?.roundImage()
//                    }
//                }
//                return view
//            }
//            return nil
//        }
//        
//        
//        // MARK: - Helpers
//        func downloadImage(with urlString : String, completion: @escaping(UIImage) -> Void) {
//            guard let url = URL.init(string: urlString) else { return }
//            let resource = KF.ImageResource(downloadURL: url)
//
//            KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { result in
//                switch result {
//                case .success(let value):
//                    completion(value.image)
//                case .failure(let error):
//                    print("DEBUG: Error downloading image from url \(error.localizedDescription)")
//                }
//            }
//        }
//        
//        
//        func configurePolylineToPickupLocation(withRoute route: MKRoute) {
//            self.parent.mapView.addOverlay(route.polyline)
//            let rect = self.parent.mapView.mapRectThatFits(route.polyline.boundingMapRect,
//                                                           edgePadding: .init(top: 88, left: 32, bottom: 400, right: 32))
//            
//            self.parent.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
//        }
//        
//        
//        func addAndSelectAnnotation(withCoordinate coordinate: CLLocationCoordinate2D) {
//            parent.mapView.removeAnnotations(parent.mapView.annotations)
//            
//            let anno = MKPointAnnotation()
//            anno.coordinate = coordinate
//            self.parent.mapView.addAnnotation(anno)
//            self.parent.mapView.selectAnnotation(anno, animated: true)
//        }
//        
//        
//        func configurePolyline(withDestinationCoordinate coordinate: CLLocationCoordinate2D) {
//            guard let userLocationCoordinate = self.userLocationCoordinate else { return }
//            parent.mapViewModel.getDestinationRoute(from: userLocationCoordinate, to: coordinate) { route in
//                self.parent.mapView.addOverlay(route.polyline)
//                self.parent.mapState = .polylineAdded
//                let rect = self.parent.mapView.mapRectThatFits(route.polyline.boundingMapRect,
//                                                               edgePadding: .init(top: 64, left: 32, bottom: 500, right: 32))
//                
//                self.parent.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
//                self.parent.mapViewModel.showLocationDetailsCard = true
//            }
//        }
//        
//        
//        func clearMapViewAndRecenterOnUserLocation() {
//            parent.mapView.removeAnnotations(parent.mapView.annotations)
//            parent.mapView.removeOverlays(parent.mapView.overlays)
//            
//            if let currentRegion = currentRegion {
//                parent.mapView.setRegion(currentRegion, animated: true)
//            }
//        }
//        
//        
//        func addAnnotationsToMap(_ locations: [MixerMapItem]) {
//            let annotations = locations.map({ MixerMapAnnotation(location: $0.self) })
//            self.parent.mapView.addAnnotations(annotations)
//        }
//    }
//}
