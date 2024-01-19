//
//  MapObservationsSpeciesView.swift
//  Ravens
//
//  Created by Eric de Quartel on 19/01/2024.
//

import SwiftUI
import MapKit

struct MapObservationsSpeciesView: View {
    @EnvironmentObject var observationsSpeciesViewModel: ObservationsSpeciesViewModel
    @EnvironmentObject var settings: Settings
    
    @State private var position : MapCameraPosition = .userLocation(fallback: .automatic)
    
    var speciesID: Int
    
    var body: some View {
        VStack {
            MapReader { proxy in
                Map(position: $position) {
                    ForEach(observationsSpeciesViewModel.locations) { location in
                        Marker(location.name, systemImage: "bird.fill", coordinate: location.coordinate)
                            .tint(Color(myColor(value: location.rarity)))
                    }
                }
            }
            .mapStyle(.hybrid(elevation: .realistic))
            .mapControls() {
                MapUserLocationButton()
                MapPitchToggle()
            }
            
        }
        .onAppear {
            observationsSpeciesViewModel.fetchData(speciesId: speciesID, endDate: settings.selectedDate)
        }
    }
}

struct MapObservationSpeciesView_Previews: PreviewProvider {
    static var previews: some View {
        // Creating dummy data for preview
        let observationsSpeciesViewModel = ObservationsSpeciesViewModel()
        let settings = Settings()

        // Setting up the environment objects for the preview
        MapObservationsSpeciesView(speciesID: 62)
            .environmentObject(observationsSpeciesViewModel)
            .environmentObject(settings)
    }
}

