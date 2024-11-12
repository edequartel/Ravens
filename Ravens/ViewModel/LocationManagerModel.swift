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

  @Published var heading: CLHeading? = nil

  private var locationCompletion: ((CLLocation) -> Void)? = nil

  override init() {
    super.init()
    log.info("Init - LocationManagerModel init")
    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    self.locationManager.requestWhenInUseAuthorization()
    self.locationManager.startUpdatingLocation()
    self.locationManager.startUpdatingHeading()
  }

  func getCurrentLocation() -> CLLocation? {
    return locationManager.location
  }

}


