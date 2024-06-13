//
//  MapObservationsUserView.swift
//  Ravens
//
//  Created by Eric de Quartel on 04/03/2024.
//

import SwiftUI
import MapKit
import SwiftyBeaver

struct MapObservationsUserView: View {
    let log = SwiftyBeaver.self
    @EnvironmentObject var observationsUserViewModel: ObservationsUserViewModel
    @EnvironmentObject var keyChainViewModel: KeychainViewModel
    @EnvironmentObject var userViewModel:  UserViewModel
    @EnvironmentObject var settings: Settings
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    @State private var showObservers: Bool = false
    @State private var showListView: Bool = false
    
    var body: some View {
        
        ZStack(alignment: .topLeading) {
            Map(position: $cameraPosition) {
//                UserAnnotation()
                
                ForEach(observationsUserViewModel.locations) { location in
                    Annotation(location.name, coordinate: location.coordinate) {
                        Circle()
                            .fill(Color(myColor(value: location.rarity)))
                            .stroke(location.hasSound ? Color.white : Color.clear,lineWidth: 1)
                            .frame(width: 12, height: 12)
                        
                            .overlay(
                                Circle()
                                    .fill(location.hasPhoto ? Color.white : Color.clear)
                                    .frame(width: 6, height: 6)
                            )
                    }
                }
            }
//            .safeAreaInset(edge: .bottom) {
//                VStack {
//                    SettingsDetailsView(
//                        count: observationsUserViewModel.locations.count,
//                        results: observationsUserViewModel.observations?.results.count ?? 0)
//                }
//                .padding(5)
//                .foregroundColor(.obsGreenFlower)
//                .background(Color.obsGreenEagle.opacity(0.5))
//            }
            
            .mapStyle(settings.mapStyle)

            .mapControls() {
                MapUserLocationButton()
                MapPitchToggle()
                MapCompass() //tapping this makes it north
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ObserversView()) {
                    Label("Observers", systemImage: "list.bullet")
                }
            }
        }

        .onAppear {
            if settings.initialUsersLoad {
                observationsUserViewModel.fetchData(
                    settings: settings,
                    userId: settings.userId,
                    completion: { log.info("viewModel.fetchData completion") })
                settings.initialUsersLoad = false
            }
        }
    }
}

