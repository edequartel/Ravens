//
//  ObservationsLocationsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 25/03/2024.
//

import SwiftUI
import SwiftyBeaver


struct ObservationsLocationView: View {
    let log = SwiftyBeaver.self
    
    @EnvironmentObject var viewModel: ObservationsLocationViewModel
    @EnvironmentObject var observersViewModel: ObserversViewModel
    @EnvironmentObject var observationsLocationViewModel: ObservationsLocationViewModel
    @EnvironmentObject var speciesGroupViewModel: SpeciesGroupViewModel
    
    @ObservedObject var locationManager = LocationManager()
    
    @StateObject private var locationIdViewModel = LocationIdViewModel()
    @StateObject private var geoJSONViewModel = GeoJSONViewModel()
    
    @EnvironmentObject var settings: Settings
    @Environment(\.presentationMode) var presentationMode
    
    @State private var limit = 100
    @State private var offset = 0
    
//    
    var body: some View {
            VStack {
                List {
                    if let results =  viewModel.observations?.results {
                        ForEach(results.sorted(by: { ($1.rarity, $0.species_detail.name,  $1.date, $0.time ?? "00:00") < ($0.rarity, $1.species_detail.name, $0.date, $1.time ?? "00:00") }), id: \.id) {
                            result in
                            ObsAreaView(obs: result)
                        }
                    }
                }
                .padding(-10)
            }
            .onAppear() {
                log.error("ObservationsLocationView onAppear")
                
                //get the POIs
//                viewModel.fetchPOIs(completion: { POIs = viewModel.POIs} )
                
                //get the location
                if settings.initialLoadLocation {
                    
                    log.info("ObservationsLocationView initiaLLoad, get data at startUp and Position")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) { //opstarten
                        settings.currentLocation = self.locationManager.location
                        
                        //get the observations
                        //geoJSON
//                        polyOverlays.removeAll()
                        locationIdViewModel.fetchLocations(
                            latitude: settings.currentLocation?.coordinate.latitude ?? 0,
                            longitude: settings.currentLocation?.coordinate.longitude ?? 0) { fetchedLocations in
                                // Use fetchedLocations here //actually it is one location
                                for location in fetchedLocations {
                                    geoJSONViewModel.fetchGeoJsonData(for: String(location.id)) { polyOverlaysIn in
//                                        polyOverlays = polyOverlaysIn
                                        settings.locationId = location.id
                                        settings.locationStr = location.name // the first is the same
                                        
                                        fetchDataModel()
//                                        cameraPosition = getCameraPosition()
                                    }
                                }
                            }
                        
                        //only once
                        settings.initialLoadLocation = false
                    }
                } else {
                    fetchDataModel()
                }
                
                //get selectedGroup
                log.verbose("settings.selectedGroupId:  \(settings.selectedGroup)")
                speciesGroupViewModel.fetchData(language: settings.selectedLanguage)
            }
    }
    
    func fetchDataModel() {
        log.error("MapObservationsLocationView fetchDataModel")
        observationsLocationViewModel.fetchData(
            locationId:  settings.locationId,
            limit: 100,
            offset: 0,
            settings: settings,
            completion: {
                //locations = observationsLocationViewModel.locations 
                log.info(observationsLocationViewModel.span)
                
//                cameraPosition = getCameraPosition()
            } )
    }
}

struct ObservationsLocationView_Previews: PreviewProvider {
    static var previews: some View {
        ObservationsLocationView()
            .environmentObject(ObservationsLocationViewModel())
            .environmentObject(ObserversViewModel())
            .environmentObject(SpeciesGroupViewModel(settings: Settings()))
            .environmentObject(Settings())
    }
}

