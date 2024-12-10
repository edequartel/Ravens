//
//  MapObservationsUserView.swift
//  Ravens
//
//  Created by Eric de Quartel on 04/03/2024.
//

import SwiftUI
import MapKit
import SwiftyBeaver

struct MapObservationsUserView: View {
  let log = SwiftyBeaver.self
  @ObservedObject var observationUser : ObservationsViewModel

  @EnvironmentObject var locationManager: LocationManagerModel
  @EnvironmentObject var settings: Settings //for the mapStyle

  @State private var cameraPosition: MapCameraPosition = .automatic
  @State private var region: MKCoordinateRegion = MKCoordinateRegion(
    center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
    span: MKCoordinateSpan(latitudeDelta: 0.045, longitudeDelta: 0.045) // Default span
  )

  var body: some View {
    ZStack(alignment: .topLeading) {
      Map(position: $cameraPosition) {
        UserAnnotation()
        ForEach(observationUser.observations ?? []) { observation in
          Annotation(observation.speciesDetail.name,
                     coordinate:  CLLocationCoordinate2D(
                      latitude: observation.point.coordinates[1],
                      longitude: observation.point.coordinates[0]))
          {
            ObservationAnnotationView(observation: observation)
          }
        }
      }
      .mapStyle(settings.mapStyle)
      .mapControls() {
        MapUserLocationButton()
        MapPitchToggle()
        MapCompass() //tapping this makes it north
      }
    }
    .onAppear {
      updateRegionToUserLocation() //just around the userlocation
    }
  }

  private func updateRegionToUserLocation() {
    guard let userLocation = locationManager.getCurrentLocation() else {
      log.warning("User location not available")
      return
    }

    // Define area span (latitudeDelta and longitudeDelta)
    let kilometersToDegrees = 255.0 / 111.0
    let updatedRegion = MKCoordinateRegion(
      center: userLocation.coordinate,
      span: MKCoordinateSpan(latitudeDelta: kilometersToDegrees, longitudeDelta: kilometersToDegrees)
    )

    region = updatedRegion
    cameraPosition = .region(updatedRegion) // Update camera to this region
  }
}



import SwiftUI
import MapKit

struct ObservationAnnotationView: View {
  let observation: Observation

  var body: some View {
    Circle()
      .fill(rarityColor(value: observation.rarity))
      .stroke(!(observation.sounds?.isEmpty ?? false) ? Color.white : Color.clear, lineWidth: 1)
      .frame(width: 12, height: 12)
      .overlay(
        Circle()
          .fill(!(observation.photos?.isEmpty ?? false) ? Color.white : Color.clear)
          .frame(width: 6, height: 6)
      )
      .onTapGesture {
        print("Tapped observation \(observation.speciesDetail.name)")
      }
  }
}

