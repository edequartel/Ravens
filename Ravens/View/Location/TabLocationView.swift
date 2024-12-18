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
  @ObservedObject var observationsLocation: ObservationsViewModel
  @StateObject var locationIdViewModel = LocationIdViewModel()
  @StateObject var geoJSONViewModel = GeoJSONViewModel()

  @EnvironmentObject private var settings: Settings
  @EnvironmentObject private var areasViewModel: AreasViewModel
  @EnvironmentObject var locationManager: LocationManagerModel

  @EnvironmentObject var accessibilityManager: AccessibilityManager

  @Binding var selectedSpeciesID: Int?

  @State private var searchText: String = ""
  @State private var showFirstView = false
  @State private var isShowingLocationList = false


  var body: some View {
    NavigationView {
      VStack {
        if showView { Text("TabLocationView").font(.customTiny) }
        if showFirstView && !accessibilityManager.isVoiceOverEnabled {
          MapObservationsLocationView(
            observationsLocation: observationsLocation,
            locationIdViewModel: locationIdViewModel,
            geoJSONViewModel: geoJSONViewModel)
        } else {
          ObservationsLocationView(
            observationsLocation: observationsLocation,
            locationIdViewModel: locationIdViewModel,
            geoJSONViewModel: geoJSONViewModel,
            selectedSpeciesID:  $selectedSpeciesID)
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
        ToolbarItem(placement: .navigationBarLeading) { //@@@
            Button(action: {
                log.info("getMyLocation")

                if let location = locationManager.getCurrentLocation() {
                  //here getting the data for the location
                  fetchDataLocation(
                    settings: settings,
                    observationsLocation: observationsLocation,
                    locationIdViewModel: locationIdViewModel,
                    geoJSONViewModel: geoJSONViewModel,
                    coordinate: CLLocationCoordinate2D(
                      latitude: location.coordinate.latitude,
                      longitude: location.coordinate.longitude))
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
          NavigationLink(
            destination: LocationListView(
              observationsLocation: observationsLocation,
              locationIdViewModel: locationIdViewModel,
              geoJSONViewModel: geoJSONViewModel)) {
                Image(systemSymbol: .listBullet)
                  .uniformSize()
              }
              .accessibilityLabel(listWithFavoriteLocation)
        }

      }
      .onAppear {
        log.info("LocationView onAppear")
      }
    }
  }


}



