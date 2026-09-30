//
//  PositonFullView.swift
//  Ravens
//
//  Created by Eric de Quartel on 27/11/2024.
//

import Foundation
import SwiftUI
import MapKit

struct PositonFullView: View {
  var obs: Obs
  var entity: EntityType = .species
  @EnvironmentObject var settings: Settings

  @State private var cameraPosition: MapCameraPosition = .automatic
  @State private var region: MKCoordinateRegion = MKCoordinateRegion(
    center: CLLocationCoordinate2D(latitude: 52.0, longitude: 5.0),
    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
  )

  var body: some View {
    Map(position: $cameraPosition) {
      Annotation(obs.speciesDetail.name, coordinate: CLLocationCoordinate2D(latitude: obs.point.coordinates[1], longitude: obs.point.coordinates[0])) {
        ObservationAnnotationView(observation: obs, entity: entity, opensDetail: false)
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
  }
}
