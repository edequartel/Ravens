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

struct TabLocationView: View {
  let log = SwiftyBeaver.self
  @EnvironmentObject private var settings: Settings
  @EnvironmentObject private var areasViewModel: AreasViewModel
  @EnvironmentObject var locationManager: LocationManagerModel
  @EnvironmentObject var locationIdViewModel: LocationIdViewModel
  @EnvironmentObject var geoJSONViewModel: GeoJSONViewModel
  @EnvironmentObject var observationsLocationViewModel: ObservationsViewModel
  @EnvironmentObject var accessibilityManager: AccessibilityManager

  @Binding var selectedSpeciesID: Int?

  @State private var searchText: String = ""
  @State private var showFirstView = true
  @State private var isShowingLocationList = false


  var body: some View {
    NavigationView {
      VStack {
        if showView { Text("TabLocationView").font(.customTiny) }
        if showFirstView && !accessibilityManager.isVoiceOverEnabled {
          MapObservationsLocationView()
        } else {
          ObservationsLocationView(selectedSpeciesID: $selectedSpeciesID)
        }
      }

      .toolbar {
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

        //update my locationData
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: {
                log.info("getMyLocation")

                if let location = locationManager.getCurrentLocation() {
                    log.info("Lat \(location.coordinate.latitude)")
                    log.info("Long \(location.coordinate.longitude)")

                    settings.currentLocation = CLLocation(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude
                    )

                    fetchDataLocation(coordinate: location.coordinate)
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

        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            if areasViewModel.isIDInRecords(areaID: settings.locationId) {
              areasViewModel.removeRecord(areaID: settings.locationId)
            } else {
              log.error("\(settings.locationName) \(settings.locationId) \(settings.locationCoordinate?.latitude ?? 0) \(settings.locationCoordinate?.longitude ?? 0)")

              areasViewModel.appendRecord(
                areaName: settings.locationName,
                areaID: settings.locationId,
                latitude: settings.locationCoordinate?.latitude ?? 0,
                longitude: settings.locationCoordinate?.longitude ?? 0
              )
              //

            }
          }) {
            Image(systemSymbol: areasViewModel.isIDInRecords(areaID: settings.locationId) ? SFAreaFill : SFArea)
              .uniformSize()
              .accessibility(
                label: Text(areasViewModel.isIDInRecords(areaID: settings.locationId) ? removeLocationFromFavorite : addLocationToFavorite))
          }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          NavigationLink(destination: AreasView()) {
            Image(systemSymbol: .listBullet)
              .uniformSize()
          }
          .accessibilityLabel(listWithFavoriteLocation)
        }

      }

      .onAppear {
        log.info("LocationView onAppear")

      }
      .onAppearOnce {
        showFirstView = settings.mapPreference
      }
    }
  }


  func fetchDataLocation(coordinate: CLLocationCoordinate2D) {
    log.info("MapObservationsLocationView fetchDataLocation")
    locationIdViewModel.fetchLocations(
      latitude: coordinate.latitude,
      longitude: coordinate.longitude,
      completion: { fetchedLocations in
        log.info("MaplocationIdViewModel data loaded")
        // Use fetchedLocations here //actually it is one location
        settings.locationName = fetchedLocations[0].name
        settings.locationId = fetchedLocations[0].id
        settings.locationCoordinate = CLLocationCoordinate2D(
          latitude: coordinate.latitude,
          longitude: coordinate.longitude)

        for location in fetchedLocations {
          log.info("locatiob \(location)")
        }

        //1. get the geoJSON for this area / we pick the first one = 0
        geoJSONViewModel.fetchGeoJsonData(
          for: fetchedLocations[0].id,
          completion:
            {
              log.info("geoJSONViewModel data loaded")

              //2. get the observations for this area
              observationsLocationViewModel.fetchData(
                settings: settings,
                entity: .area,
                id: fetchedLocations[0].id,
                completion: {
                  log.info("observationsLocationViewModel data loaded")
                  settings.cameraAreaPosition = geoJSONViewModel.getCameraPosition() //automatic
                })
            }
        )
      })
  }
}

#Preview {
  TabLocationView(selectedSpeciesID: .constant(nil))
      .environmentObject(Settings())
      .environmentObject(AreasViewModel())
      .environmentObject(LocationManagerModel())
      .environmentObject(LocationIdViewModel())
      .environmentObject(GeoJSONViewModel())
      .environmentObject(ObservationsViewModel())
}

