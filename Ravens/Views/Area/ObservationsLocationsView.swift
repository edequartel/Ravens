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

    var body: some View {
            VStack {
                List {
                    if let results =  observationsLocationViewModel.observations?.results {
                        ForEach(results.sorted(by: { ($1.rarity, $0.species_detail.name,  $1.date, $0.time ?? "00:00") < ($0.rarity, $1.species_detail.name, $0.date, $1.time ?? "00:00") }), id: \.id) {
                            result in
                            ObsAreaView(obs: result)
                        }
                    }
                }
            }
            .onAppear()  {
            if settings.initialLoadArea {
                log.info("MapObservationsLocationView onAppear")
                if locationManagerModel.checkLocation() {
                    let location = locationManagerModel.getCurrentLocation()
                    let defaultCoordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
                    fetchLocationData(coordinate: location?.coordinate ?? defaultCoordinate)
                    settings.initialLoadArea = false
                }
            }
        }
    }
        
    
    func fetchLocationData(coordinate: CLLocationCoordinate2D) {
        locationIdViewModel.fetchLocations(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            completion: { fetchedLocations in
                log.info("locationIdViewModel data loaded")
                // Use fetchedLocations here //actually it is one location
                settings.locationName = fetchedLocations[0].name
                for location in fetchedLocations {
                    log.info(location)
                }
                
                //1. get the geoJSON for this area / we pick the first one = 0
                geoJSONViewModel.fetchGeoJsonData(
                    for: fetchedLocations[0].id,
                    completion:
                        {
                            log.info("geoJSONViewModel data loaded")
                            //2. get the observations for this area
                            observationsLocationViewModel.fetchData( //settings??
                                locationId: fetchedLocations[0].id,
                                limit: 100,
                                offset: 0,
                                settings: settings,
                                completion: {
                                    log.info("observationsLocationViewModel data loaded")
//                                    cameraPosition = getCameraPosition()
                                })
                        }
                )
            })
    }
}

struct ObservationsLocationView_Previews: PreviewProvider {
    static var previews: some View {
        ObservationsLocationView()
            .environmentObject(ObservationsLocationViewModel())
            .environmentObject(Settings())
    }
}

