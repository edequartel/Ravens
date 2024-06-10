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
    
    @State private var showingDetails = false
    @State private var speciesID = 58
    
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
//                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
//                                        Button {
//                                            log.info("Button tapped")
//                                            speciesID = result.species_detail.id
//                                            showingDetails.toggle()
//                                        } label: {
//                                            Label("Button", systemImage: "star")
//                                        }
//                                    }
                            }
                    }
//                    .sheet(isPresented: $showingDetails) {
////                        Text("Details for speciesID: \(speciesID)")
//                        SpeciesDetailsView(speciesID: speciesID)
//                    }
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
            if locationManagerModel.checkLocation() {
                let location = locationManagerModel.getCurrentLocation()
                settings.currentLocation = location
                fetchDataLocation(location: location?.coordinate ?? CLLocationCoordinate2D())
            } else {
                log.error("error observationsView getDataRadiusModel initialRadiusLoad")
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
            lat: location.latitude,
            long: location.longitude,
            settings: settings,
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


