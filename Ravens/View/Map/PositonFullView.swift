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
  var obs: Observation
  @EnvironmentObject var settings: Settings

  @State private var cameraPosition: MapCameraPosition = .automatic

  var body: some View {
    Map(position: $cameraPosition) {
      Annotation(obs.speciesDetail.name, coordinate: CLLocationCoordinate2D(latitude: obs.point.coordinates[1], longitude: obs.point.coordinates[0])) {
        Circle()
          .fill(rarityColor(value: obs.rarity))
          .stroke(obs.hasSound ?? false ? Color.white : Color.clear,lineWidth: 1)
          .frame(width: 12, height: 12)

          .overlay(
            Circle()
              .fill(obs.hasPhoto ?? false ? Color.white : Color.clear)
              .frame(width: 6, height: 6)
          )
      }
    }
    .mapStyle(settings.mapStyle)
    .mapControls() {
      MapUserLocationButton()
      MapPitchToggle()
      MapCompass() //tapping this makes it north
    }

    .onAppear() {
      cameraPosition = .camera(
        MapCamera(centerCoordinate: CLLocationCoordinate2D(latitude: obs.point.coordinates[1], longitude: obs.point.coordinates[0]), distance: 1000)
      )
    }
  }
}

