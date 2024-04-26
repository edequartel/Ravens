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
    @StateObject private var observationsViewModel = ObservationsViewModel()
    @StateObject private var observationsSpeciesViewModel =  ObservationsSpeciesViewModel(settings: Settings())

    
    @State private var locationId: Int?
    
    var body: some View {
        TabView {
            // Tab 1
            MapObservationView()
                .tabItem {
                    Text("Radius")
                    Image(systemName: "circle")
                }

            // Tab 2
//            if !(keyChainviewModel.token.isEmpty) {
                MapObservationsLocationView()
                    .tabItem {
                        Text("Location")
                        Image(systemName: "location")
                    }
                    .tabItem {
                        Text("Area")
                        Image(systemName: "pentagon")
                    }
//            }
            
            // Tab 2
            SpeciesView()
                .tabItem {
                    Text("Species")
                    Image(systemName: "tree")
                }
            
            // Tab 4
//            if !(keyChainviewModel.token.isEmpty) {
                MapObservationsUserView()
                    .tabItem {
                        Text("Me")
                        Image(systemName: "person.fill")
                    }
//            }

            
            // Tab 5
            SettingsView()
                .tabItem {
                    Text("Settings")
                    Image(systemName: "gearshape")
                }
        }
        .onAppear() {
            log.warning("*** NEW LAUNCH ***")
            CLLocationManager().requestWhenInUseAuthorization()
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
            .environmentObject(ObservationsViewModel())
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

//Tab 0
//            LottieView(lottieFile: "LottieFile")
//                .tabItem {
//                    Text("Lottie")
//                    Image(systemName: "globe")
//                }
//
//            Tab 0
//            AudioView()
//                .tabItem {
//                    Text("weather")
//                    Image(systemName: "globe")
//                }
//            Tab 0
//            LookUpsView()
//                .tabItem {
//                    Text("weather")
//                    Image(systemName: "globe")
//                }
//            Tab 0
//            LocationLatLongView()
//                .tabItem {
//                    Text("weather")
//                    Image(systemName: "globe")
//                }
//            Tab 0
//            POIsView()
//                .tabItem {
//                    Text("weather")
//                    Image(systemName: "globe")
//                }
            
