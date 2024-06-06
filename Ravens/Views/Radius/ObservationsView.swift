//
//  ObservationsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 11/01/2024.
//

import SwiftUI
import SwiftyBeaver
import MapKit

struct ObservationsView: View {
    let log = SwiftyBeaver.self
    @EnvironmentObject var locationManagerModel: LocationManagerModel
    @EnvironmentObject var observationsRadiusViewModel: ObservationsRadiusViewModel
    @EnvironmentObject var keyChainViewModel: KeychainViewModel
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        VStack {
            if (!keyChainViewModel.token.isEmpty) {
                if let results = observationsRadiusViewModel.observations?.results, results.count > 0 {
                    List {
                        ForEach(results.sorted(
                            by: {
                                ($1.rarity, $0.species_detail.name, $1.date, $0.time ?? "00:00") <
                                    ($0.rarity, $1.species_detail.name, $0.date, $1.time ?? "00:00")
                            }), id: \.id) {
                                result in
                                ObsRadiusView(obs: result, showUsername: false)
                            }
                    }
                } else {
                    ProgressView()
                }
            }
        }
        .onAppear() {
            getDataRadiusModel()
        }
    }
    
    func getDataRadiusModel() {
        if settings.initialRadiusLoad {
            print("OBS LIST only when start first time")
            if locationManagerModel.checkLocation() {
                let location = locationManagerModel.getCurrentLocation() //<<
                settings.currentLocation = location //<<
//                settings.circlePos = location?.coordinate
                //for the radius
//                fetchDataLocation(location: location?.coordinate)
                observationsRadiusViewModel.fetchData(
                    lat: location?.coordinate.latitude ?? 0,
                    long: location?.coordinate.longitude ?? 0,
                    settings: settings,
                    completion: {
                        log.info("settings.initialRadiusLoad observationsViewModel data loaded")
                    })
            }
            settings.initialRadiusLoad = false
        }
        //
        if settings.isRadiusChanged {
            print("changed Radius")
            if let circlePosition = settings.circlePos {
                fetchDataLocation(location: circlePosition)
            }
            settings.isRadiusChanged = false
        }
    }
    
    func fetchDataLocation(location: CLLocationCoordinate2D) {
        observationsRadiusViewModel.fetchData(
            lat: location.latitude,
            long: location.longitude,
            settings: settings,
            completion: { print("observationsViewModel.locations") }
        )
    }
}

struct ObservationsView_Previews: PreviewProvider {
    static var previews: some View {
        // Setting up the environment objects for the preview
        ObservationsView()
            .environmentObject(ObservationsRadiusViewModel())
            .environmentObject(KeychainViewModel())
    }
}


