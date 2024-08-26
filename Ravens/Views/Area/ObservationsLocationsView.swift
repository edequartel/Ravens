//
//  ObservationsLocationsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 25/03/2024.
//

import SwiftUI
import SwiftyBeaver
import MapKit
import SwiftUIImageViewer


struct ObservationsLocationView: View {
    let log = SwiftyBeaver.self

    @EnvironmentObject var observationsLocationViewModel: ObservationsLocationViewModel
    @EnvironmentObject var locationIdViewModel: LocationIdViewModel
    @EnvironmentObject var locationManagerModel: LocationManagerModel
    @EnvironmentObject var geoJSONViewModel: GeoJSONViewModel

    @EnvironmentObject var settings: Settings

    @Binding var selectedObservation: Observation?
    @Binding var selectedObservationSound: Observation?

    var body: some View {
        VStack {
                SettingsDetailsView(
                    count: observationsLocationViewModel.locations.count,
                    results: observationsLocationViewModel.count
                )


            HorizontalLine()
            List {
                if let results =  observationsLocationViewModel.observations?.results {
                    ForEach(results
                        .filter { $0.rarity >= settings.selectedRarity }

                        .sorted(by: { ($1.rarity, $0.species_detail.name,  $1.date, $0.time ?? "00:00") < ($0.rarity, $1.species_detail.name, $0.date, $1.time ?? "00:00") })

                            //                            .filter { result in
                            //                                // Add your condition here
                            //                                // For example, the following line filters `result` to keep only those with a specific `rarity`.
                            //                                // You can replace it with your own condition.
                            //                                ((!settings.showObsPictures) && (!settings.showObsAudio)) ||
                            //                                (
                            //                                    (result.has_photo ?? false) && (settings.showObsPictures) ||
                            //                                    (result.has_sound ?? false) && (settings.showObsAudio)
                            //                                )
                            //                            }
                            , id: \.id) {
                        obs in
                        ObsAreaView(
                            selectedObservation: $selectedObservation,
                            obs: obs
                        )
                        .accessibilityLabel("\(obs.species_detail.name) \(obs.date) \(obs.time ?? "")")
                        .onTapGesture {
                            if let sounds = obs.sounds, !sounds.isEmpty {
                              selectedObservationSound = obs
                                vibrate()
                            }
                        }

                    }
                }
            }
            .listRowSeparator(.hidden)
            .listStyle(PlainListStyle())

            .toolbar {
                if (!settings.accessibility) {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            settings.hidePictures.toggle()
                        }) {
                            ImageWithOverlay(systemName: "photo", value: !settings.hidePictures)
                                .accessibilityElement(children: .combine)
                                .accessibility(label: Text("Hide pictures"))
                        }
                    }
                }
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

//struct ObservationsLocationView_Previews: PreviewProvider {
//    static var previews: some View {
//        ObservationsLocationView()
//            .environmentObject(ObservationsLocationViewModel())
//            .environmentObject(Settings())
//    }
//}

