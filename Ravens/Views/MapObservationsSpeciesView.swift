//
//  MapObservationsSpeciesView.swift
//  Ravens
//
//  Created by Eric de Quartel on 19/01/2024.
//

import SwiftUI
import MapKit
import SwiftyBeaver

struct MapObservationsSpeciesView: View {
    let log = SwiftyBeaver.self
    @EnvironmentObject var observationsSpeciesViewModel: ObservationsSpeciesViewModel
    @EnvironmentObject var settings: Settings
    
    @State private var position : MapCameraPosition = .userLocation(fallback: .automatic)
//    @State private var position : MapCameraPosition = .automatic
    
    @State private var isSheetObservationsViewPresented = false
    
    var speciesID: Int
    
    var body: some View {
        ZStack {
//            MapReader { proxy in
                Map(position: $position) {
                    ForEach(observationsSpeciesViewModel.locations) { location in
                        Marker(location.name, systemImage: "bird.fill", coordinate: location.coordinate)
                            .tint(Color(myColor(value: location.rarity)))
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    SettingsDetailsView()
                        .frame(maxWidth: .infinity)
                        .padding()
                }
//            }
            .mapStyle(.hybrid(elevation: .realistic))
            .mapControls() {
                MapUserLocationButton()
                MapPitchToggle()
                MapCompass() //tapping this makes it north
            }
            
            ObservationCircle(toggle: $isSheetObservationsViewPresented, colorHex: "f7b731")
        }
        .sheet(isPresented: $isSheetObservationsViewPresented) {
            ObservationsSpeciesView(speciesID: speciesID)
        }
        .onAppear {
            observationsSpeciesViewModel.fetchData(speciesId: speciesID, endDate: settings.selectedDate, days: settings.days)
        }
    }
}

struct MapObservationSpeciesView_Previews: PreviewProvider {
    static var previews: some View {
        // Setting up the environment objects for the preview
        MapObservationsSpeciesView(speciesID: 62)
            .environmentObject(ObservationsSpeciesViewModel())
            .environmentObject(Settings())
    }
}

