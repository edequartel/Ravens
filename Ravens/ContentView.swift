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
    @State private var isSheetObservationsLocationsViewPresented = false
    
    @State private var locationId: Int?
    
    var body: some View {
        TabView {
            // Tab 0
//            LottieView(lottieFile: "LottieFile")
//                .tabItem {
//                    Text("Lottie")
//                    Image(systemName: "globe")
//                }

            // Tab 0
//            AudioView()
//            .tabItem {
//                Text("weather")
//                Image(systemName: "globe")
//            }
            // Tab 0
//            LookUpsView()
//            .tabItem {
//                Text("weather")
//                Image(systemName: "globe")
//            }
//                         Tab 0
//            LocationLatLongView()
//            .tabItem {
//                Text("weather")
//                Image(systemName: "globe")
//            }
//                         Tab 0
//            POIsView()
//            .tabItem {
//                Text("weather")
//                Image(systemName: "globe")
//            }
            
            // Tab 1
            ZStack {
                MapObservationView()
                ObservationCircle(toggle: $isSheetObservationsViewPresented, colorHex: "f7b731")
            }
            .tabItem {
                Text("Radius")
                Image(systemName: "circle")
            }
            
            // Tab 2
            ZStack {
                MapObservationsLocationView(sharedLocationId: Binding<Int>(get: { self.locationId ?? 0 }, set: { self.locationId = $0 }))
                ObservationCircle(toggle: $isSheetObservationsLocationsViewPresented, colorHex: "a7b731")
            }
            .tabItem {
                Text("Area")
                Image(systemName: "pentagon")
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
                    Text("We")
                    Image(systemName: "person.2.fill")
                }
            
//            // Tab 4
//            EmptyView()
//                .tabItem {
//                    Text("Explorers")
//                    Image(systemName: "person.2.fill")
//                }
            
            // Tab 5
            SettingsView()
                .tabItem {
                    Text("Settings")
                    Image(systemName: "gearshape")
                }
        }

        .sheet(isPresented: $isSheetObservationsViewPresented) {
            ObservationsView(isShowing: $isSheetObservationsViewPresented)
        }
        .sheet(isPresented: $isSheetObservationsLocationsViewPresented) {
            ObservationsLocationView(
                    locationId: Binding<Int>(get: { self.locationId ?? 0 }, set: { self.locationId = $0 }),
//                    locationStr: <#T##Binding<String>#>(get: { self.locationId ?? 0 }, set: { self.locationId = $0 }),
                    isShowing: $isSheetObservationsLocationsViewPresented)
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
            
