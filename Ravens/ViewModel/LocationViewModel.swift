//
//  LocationViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 14/05/2024.
//

import Foundation
import MapKit

class LocationViewModel: ObservableObject {
    @Published var location: CLLocationCoordinate2D?
//    @Published var cameraPosition: MapCameraPosition?
}
