//
//  ContentView.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // Tab 1
            BirdView()
                .tabItem {
                    Text("Species")
                    Image(systemName: "tree.fill")
                }
            
            // Tab 2
            MapObservationView()
                .tabItem {
                    Text("Map")
                    Image(systemName: "location.fill")
                }
            
            // Tab 3
//            RegionListView()
            ObservationsView()
//            SpeciesGroupView()
                .tabItem {
                    Text("Obs")
                    Image(systemName: "binoculars.fill")
                }
//
//            
            // Tab 4
            SettingsView()
                .tabItem {
                    Text("Settings")
                    Image(systemName: "gearshape.fill")
                }
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
