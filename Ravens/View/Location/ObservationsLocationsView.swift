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

  @EnvironmentObject var locationIdViewModel: LocationIdViewModel
  @EnvironmentObject var locationManagerModel: LocationManagerModel
  @EnvironmentObject var geoJSONViewModel: GeoJSONViewModel
  @EnvironmentObject var settings: Settings
  
  @Binding var selectedSpeciesID: Int?
  
  @State private var retrievedData = false

  var body: some View {
    VStack {
      if showView { Text("ObservationsLocationView").font(.customTiny) }

      Text("cnt: \(observationsLocation.count)")

      if let observations = observationsLocation.observations, observations.count == 0 {
        Text(noObsLastPeriod)
          .font(.headline) // Set font style
          .foregroundColor(.secondary) // Adjust text color
          .multilineTextAlignment(.center) // Align text to the center
          .padding() // Add padding around the text
        Spacer()
      } else {
        if let observations = observationsLocation.observations, observations.count > 0 {
          SettingsDetailsView()
          HorizontalLine()
          ObservationListView(observations: observations, selectedSpeciesID: $selectedSpeciesID, entity: .area) {
            // Handle end of list event
             print("End of list reached in ParentView observationsLocation")
            observationsLocation.fetchData(settings: settings, url: observationsLocation.next, completion: { log.error("observationsLocation.fetchData") })

          }
        } else {
          NoObservationsView()
        }
      }
      
    }
    .refreshable {
//      getDataAreaModel()
    }
    .onAppear()  {
      log.info("MapObservationsLocationView onAppear")
      let location = locationManagerModel.getCurrentLocation()
//      settings.currentLocation = location //@@@
      fetchDataLocation(coordinate: location?.coordinate ?? CLLocationCoordinate2D())
        
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
              observationsLocation.fetchDataInit(
                settings: settings,
                entity: .area,
                id: fetchedLocations[0].id,
                completion: {
                  log.info("observationsLocationViewModel data loaded")
                  settings.cameraAreaPosition = geoJSONViewModel.getCameraPosition()
                })
            }
        )
      })
  }
  
//  func fetchDataLocationID() {
//    log.error("fetchDataLocationID by Point")
//    //1. get the geoJSON for this area / we pick the first one = 0
//    geoJSONViewModel.fetchGeoJsonData(
//      for: settings.locationId,
//      completion:
//        {
//          log.error("geoJSONViewModel data loaded")
//          //2. get the observations for this area
//          observationsLocation.fetchDataInit(
//            settings: settings,
//            entity: .area,
//            id: settings.locationId,
//            completion: {
//              log.info("observationsLocationViewModel data loaded")
//              settings.cameraAreaPosition = geoJSONViewModel.getCameraPosition()
//            })
//        }
//    )
//  }
}


struct NoObservationsView: View {
  var body: some View {
    VStack(spacing: 16) {  // Adds spacing between elements
      ProgressView()
        .frame(width: 100, height: 100)
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

