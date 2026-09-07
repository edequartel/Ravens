//
//  PosOnMapView.swift
//  Ravens
//
//  Created by Eric de Quartel on 09/09/2024.
//
import Foundation
import SwiftUI
import MapKit

struct PositionOnMapView: View {
  var obs: Obs
  var allowsHitTesting: Bool = false // so the map is not moving

  @EnvironmentObject var settings: Settings
  @State private var cameraPosition: MapCameraPosition = .automatic
  @State private var region: MKCoordinateRegion = MKCoordinateRegion(
    center: CLLocationCoordinate2D(latitude: 52.0, longitude: 5.0),
    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
  )

  var body: some View {
    Map(position: $cameraPosition) {
      UserAnnotation()
      Annotation(obs.speciesDetail.name, coordinate: CLLocationCoordinate2D(latitude: obs.point.coordinates[1], longitude: obs.point.coordinates[0])) {
        Circle()
          .fill(rarityColor(value: obs.rarity))
          .stroke(obs.hasSound ?? false ? Color.white : Color.clear, lineWidth: 1)
          .frame(width: 12, height: 12)

          .overlay(
            Circle()
              .fill(obs.hasPhoto ?? false ? Color.white : Color.clear)
              .frame(width: 6, height: 6)
          )
      }
    }
    .mapStyle(settings.mapStyle)
    .mapControls {
      MapCompass() // tapping this makes it north
    }
    .onMapCameraChange { context in
      region = context.region
    }
    .overlay(alignment: .topTrailing) {
      MapControlButtons(cameraPosition: $cameraPosition, region: $region)
    }

    .onAppear {
      region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: obs.point.coordinates[1], longitude: obs.point.coordinates[0]),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
      )
      cameraPosition = .region(region)
    }
    .allowsHitTesting(allowsHitTesting)
  }
}

struct PositionLatitideLongitudeOnMapView: View {
  let latitude: Double
  let longitude: Double

  @EnvironmentObject var settings: Settings
  @State private var cameraPosition: MapCameraPosition = .automatic
  @State private var region: MKCoordinateRegion = MKCoordinateRegion(
    center: CLLocationCoordinate2D(latitude: 52.0, longitude: 5.0),
    span: MKCoordinateSpan(latitudeDelta: 1.3, longitudeDelta: 1.3)
  )

  var body: some View {
    Map(position: $cameraPosition) {
      Annotation("", coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)) {
        Circle()
          .fill(.red)
          .frame(width: 12, height: 12)

      }
    }
    .mapStyle(settings.mapStyle)
    .mapControls {
      MapCompass() // tapping this makes it north
    }
    .onMapCameraChange { context in
      region = context.region
    }
    .overlay(alignment: .topTrailing) {
      MapControlButtons(cameraPosition: $cameraPosition, region: $region)
    }
    .onAppear {
      region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
        span: MKCoordinateSpan(latitudeDelta: 1.3, longitudeDelta: 1.3)
      )
      cameraPosition = .region(region)
    }
    .allowsHitTesting(false)
  }
}
