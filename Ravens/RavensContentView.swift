//
//  ContentView.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import SwiftUI
import MapKit
import SwiftyBeaver

struct RavensContentView: View {
    let log = SwiftyBeaver.self
    
    @StateObject private var observationsViewModel = ObservationsViewModel(settings: Settings())
    @StateObject private var observationsSpeciesViewModel =  ObservationsSpeciesViewModel(settings: Settings())
    
    @State private var isSheetObservationsViewPresented = false
    
    var body: some View {
        TabView {
            // Tab 1
            ZStack {
                MapObservationView()
                ObservationCircle(toggle: $isSheetObservationsViewPresented, colorHex: "f7b731")
            }
            .tabItem {
                Text("Obs")
                Image(systemName: "binoculars")
            }
            
            // Tab 2 //??
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
            log.warning("*** NEW LAUNCH ***")
            CLLocationManager().requestWhenInUseAuthorization()
        }
    }
}

struct RavensContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Setting up the environment objects for the preview
        RavensContentView()
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
            
