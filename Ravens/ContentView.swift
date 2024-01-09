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
//            MapObservationView()
//                .tabItem {
//                    Text("Map")
//                    Image(systemName: "location.fill")
//                }
            
            // Tab 3a
            SpeciesGroupView()
                .tabItem {
                    Text("SpeciesGroups")
                    Image(systemName: "binoculars.fill")
                }
            
            // Tab 3b
            RegionListView()
                .tabItem {
                    Text("RegionLists")
                    Image(systemName: "binoculars.fill")
                }
            
            // Tab 3c
            RegionsView()
                .tabItem {
                    Text("Region")
                    Image(systemName: "binoculars.fill")
                }
            
            
            // Tab 3
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
//    }
//}

#Preview {
    ContentView()
}
