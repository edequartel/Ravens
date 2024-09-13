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

  @EnvironmentObject var observationsLocationViewModel: ObservationsLocationViewModel
  @EnvironmentObject var locationIdViewModel: LocationIdViewModel
  @EnvironmentObject var locationManagerModel: LocationManagerModel
  @EnvironmentObject var geoJSONViewModel: GeoJSONViewModel
  @EnvironmentObject var settings: Settings

  @Binding var selectedSpeciesID: Int?

  var body: some View {
    VStack {

      if let observations = observationsLocationViewModel.observations?.results {
        if showView { Text("ObservationsLocationView").font(.customTiny) }
        SettingsDetailsView(
          count: observationsLocationViewModel.locations.count,
          results: observationsLocationViewModel.count
        )
        HorizontalLine()
        ObservationListView(observations: observations, entity: .area, selectedSpeciesID: $selectedSpeciesID)
      } else {
        ProgressView()
      }
    }

    .onAppear()  {
      getDataAreaModel()
    }
  }

  func getDataAreaModel() {
    log.info("getDataAreaModel")
    log.info(settings.initialAreaLoad)
    if settings.initialAreaLoad {
      log.info("MapObservationsLocationView onAppear")
      if locationManagerModel.checkLocation() {
        let location = locationManagerModel.getCurrentLocation()
        settings.currentLocation = location
        fetchDataLocation(coordinate: location?.coordinate ?? CLLocationCoordinate2D())
      } else {
        log.info("error observationsLocationsView getDataAreaModel initialAreaLoad")
      }
      settings.initialAreaLoad = false
    }

    log.info(settings.isAreaChanged)
    if settings.isAreaChanged {
      log.info("isAreaChanged")
      if locationManagerModel.checkLocation() {
        let location = settings.currentLocation
        fetchDataLocation(coordinate: location?.coordinate ?? CLLocationCoordinate2D())
      } else {
        log.error("error observationsLocationsView getDataAreaModel isAreaChanged")
      }
      settings.isAreaChanged = false
    }

    log.info(settings.isLocationIDChanged)
    if settings.isLocationIDChanged {
      log.info("isLocationIDChanged")
      if locationManagerModel.checkLocation() {
        fetchDataLocationID()
      } else {
        log.error("error observationsLocationsView getDataAreaModel isLocationIDChanged")
      }
      settings.isLocationIDChanged = false
    }
  }


  func fetchDataLocation(coordinate: CLLocationCoordinate2D) {
    log.error("fetchDataLocation")
    locationIdViewModel.fetchLocations(
      latitude: coordinate.latitude,
      longitude: coordinate.longitude,
      completion: { fetchedLocations in
        log.info("locationIdViewModel data loaded")
        // Use fetchedLocations here //actually it is one location
        settings.locationName = fetchedLocations[0].name
        settings.locationId = fetchedLocations[0].id
        for location in fetchedLocations {
          log.info("location \(location)")
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
                locationId: fetchedLocations[0].id,
                limit: 100,
                offset: 0,
                completion: {
                  log.info("observationsLocationViewModel data loaded")
                  settings.cameraAreaPosition = geoJSONViewModel.getCameraPosition()
                })
            }
        )
      })
  }

  func fetchDataLocationID() {
    log.error("fetchDataLocationID")
    //1. get the geoJSON for this area / we pick the first one = 0
    geoJSONViewModel.fetchGeoJsonData(
      for: settings.locationId,
      completion:
        {
          log.error("geoJSONViewModel data loaded")

          //2. get the observations for this area
          observationsLocationViewModel.fetchData(
            settings: settings,
            locationId: settings.locationId,
            limit: 100,
            offset: 0,
            completion: {
              log.info("observationsLocationViewModel data loaded")
              settings.cameraAreaPosition = geoJSONViewModel.getCameraPosition()
            })
        }
    )
  }
}



