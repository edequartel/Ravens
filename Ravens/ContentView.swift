//
//  ContentView.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import SwiftUI
import MapKit
import SwiftyBeaver

struct ContentView: View {
    let log = SwiftyBeaver.self
    
    @StateObject private var observationsViewModel = ObservationsViewModel()
    @StateObject private var observationsSpeciesViewModel =  ObservationsSpeciesViewModel()
    @StateObject private var loginViewModel = LoginViewModel()
    
    @State private var isViewAVisible = true
    
    @State private var isSheetObservationsViewPresented = false
    
    var body: some View {
        TabView {
            // Tab 1
            ZStack {
                MapObservationView()
                    .environmentObject(observationsViewModel)
                ObservationCircle(toggle: $isSheetObservationsViewPresented, colorHex: "f7b731")
            }
            .tabItem {
                Text("Obs")
                Image(systemName: "binoculars")
            }
            
            // Tab 2
            BirdView()
                .tabItem {
                    Text("Species")
                    Image(systemName: "tree")
                }
            
            // Tab 3
            SettingsView()
                .tabItem {
                    Text("Settings")
                    Image(systemName: "gearshape")
                }
        }

        .sheet(isPresented: $isSheetObservationsViewPresented) {
            ObservationsView(isShowing: $isSheetObservationsViewPresented)
        }
        .onAppear() {
            log.verbose("*** NEW LAUNCH ***")
            CLLocationManager().requestWhenInUseAuthorization()
        }
    }
}

//struct ContentView: View {
//    var body: some View {
//        ObservationsSpeciesView()
//        LanguageView()
//        SpeciesGroupView()
//        RegionView()
//        BirdView()
//        SpeciesDetailsView(speciesID: 2)
//        SettingsView()
//        MapObservationsSpeciesView(speciesID: 62)
//    }
//}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Creating dummy data for preview
        let observationsViewModel = ObservationsViewModel()
        let observationsSpeciesViewModel = ObservationsSpeciesViewModel()
//        let @StateObject private var logStore = LogStore()
        
        // let loginViewModel = LoginViewModel()
        let settings = Settings()
        
        // Setting up the environment objects for the preview
        ContentView()
            .environmentObject(observationsViewModel)
            .environmentObject(observationsSpeciesViewModel)
            .environmentObject(settings)
    }
}

