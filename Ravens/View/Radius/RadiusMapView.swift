//
//  RadiusMapView.swift
//  Ravens
//
//  Created by Eric de Quartel on 02/04/2025.
//
import SwiftUI
import Foundation
import Alamofire
import Combine
import SwiftyBeaver
import MapKit

struct RadiusMapView: View {
  let log = SwiftyBeaver.self
  @ObservedObject var observationsRadiusViewModel: ObservationsRadiusViewModel

  @EnvironmentObject var settings: Settings
  @EnvironmentObject var locationManager: LocationManagerModel

  @Binding var currentSortingOption: SortingOption?
  @Binding var currentFilteringAllOption: FilterAllOption?
  @Binding var currentFilteringOption: FilteringRarityOption?
  @Binding var timePeriod: TimePeriod?
  @Binding var region: MKCoordinateRegion
  @Binding var cameraPosition: MapCameraPosition

  var body: some View {
    MapReader { proxy in
      Map(position: $cameraPosition) {
        UserAnnotation()

        // observations
        let obs = observationsRadiusViewModel.observations ?? []
        let filteredObs = obs.filter {
          $0.rarity == currentFilteringOption?.intValue ?? 0  || currentFilteringOption?.intValue ?? 0 == 0
        }
        ForEach(filteredObs) { observation in
          Annotation(observation.speciesDetail.name, coordinate: CLLocationCoordinate2D(
            latitude: observation.point.coordinates[1],
            longitude: observation.point.coordinates[0])) {
              ObservationAnnotationView(observation: observation)
            }
        }

        MapCircle(
          center: CLLocationCoordinate2D(
            latitude: observationsRadiusViewModel.circleCenter.latitude,
            longitude: observationsRadiusViewModel.circleCenter.longitude),
          radius: Double(settings.radius))
        .foregroundStyle(.blue.opacity(0.2)) // Fill the circle with blue color
        .stroke(.blue.opacity(0.7), lineWidth: 1) // Add a border

      }
      .mapStyle(settings.mapStyle)
      .mapControls {
        MapUserLocationButton()
        MapPitchToggle()
        MapCompass() // tapping this makes it north
      }

      .onTapGesture() { position in
        observationsRadiusViewModel.observations = []

        if let coordinate = proxy.convert(position, from: .local) {
          observationsRadiusViewModel.circleCenter = coordinate

          observationsRadiusViewModel.fetchDataInit(
            settings: settings,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            radius: settings.radius,
            timePeriod: settings.timePeriodRadius,
            completion: {
              log.error("tapgesture update userlocation")
              updateRegionToUserLocation(coordinate: coordinate)
            })
        }
      }
    }
    .onAppear {
      log.error("radiusMapView onAppear")
      updateRegionToUserLocation(coordinate: observationsRadiusViewModel.circleCenter)
    }
  }

  private var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "EE dd-MM"
    return formatter
  }

  private func updateRegionToUserLocation(coordinate: CLLocationCoordinate2D) {

    log.error("User location IS available")
    // Define area span (latitudeDelta and longitudeDelta)
    let updatedRegion = MKCoordinateRegion(
      center: coordinate,
      span: MKCoordinateSpan(
        latitudeDelta: Double(settings.radius) / 20000,
        longitudeDelta: Double(settings.radius) / 20000)
    )

    region = updatedRegion
    cameraPosition = .region(updatedRegion) // Update camera to this region
  }
}
