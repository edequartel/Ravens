//
//  LocationView.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/05/2024.
//

import SwiftUI
import SwiftyBeaver
import MapKit
import SFSafeSymbols
import CoreLocation

// Add Equatable conformance for CLLocationCoordinate2D
extension CLLocationCoordinate2D: @retroactive Equatable {
  public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
  }
}

struct TabLocationView: View {
  let log = SwiftyBeaver.self
  @ObservedObject var observationsLocation: ObservationsViewModel

  @StateObject var locationIdViewModel = LocationIdViewModel()
  @StateObject var geoJSONViewModel = GeoJSONViewModel()

  @EnvironmentObject private var settings: Settings
  @EnvironmentObject private var areasViewModel: AreasViewModel
  @EnvironmentObject var locationManager: LocationManagerModel

  @EnvironmentObject var accessibilityManager: AccessibilityManager
  @EnvironmentObject var userViewModel: UserViewModel

  @Binding var selectedSpeciesID: Int?

  @State private var searchText: String = ""
  @State private var showFirstView = false
  @State private var isShowingLocationList = false

  @State private var currentSortingOption: SortingOption? = .date
  @State private var currentFilteringAllOption: FilterAllOption? = .native
  @State private var currentFilteringOption: FilteringRarityOption? = .all

  @State private var setLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
  @State private var setRefresh: Bool = false

  @EnvironmentObject var locationManagerModel: LocationManagerModel
  @EnvironmentObject var keyChainviewModel: KeychainViewModel

  var body: some View {
    NavigationStack {
      VStack {
        if showView { Text("TabLocationView").font(.customTiny) }
        if showFirstView && !accessibilityManager.isVoiceOverEnabled {
          MapObservationsLocationView(
            observationsLocation: observationsLocation,
            locationIdViewModel: locationIdViewModel,
            geoJSONViewModel: geoJSONViewModel,
            setLocation: $setLocation,
            currentFilteringAllOption: $currentFilteringAllOption,
            currentFilteringOption: $currentFilteringOption,
            timePeriod: $settings.timePeriodLocation)
        } else {
          ObservationsLocationView(
            observationsLocation: observationsLocation,
            locationIdViewModel: locationIdViewModel,
            geoJSONViewModel: geoJSONViewModel,
            selectedSpeciesID: $selectedSpeciesID,

            currentSortingOption: $currentSortingOption,
            currentFilteringAllOption: $currentFilteringAllOption,
            currentFilteringOption: $currentFilteringOption,
            setLocation: $setLocation,

            setRefresh: $setRefresh
          )
        }
      }

      .onChange(of: settings.selectedLocationSpeciesGroup) {
        log.error("-->> update timePeriodLocation so new data fetch for this period")
        fetchDataLocation(
          settings: settings,
          token: keyChainviewModel.token,
          observationsLocation: observationsLocation,
          locationIdViewModel: locationIdViewModel,
          geoJSONViewModel: geoJSONViewModel,
          coordinate: setLocation,
          timePeriod: settings.timePeriodLocation)
        settings.hasLocationLoaded = true
      }

      .onChange(of: settings.timePeriodLocation) {
        log.error("-->> update timePeriodLocation so new data fetch for this period")
        fetchDataLocation(
          settings: settings,
          token: keyChainviewModel.token,
          observationsLocation: observationsLocation,
          locationIdViewModel: locationIdViewModel,
          geoJSONViewModel: geoJSONViewModel,
          coordinate: setLocation,
          timePeriod: settings.timePeriodLocation)
        settings.hasLocationLoaded = true
      }

      .onChange(of: setLocation) {
        log.info("update setLocation so new data fetch for this period")
        fetchDataLocation(
          settings: settings,
          token: keyChainviewModel.token,
          observationsLocation: observationsLocation,
          locationIdViewModel: locationIdViewModel,
          geoJSONViewModel: geoJSONViewModel,
          coordinate: setLocation,
          timePeriod: settings.timePeriodLocation)
        settings.hasLocationLoaded = true
      }

      .onChange(of: setRefresh) {
        log.info("update setRefresh so new data fetch for this period")
        fetchDataLocation(
          settings: settings,
          token: keyChainviewModel.token,
          observationsLocation: observationsLocation,
          locationIdViewModel: locationIdViewModel,
          geoJSONViewModel: geoJSONViewModel,
          coordinate: setLocation,
          timePeriod: settings.timePeriodLocation
        )
        settings.hasLocationLoaded = true
      }

      // set sort, filter and timePeriod
      .modifier(
        ObservationToolbarModifier(
          currentSortingOption: $currentSortingOption,
          currentFilteringOption: $currentFilteringOption,
          currentSpeciesGroup: $settings.selectedLocationSpeciesGroup,
          timePeriod: $settings.timePeriodLocation
        )
      )

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

        // update my locationData
        ToolbarItem(placement: .navigationBarLeading) {
          Button(action: {
            log.info("getMyLocation")

            if let location = locationManager.getCurrentLocation() {
              fetchDataLocation(
                settings: settings,
                token: keyChainviewModel.token,
                observationsLocation: observationsLocation,
                locationIdViewModel: locationIdViewModel,
                geoJSONViewModel: geoJSONViewModel,
                coordinate: CLLocationCoordinate2D(
                  latitude: location.coordinate.latitude,
                  longitude: location.coordinate.longitude),
                timePeriod: settings.timePeriodLocation)

            } else if let errorMessage = locationManager.errorMessage {
              log.error("Error: \(errorMessage)")
            } else {
              log.error("Retrieving location...")
            }
          }) {
            Image(systemName: "smallcircle.filled.circle")
              .uniformSize()
              .accessibilityLabel(updateLocation)
          }
        }

        // choose a location from a list
        ToolbarItem(placement: .navigationBarTrailing) {
          NavigationLink(
            destination: LocationListView(
              observationsLocation: observationsLocation,
              locationIdViewModel: locationIdViewModel,
              geoJSONViewModel: geoJSONViewModel,
              setLocation: $setLocation)
          ) {
            Image(systemSymbol: .listBullet)
              .uniformSize()
          }
          .accessibilityLabel(listWithFavoriteLocation)
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          AreaLocationButtonView()
        }

      }
      .onAppear {
        log.info("LocationView onAppear")
      }
    }
  }
}
