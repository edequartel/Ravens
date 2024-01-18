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
    @StateObject private var observationsSpeciesViewModel =  ObservationsSpeciesViewModel()
    @StateObject private var loginViewModel = LoginViewModel()
    
    var body: some View {
        TabView {
            // Tab 1
//            LoginView(loginViewModel: loginViewModel)
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
            

//            // Tab 3
//            ObservationsSpeciesView(speciesID: 306)
//                .environmentObject(observationsSpeciesViewModel)
//                .tabItem {
//                    Text("Species")
//                    Image(systemName: "tree.fill")
//                }
            


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
//        ObservationsSpeciesView()
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
        let observationsSpeciesViewModel = ObservationsSpeciesViewModel()
        
//        let loginViewModel = LoginViewModel()
        let settings = Settings()

        // Setting up the environment objects for the preview
        ContentView()
            .environmentObject(observationsViewModel)
            .environmentObject(observationsSpeciesViewModel)
            .environmentObject(settings)
    }
}

