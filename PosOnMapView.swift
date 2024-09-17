//
//  PosOnMapView.swift
//  Ravens
//
//  Created by Eric de Quartel on 09/09/2024.
//

import Foundation
import SwiftUI
import MapKit

// Helper struct for annotations
struct LocationXX: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
}

struct PositionOnMapView: View {
    var latitude: Double
    var longitude: Double

    @State private var region: MKCoordinateRegion

    init(lat: Double, long: Double) {
        self.latitude = lat
        self.longitude = long
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: lat, longitude: long),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }


    var body: some View {
        Map(coordinateRegion: $region, annotationItems: [LocationXX(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))]) { location in
            MapMarker(coordinate: location.coordinate)
        }
    }
}

