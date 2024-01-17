//
//  ContentView.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import SwiftUI
import MapKit
struct ContentView: View {
    @StateObject private var observationsViewModel = ObservationsViewModel()
    
    var body: some View {
        TabView {
            // Tab 1
            MapObservationView()
                .environmentObject(observationsViewModel)
                .tabItem {
                    Text("Map")
                    Image(systemName: "location.fill")
                }
            
            // Tab 2
            ObservationsView()
                .environmentObject(observationsViewModel)
                .tabItem {
                    Text("Obs")
                    Image(systemName: "binoculars.fill")
                }
            
            // Tab 3
            BirdView()
                .tabItem {
                    Text("Species")
                    Image(systemName: "tree.fill")
                }
            

            // Tab 4
            SettingsView()
                .tabItem {
                    Text("Settings")
                    Image(systemName: "gearshape.fill")
                }
        }
        .onAppear() {
            CLLocationManager().requestWhenInUseAuthorization()
        }
    }
}

//struct ContentView: View {
//    var body: some View {
//        LanguageView()
//        SpeciesGroupView()
//        RegionView()
//        BirdView()
//        SpeciesDetailsView(speciesID: 2)
//        SettingsView()
//    }
//}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Creating dummy data for preview
        let observationsViewModel = ObservationsViewModel()
        let settings = Settings()

        // Setting up the environment objects for the preview
        ContentView()
            .environmentObject(observationsViewModel)
            .environmentObject(settings)
    }
}

