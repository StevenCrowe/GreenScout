//
//  MapView.swift
//  GreenScout
//
//  UIKit-based map view for iOS 15 compatibility
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    let coordinate: CLLocationCoordinate2D
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.mapType = .standard
        mapView.isUserInteractionEnabled = false // Make it non-interactive for display
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Set the region
        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        mapView.setRegion(region, animated: false)
        
        // Remove existing annotations
        mapView.removeAnnotations(mapView.annotations)
        
        // Add a pin annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Photo Location"
        mapView.addAnnotation(annotation)
    }
}

// Preview
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194))
            .frame(height: 200)
    }
}
