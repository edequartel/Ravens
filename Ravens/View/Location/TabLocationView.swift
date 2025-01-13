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

import SwiftUI
import CoreLocation

// Add Equatable conformance for CLLocationCoordinate2D
extension CLLocationCoordinate2D: @retroactive Equatable {
  public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
  }
}

struct TabLocationView: View {
  let log = SwiftyBeaver.self
  @ObservedObject var observationsLocation: ObservationsViewModel //???

  @StateObject var locationIdViewModel = LocationIdViewModel()
  @StateObject var geoJSONViewModel = GeoJSONViewModel()

  @EnvironmentObject private var settings: Settings
  @EnvironmentObject private var areasViewModel: AreasViewModel
  @EnvironmentObject var locationManager: LocationManagerModel

  @EnvironmentObject var accessibilityManager: AccessibilityManager
  @EnvironmentObject var userViewModel:  UserViewModel

  @Binding var selectedSpeciesID: Int?

  @State private var searchText: String = ""
  @State private var showFirstView = false
  @State private var isShowingLocationList = false


  @State private var currentSortingOption: SortingOption = .date
  @State private var currentFilteringAllOption: FilterAllOption = .native
  @State private var currentFilteringOption: FilteringRarityOption = .all


  @State private var setLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
  @State private var setRefresh: Bool = false

  @EnvironmentObject var locationManagerModel: LocationManagerModel
  @EnvironmentObject var keyChainviewModel: KeychainViewModel

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
            selectedSpeciesID:  $selectedSpeciesID,
            currentSortingOption: $currentSortingOption,
            currentFilteringAllOption: $currentFilteringAllOption,
            currentFilteringOption: $currentFilteringOption,
            setLocation: $setLocation,
            setRefresh: $setRefresh
          )
        }
      }

      .onChange(of: settings.timePeriodLocation) {
        log.info("update timePeriodLocation so new data fetch for this period")
        fetchDataLocation(
          settings: settings,
          token: keyChainviewModel.token,
          observationsLocation: observationsLocation,
          locationIdViewModel: locationIdViewModel,
          geoJSONViewModel: geoJSONViewModel,
          coordinate: setLocation)
        settings.hasLocationLoaded = true 
      }

      .onChange(of: setLocation) {
        log.error("update setLocation so new data fetch for this period")
        fetchDataLocation(
          settings: settings,
          token: keyChainviewModel.token,
          observationsLocation: observationsLocation,
          locationIdViewModel: locationIdViewModel,
          geoJSONViewModel: geoJSONViewModel,
          coordinate: setLocation
        )
        settings.hasLocationLoaded = true
      }


      .onChange(of: setRefresh) {
        log.error("update setRefresh so new data fetch for this period")
        fetchDataLocation(
          settings: settings,
          token: keyChainviewModel.token,
          observationsLocation: observationsLocation,
          locationIdViewModel: locationIdViewModel,
          geoJSONViewModel: geoJSONViewModel,
          coordinate: setLocation
        )
        settings.hasLocationLoaded = true
      }

      
      //set sort, filter and timePeriod
      .modifier(ObservationToolbarModifier(
        currentSortingOption: $currentSortingOption,
        currentFilteringAllOption: $currentFilteringAllOption,
        currentFilteringOption: $currentFilteringOption,
        timePeriod: $settings.timePeriodLocation
      ))

      .toolbar {
        //map or list
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
              //here getting the data for the location
              setLocation = location.coordinate
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

        //favo location
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

        //choose a location from a list
        ToolbarItem(placement: .navigationBarTrailing) {
          NavigationLink(
            destination: LocationListView(
              observationsLocation: observationsLocation,
              locationIdViewModel: locationIdViewModel,
              geoJSONViewModel: geoJSONViewModel,
              setLocation: $setLocation)) {
                Image(systemSymbol: .listBullet)
                  .uniformSize()
              }
              .accessibilityLabel(listWithFavoriteLocation)
        }

      }
      .onAppear {
        log.error("LocationView onAppear")
      }
    }
  }


}



