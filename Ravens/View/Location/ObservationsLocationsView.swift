//
//  ObservationsLocationsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 25/03/2024.
//

import SwiftUI
import SwiftyBeaver
import MapKit

struct ObservationsLocationView: View {
  let log = SwiftyBeaver.self

  @ObservedObject var observationsLocation: ObservationsViewModel
  @ObservedObject var locationIdViewModel: LocationIdViewModel
  @ObservedObject var geoJSONViewModel: GeoJSONViewModel

  @EnvironmentObject var locationManagerModel: LocationManagerModel
  @EnvironmentObject var locationManager: LocationManagerModel
  @EnvironmentObject var keyChainviewModel: KeychainViewModel
  @EnvironmentObject var settings: Settings
  @EnvironmentObject var speciesGroupsViewModel: SpeciesGroupsViewModel

  @Binding var selectedSpeciesID: Int?

  @Binding var currentSortingOption: SortingOption?
  @Binding var currentFilteringAllOption: FilterAllOption?
  @Binding var currentFilteringOption: FilteringRarityOption?

  @State private var retrievedData = false

  @Binding var setLocation: CLLocationCoordinate2D
  @Binding var setRefresh: Bool

  func forceUpdateLocation(_ coordinate: CLLocationCoordinate2D) {
      setLocation = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
  }

  var body: some View {
    NavigationStack {
      VStack {
        if showView { Text("ObservationsLocationView").font(.customTiny) }
        HStack {
          Text("\(settings.locationName)")
            .bold()
          Spacer()
        }
        .padding(.horizontal, 10)

        HStack {
          let speciesGroupName = speciesGroupsViewModel.speciesDictionary[settings.selectedLocationSpeciesGroup ?? 0] ?? ""
          SelectedUserSpeciesView(speciesGroup: settings.selectedLocationSpeciesGroup != -1 ? speciesGroupName : "∞")
          ObservationsCountView(count: observationsLocation.count)
          Spacer()
        }
        .padding(.horizontal, 10)

        HorizontalLine()

        if let observations = observationsLocation.observations, !observations.isEmpty {
            ObservationListView(
              observations: observations,
              selectedSpeciesID: $selectedSpeciesID,
              timePeriod: $settings.timePeriodLocation,
              entity: .location,
              currentSortingOption: $currentSortingOption,
              currentFilteringAllOption: $currentFilteringAllOption,
              currentFilteringOption: $currentFilteringOption) {
                // Handle end of list event
                print("End of list reached in ParentView observationsLocation")
                observationsLocation.fetchData(
                  settings: settings, url: observationsLocation.next,
                  token: keyChainviewModel.token,
                  completion: { log.error("observationsLocation.fetchData") })
                
              }
          } else {
            NoObservationsView()
          }
        }

      .refreshable {
        log.error("refreshing... ObservationsLocationsView")
        setRefresh.toggle()
      }

      .onAppear {
        if !settings.hasLocationLoaded {
          log.info("ObservationsLocationsView onAppear")
          if let location = locationManager.getCurrentLocation() {

            setLocation = location.coordinate
          }
        }
      }
    }
  }
}

func fetchDataLocation(
  settings: Settings,
  token: String,
  observationsLocation: ObservationsViewModel,
  locationIdViewModel: LocationIdViewModel,
  geoJSONViewModel: GeoJSONViewModel,
  coordinate: CLLocationCoordinate2D,
  timePeriod: TimePeriod?) {
    //  log.info("fetchDataLocation")
    // 1. get the id from the location
    locationIdViewModel.fetchLocations(
      latitude: coordinate.latitude,
      longitude: coordinate.longitude,
      token: token,
      completion: { fetchedLocations in

        // Use fetchedLocations here, actually it is one location,. the first
        settings.locationName = fetchedLocations[0].name
        settings.locationId = fetchedLocations[0].id
        settings.locationCoordinate = coordinate

        // 2a. get the geoJSON for this area, and we pick the first one = 0
        geoJSONViewModel.fetchGeoJsonData(
          for: fetchedLocations[0].id
        )

        // 2b. get the observations for this area
        observationsLocation.fetchDataInit(
          settings: settings,
          entity: .location,
          token: token,
          id: fetchedLocations[0].id,
          speciesGroup: settings.selectedLocationSpeciesGroup ?? 1, 
          timePeriod: timePeriod,
          completion: {
            settings.cameraAreaPosition = geoJSONViewModel.getCameraPosition()
          })
      })
  }

struct NoObservationsView: View {
  var body: some View {
    VStack(spacing: 16) {  // Adds spacing between elements
      EmptyView()
      Text(noObservations)
        .foregroundColor(.secondary)
    }
    .padding() // Adds padding around VStack content
    .frame(maxWidth: .infinity, maxHeight: .infinity) // Expands VStack to fill parent
    .background(Color(.systemBackground)) // Optional: Sets background color
    .multilineTextAlignment(.center) // Centers text within Text view
  }
}

struct NoObservationsView_Previews: PreviewProvider {
  static var previews: some View {
    NoObservationsView()
      .previewLayout(.sizeThatFits) // Sets the preview to fit content size
      .padding()
  }
}
