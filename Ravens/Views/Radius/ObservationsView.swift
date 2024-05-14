//
//  ObservationsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 11/01/2024.
//

import SwiftUI
import MapKit


struct ObservationsView: View {
    @EnvironmentObject var observationsViewModel: ObservationsViewModel
    @EnvironmentObject var keyChainViewModel: KeychainViewModel
    @EnvironmentObject var settings: Settings
//    @EnvironmentObject var speciesGroupViewModel: SpeciesGroupViewModel
    
//    @State private var circlePos: CLLocationCoordinate2D?
//    @ObservedObject var locationManager = LocationManager()
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
            ZStack {
                HStack {
                    Spacer()
                    Image(systemName: keyChainViewModel.token.isEmpty ? "person.slash" : "person")
                        .foregroundColor(keyChainViewModel.token.isEmpty ? .red : .black)
                    
                    Text("Radius")
                        .bold()
                    Text("\(observationsViewModel.observations?.results.count ?? 0)x")
                        .bold()
                }
                .padding(8)
                .background(Color(hex: obsStrNorthSeaBlue))

                
                if (!keyChainViewModel.token.isEmpty) {
                    List {
                        if let results = observationsViewModel.observations?.results {
                            ForEach(results.sorted(by: { ($1.rarity, $0.species_detail.name,  $1.date, $0.time ?? "00:00") < ($0.rarity, $1.species_detail.name, $0.date, $1.time ?? "00:00") }), id: \.id) {
                                result in
                                ObsView(obs: result, showUsername: false)
                            }
                        } else {
                            Text("nobsavaliable")
                        }
                    }
                    .padding(-10)
                }
            }
//            .onAppear() {
////                log.info("MapObservationView onAppear")
//                
//                //getUser
////                userViewModel.fetchUserData(settings: settings, completion: {
////                    log.info("userViewModel.fetchUserData userid \(userViewModel.user?.id ?? 0)")
////                    settings.userId = userViewModel.user?.id ?? 0
////                })
//                
////                //get the POIs
////                viewModel.fetchPOIs(completion: { POIs = viewModel.POIs} )
//                
//                //get the location
//                if settings.initialLoad {
////                    log.info("MapObservationView initiaLLoad, get data at startUp and Position")
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) { //opstarten
//                        settings.currentLocation = self.locationManager.location
//                        circlePos = settings.currentLocation?.coordinate
//                        
//                        //get the observations
//                        fetchDataModel()
////                        cameraPosition = getCameraPosition()
//                        
//                        //only once
//                        settings.initialLoad = false
//                    }
//                } else {
////                    log.info("MapObservationView NOT initiaLLoad")
//    //                circlePos = settings.currentLocation?.coordinate
//    //
//    //                //get the observations
//                    fetchDataModel()
//    //                cameraPosition = getCameraPosition()
//                }
//                
//                //get selectedGroup
////                log.verbose("settings.selectedGroupId:  \(settings.selectedGroup)")
//                speciesGroupViewModel.fetchData(language: settings.selectedLanguage)
//            }
    }
    
//    func fetchDataModel() {
//        observationsViewModel.fetchData(
//            lat: circlePos?.latitude ?? 0,
//            long: circlePos?.longitude ?? 0,
//            settings: settings,
//            completion: { print("locations = observationsViewModel.locations niet doen") }
//        )
//    }
}


struct ObservationsView_Previews: PreviewProvider {
    static var previews: some View {
        // Setting up the environment objects for the preview
        ObservationsView()
            .environmentObject(ObservationsViewModel())
            .environmentObject(KeychainViewModel())
//            .environmentObject(Settings())
    }
}


