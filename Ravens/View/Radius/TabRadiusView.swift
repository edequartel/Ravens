//
//  RadiusView.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/05/2024.
//

import SwiftUI
import Foundation
import Alamofire
import Combine
import SwiftyBeaver
import MapKit

struct TabRadiusView: View {
  let log = SwiftyBeaver.self
  @ObservedObject var observationsRadiusViewModel: ObservationsRadiusViewModel
  
  @EnvironmentObject var locationManager: LocationManagerModel
  @EnvironmentObject var accessibilityManager: AccessibilityManager
  @EnvironmentObject private var settings: Settings

  @Binding var selectedSpeciesID: Int?

  @State private var showFirstView = false
  @State private var currentSortingOption: SortingOption? = .date
  @State private var currentFilteringAllOption: FilterAllOption? = .native
  @State private var currentFilteringOption: FilteringRarityOption? = .all

  @State private var region: MKCoordinateRegion = MKCoordinateRegion(
    center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
    span: MKCoordinateSpan(latitudeDelta: 0.045, longitudeDelta: 0.045) // Default span
  )

  @State private var cameraPosition: MapCameraPosition = .automatic

  var body: some View {
    NavigationStack {
      VStack {
        if showView { Text("TabRadiusView").font(.customTiny) }

        if showFirstView && !accessibilityManager.isVoiceOverEnabled {
          RadiusMapView(observationsRadiusViewModel: observationsRadiusViewModel,
                        currentSortingOption: $currentSortingOption,
                        currentFilteringAllOption: $currentFilteringAllOption,
                        currentFilteringOption: $currentFilteringOption,
                        timePeriod: $settings.timePeriodRadius,
                        region: $region,
                        cameraPosition: $cameraPosition)
        } else {
          RadiusListView(observationsRadiusViewModel: observationsRadiusViewModel,
                         selectedSpeciesID: $selectedSpeciesID,
                         currentSortingOption: $currentSortingOption,
                         currentFilteringAllOption: $currentFilteringAllOption,
                         currentFilteringOption: $currentFilteringOption,
                         timePeriod: $settings.timePeriodRadius,
                         region: $region,
                         cameraPosition: $cameraPosition
          )
        }
      }

      .modifier(
        ObservationToolbarModifier(
          currentFilteringOption: $currentFilteringOption,
          timePeriod: $settings.timePeriodRadius,
          entity: .radius)
      )

      .onChange(of: settings.radius) {
        log.error("update radius \(String(describing: settings.radius))")
        observationsRadiusViewModel.observations = []
        observationsRadiusViewModel.fetchDataInit(
          settings: settings,

          latitude: observationsRadiusViewModel.circleCenter.latitude,
          longitude: observationsRadiusViewModel.circleCenter.longitude,

          radius: settings.radius,
          timePeriod: settings.timePeriodRadius,
          completion: {
            log.error("update radius")
          })
      }

      .onChange(of: settings.selectedLanguage) {
        log.error("update selectedLanguage \(String(describing: settings.selectedLanguage))")
        observationsRadiusViewModel.observations = []
        observationsRadiusViewModel.fetchDataInit(
          settings: settings,

          latitude: observationsRadiusViewModel.circleCenter.latitude,
          longitude: observationsRadiusViewModel.circleCenter.longitude,

          radius: settings.radius,
          timePeriod: settings.timePeriodRadius,
          completion: {
            log.error("update timePeriod")
          })
      }

      .onChange(of: settings.timePeriodRadius) {
        log.error("update timePeriod \(String(describing: settings.timePeriodRadius))")
        observationsRadiusViewModel.observations = []
        observationsRadiusViewModel.fetchDataInit(
          settings: settings,

          latitude: observationsRadiusViewModel.circleCenter.latitude,
          longitude: observationsRadiusViewModel.circleCenter.longitude,

          radius: settings.radius,
          timePeriod: settings.timePeriodRadius, 
          completion: {
            log.error("update timePeriod count: \(observationsRadiusViewModel.count)")
          })
      }

      .toolbar {
        // map or list
        if !accessibilityManager.isVoiceOverEnabled {
          ToolbarItem(placement: .navigationBarLeading) {
            Button(action: {
              showFirstView.toggle()
            }) {
              Image(systemName: "rectangle.2.swap")
                .uniformSize()
                .accessibilityLabel(toggleViewMapList)
            }
          }
        }

        ToolbarItem(placement: .navigationBarLeading) {
          Button(action: {
            observationsRadiusViewModel.observations = []

            if let location = locationManager.getCurrentLocation() {
              observationsRadiusViewModel.circleCenter = location.coordinate

              observationsRadiusViewModel.fetchDataInit(
                settings: settings,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                radius: settings.radius,
                timePeriod: settings.timePeriodRadius,
                completion: {
                  log.error("tapgesture update userlocation")
                  updateRegionToUserLocation(coordinate: location.coordinate)
                })
            }


          }) {
            Image(systemName: "smallcircle.filled.circle")
              .uniformSize()
              .accessibilityLabel(updateLocation)
          }
        }
      }
    }
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
