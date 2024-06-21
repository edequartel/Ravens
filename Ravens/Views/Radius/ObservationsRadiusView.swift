//
//  ObservationsRadiusView.swift
//  Ravens
//
//  Created by Eric de Quartel on 11/01/2024.
//

import SwiftUI
import SwiftyBeaver
import MapKit

struct ObservationsRadiusView: View {
    let log = SwiftyBeaver.self
    @EnvironmentObject var locationManagerModel: LocationManagerModel
    @EnvironmentObject var observationsRadiusViewModel: ObservationsRadiusViewModel
    @EnvironmentObject var keyChainViewModel: KeychainViewModel
    @EnvironmentObject var settings: Settings
    
    @State private var selectedObservation: Observation?
    
    var body: some View {
        NavigationView {
            VStack {
                if (!keyChainViewModel.token.isEmpty) {
                    if let results = observationsRadiusViewModel.observations?.results, results.count > 0 {
                        List {
                            ForEach(results.sorted(
                                by: {
                                    ($1.rarity, $0.species_detail.name, $1.date, $0.time ?? "00:00") <
                                    ($0.rarity, $1.species_detail.name, $0.date, $1.time ?? "00:00")
                                })
                                .filter { result in
                                    ((!settings.showObsPictures) && (!settings.showObsAudio)) ||
                                    (
                                        (result.has_photo ?? false) && (settings.showObsPictures) ||
                                        (result.has_sound ?? false) && (settings.showObsAudio)
                                    )
                                }
                                    , id: \.id) { result in
                                ObsRadiusView(
                                    selectedObservation: $selectedObservation,
                                    obs: result
                                )
                            }
                        }
                    } else {
                        ProgressView()
                    }
                }
            }
        }
//        .edgesIgnoringSafeArea(.all)
        
        .sheet(item: $selectedObservation) { item in
            SpeciesDetailsView(speciesID: item.species_detail.id)
        }
        
        .onAppear() {
            getDataRadiusModel()
        }
    }
    
    func getDataRadiusModel() {
        if settings.initialRadiusLoad {
            if locationManagerModel.checkLocation() {
                let location = locationManagerModel.getCurrentLocation()
                settings.currentLocation = location
                fetchDataLocation(location: location?.coordinate ?? CLLocationCoordinate2D())
            } else {
                log.error("error observationsRadiusView getDataRadiusModel initialRadiusLoad")
            }
            settings.initialRadiusLoad = false
        }
        
        if settings.isRadiusChanged {
            if locationManagerModel.checkLocation() {
                let location = settings.currentLocation //and now for the saved locations
                fetchDataLocation(location: location?.coordinate ?? CLLocationCoordinate2D())
            } else {
                log.error("error observationsView getDataRadiusModel isRadiusChanged")
            }
            settings.isRadiusChanged = false
        }
    }

    func fetchDataLocation(location: CLLocationCoordinate2D) {
        observationsRadiusViewModel.fetchData(
            settings: settings,
            lat: location.latitude,
            long: location.longitude,
            completion: { log.info("LIST observationsViewModel.locations") }
        )
    }
}

struct ObservationsView_Previews: PreviewProvider {
    static var previews: some View {
        // Setting up the environment objects for the preview
        ObservationsRadiusView()
            .environmentObject(ObservationsRadiusViewModel())
            .environmentObject(KeychainViewModel())
    }
}


