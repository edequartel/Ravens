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

  @State private var retrieveData = false

  var body: some View {
    VStack {
      if showView { Text("ObservationsLocationView").font(.customTiny) }

      if let observations = observationsLocationViewModel.observations?.results, observations.count == 0 {
        Text("No observations for the last 14 days at this location")
            .font(.headline) // Set font style
            .foregroundColor(.secondary) // Adjust text color
            .multilineTextAlignment(.center) // Align text to the center
            .padding() // Add padding around the text
            Spacer()
      } else {
        if let observations = observationsLocationViewModel.observations?.results, observations.count > 0 {
          SettingsDetailsView(
            count: observationsLocationViewModel.locations.count,
            results: observationsLocationViewModel.count
          )
          HorizontalLine()
          ObservationListView(observations: observations, selectedSpeciesID: $selectedSpeciesID, entity: .area)
        } else {
          NoObservationsView()
        }
      }

    }
    .refreshable {
      getDataAreaModel()
    }
    .onAppear()  {
      getDataAreaModel()
    }
  }

  func getDataAreaModel() { //Dit moet een state variable of zoiets gaan worden.

    log.info("getDataAreaModel")
    log.info(settings.initialAreaLoad)
    if settings.initialAreaLoad {
      log.info("MapObservationsLocationView onAppear")
      let location = locationManagerModel.getCurrentLocation()
      settings.currentLocation = location
      fetchDataLocation(coordinate: location?.coordinate ?? CLLocationCoordinate2D())
      settings.initialAreaLoad = false
    }

    log.info(settings.isAreaChanged)
    if settings.isAreaChanged {
      log.info("isAreaChanged")
      let location = settings.currentLocation
      fetchDataLocation(coordinate: location?.coordinate ?? CLLocationCoordinate2D())
      settings.isAreaChanged = false
    }

    log.info(settings.isLocationIDChanged)
    if settings.isLocationIDChanged {
      log.info("isLocationIDChanged")
      fetchDataLocationID()
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



struct NoObservationsView: View {
    var body: some View {
        VStack(spacing: 16) {  // Adds spacing between elements
//            Text("Retrieving observations")
//                .font(.custom("CustomFontName", size: 12)) // Replace with your custom font
//                .foregroundColor(.secondary) // Optional: Sets text color to secondary color for a softer look

            ProgressView()
                .frame(width: 100, height: 100)
        }
        .padding() // Adds padding around VStack content
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Expands VStack to fill parent
        .background(Color(.systemBackground)) // Optional: Sets background color
//        .cornerRadius(12) // Optional: Adds rounded corners
//        .shadow(radius: 5) // Optional: Adds shadow for depth
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

