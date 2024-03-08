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
    
    
    @StateObject private var keyChainviewModel = KeychainViewModel()
    @StateObject private var observationsViewModel = ObservationsViewModel(settings: Settings())
    @StateObject private var observationsSpeciesViewModel =  ObservationsSpeciesViewModel(settings: Settings())
    
    @State private var isSheetObservationsViewPresented = false
    
    var body: some View {
        TabView {
            // Tab 0
            WeatherView()
            .tabItem {
                Text("Globe")
                Image(systemName: "Globe")
            }
            // Tab 1
            ZStack {
                MapObservationView()
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
            MapObservationsUserView()
                .tabItem {
                    Text("Me")
                    Image(systemName: "person")
                }
            
            // Tab 4
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
            log.warning("*** NEW LAUNCH ***")
            CLLocationManager().requestWhenInUseAuthorization()
//            keyChainviewModel.retrieveCredentials()
//            log.error("Token from keychain \(keyChainviewModel.token)")
        }
    }
}

struct AnotherView: View {
    @ObservedObject var viewModel: KeychainViewModel

    var body: some View {
        Text("Token: \(viewModel.token)")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Setting up the environment objects for the preview
        ContentView()
            .environmentObject(KeychainViewModel())
            .environmentObject(ObservationsViewModel(settings: Settings()))
            .environmentObject(ObservationsSpeciesViewModel(settings: Settings()))
            .environmentObject(Settings())
    }
}

//            RegionListView()
//                .tabItem {
//                    Text("Species")
//                    Image(systemName: "tree")
//                }
////
//            SpeciesGroupView()
////                LoginView(loginViewModel: loginViewModel)
//                    .tabItem {
//                        Text("Species")
//                        Image(systemName: "tree")
//                    }
//
//            LanguageView()
//                .tabItem {
//                    Text("Language")
//                    Image(systemName: "book")
//                }
//            ObsView(obsID: 123629598)
//                .tabItem {
//                    Text("Book")
//                    Image(systemName: "book")
//                }
//            ObsView(obsID: 123629598)
//            LookUpsView()
//                .tabItem {
//                    Text("Book")
//                    Image(systemName: "book")
//                }
            
//            PassportView()
//                .tabItem {
//                    Text("Book")
//                    Image(systemName: "book")
//                }
            
