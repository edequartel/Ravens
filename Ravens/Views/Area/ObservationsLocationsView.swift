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
                Text(settings.locationName)
                    .bold()
                    .lineLimit(1)
                    .foregroundColor(.blue)
//                    .padding()
                List {
                    if let results =  observationsLocationViewModel.observations?.results {
                        ForEach(results
                            .filter { $0.rarity >= settings.selectedRarity }
                            .sorted(by: { ($1.rarity, $0.species_detail.name,  $1.date, $0.time ?? "00:00") < ($0.rarity, $1.species_detail.name, $0.date, $1.time ?? "00:00") }), id: \.id) {
                            obs in
                            ObsAreaView(obs: obs)
                        }
                    }
                }
            }
            .onAppear()  {
                getDataAreaModel()
            }
    }
     
    func getDataAreaModel() {
        log.error("--> getDataAreaModel")
//        print("YYY")
        print(settings.initialAreaLoad)
        if settings.initialAreaLoad {
            log.error("--> MapObservationsLocationView onAppear")
            if locationManagerModel.checkLocation() {
                let location = locationManagerModel.getCurrentLocation()
                settings.currentLocation = location
                fetchDataLocation(coordinate: location?.coordinate ?? CLLocationCoordinate2D())
            } else {
                log.info("error observationsLocationsView getDataAreaModel initialAreaLoad")
            }
            settings.initialAreaLoad = false
//            print("XXXX")
//            settings.isLocationIDChanged = true
//            print("XXXX")
        }
        
        print(settings.isAreaChanged)
        if settings.isAreaChanged {
            log.info("isAreaChanged")
            if locationManagerModel.checkLocation() {
                let location = settings.currentLocation
                fetchDataLocation(coordinate: location?.coordinate ?? CLLocationCoordinate2D())
            } else {
                log.info("error observationsLocationsView getDataAreaModel isAreaChanged")
            }
            settings.isAreaChanged = false
        }
        
        print(settings.isLocationIDChanged)
        if settings.isLocationIDChanged {
            log.error("isLocationIDChanged")
            if locationManagerModel.checkLocation() {
                fetchDataLocationID()
            } else {
                log.error("error observationsLocationsView getDataAreaModel isLocationIDChanged")
            }
            settings.isLocationIDChanged = false
        }
    }
    
    
    func fetchDataLocation(coordinate: CLLocationCoordinate2D) {
        log.info("fetchDataLocation")
        locationIdViewModel.fetchLocations(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            completion: { fetchedLocations in
                log.info("locationIdViewModel data loaded")
                // Use fetchedLocations here //actually it is one location
                settings.locationName = fetchedLocations[0].name
                settings.locationId = fetchedLocations[0].id
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
                            observationsLocationViewModel.fetchData(
                                locationId: fetchedLocations[0].id,
                                limit: 100,
                                offset: 0,
                                settings: settings,
                                completion: {
                                    log.info("observationsLocationViewModel data loaded")
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
                        locationId: settings.locationId,
                        limit: 100,
                        offset: 0,
                        settings: settings,
                        completion: {
                            log.error("observationsLocationViewModel data loaded")
                        })
                }
        )
    }
}

struct ObservationsLocationView_Previews: PreviewProvider {
    static var previews: some View {
        ObservationsLocationView()
            .environmentObject(ObservationsLocationViewModel())
            .environmentObject(Settings())
    }
}

