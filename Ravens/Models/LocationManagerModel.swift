//
//  LocationManagerModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 24/05/2024.
//

import SwiftUI
import CoreLocation
import SwiftyBeaver

class LocationManagerModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    let log = SwiftyBeaver.self
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation? = nil
    @Published var errorMessage: String? = nil

    override init() {
        super.init()
        log.info("Init - LocationManagerModel init")
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else { return }
        self.location = latestLocation
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.errorMessage = error.localizedDescription
    }

    func getCurrentLocation() -> CLLocation? {
        return self.location
    }
}

