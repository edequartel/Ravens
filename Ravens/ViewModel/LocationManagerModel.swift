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

  override init() {
    super.init()
    log.info("Init - LocationManagerModel init")
    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    self.locationManager.requestWhenInUseAuthorization()
    self.locationManager.startUpdatingLocation()
    self.locationManager.startUpdatingHeading()
  }

  //?
  func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    self.heading = newHeading
  }
  
  //?
  func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
    return true
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

  func checkLocation() -> Bool {
    if let _ = self.errorMessage {
      log.error("Location error.")
      return false
    } else if let location = self.location {
      log.info("Location is available.")
      log.info("Location accuracy: \(location.horizontalAccuracy) meters")
      let accuracyThreshold = 100.0 // Define your own accuracy threshold
      return location.horizontalAccuracy < accuracyThreshold
    } else {
      log.error("Location is not available.")
      return false
    }
  }
}

