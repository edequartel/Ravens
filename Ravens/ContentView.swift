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
                    Text("map".localized())
                    Image(systemName: "location.fill")
                }
            
            // Tab 2
            ObservationsView()
                .environmentObject(observationsViewModel)
                .tabItem {
                    Text("obs".localized())
                    Image(systemName: "binoculars.fill")
                }
            
            // Tab 3
            BirdView()
                .tabItem {
                    Text("species".localized())
                    Image(systemName: "tree.fill")
                }
            

            // Tab 4
            SettingsView()
                .tabItem {
                    Text("settings".localized())
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

#Preview {
    ContentView()
}
