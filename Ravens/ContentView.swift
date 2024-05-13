//
//  ContentView.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import SwiftUI
import MapKit
import SwiftyBeaver
import SwiftUIPager


struct ContentView: View {
    let log = SwiftyBeaver.self
    
    var items = Array(0..<10)
    
    @EnvironmentObject var settings: Settings
    
    @StateObject private var keyChainviewModel = KeychainViewModel()
    @StateObject private var observationsViewModel = ObservationsViewModel()
    @StateObject private var observationsSpeciesViewModel =  ObservationsSpeciesViewModel(settings: Settings())

    @StateObject var page: Page = .first()
    
    @State private var locationId: Int?
    
    var body: some View {
        TabView {
            // Tab 0
//            TestMeView()
//                .tabItem {
//                    Text("Records")
//                    Image(systemName: "square")
//                }         
            
//            FileListView()
//                .tabItem {
//                    Text("Records")
//                    Image(systemName: "square")
//                }
//            
//            ObserversView()
//                .tabItem {
//                    Text("Records")
//                    Image(systemName: "square")
//                }
            
            
            // Tab 1
//            if settings.listPreference {
                MapObservationView()
                    .tabItem {
                        Text("Radius")
                        Image(systemName: "circle")
                    }
//            } else {
//                ObservationsView()
//                    .tabItem {
//                        Text("Radius")
//                        Image(systemName: "circle")
//                    }
//                
//            }

            // Tab 2
            MapObservationsLocationView()
                .tabItem {
                    Text("Location")
                    Image(systemName: "location")
                }

            
            // Tab 2
            SpeciesView()
                .tabItem {
                    Text("Species")
                    Image(systemName: "tree")
                }
            
//            Pager(page: page,
//                  data: items,
//                  id: \.self,
//                  content: { index in
//                // create a page based on the data passed
//                Text("Page: \(index)")
//            })
//            .tabItem {
//                Text("View A")
//            }
            
//             Tab 4
            if !settings.listPreference {
                MapObservationsUserView()
                    .tabItem {
                        Text("Me")
                        Image(systemName: "person.fill")
                    }
            } else {
                ObservationsUserViewExtra()
                    .tabItem {
                        Text("Me")
                        Image(systemName: "person.fill")
                    }
            }
            
            
            // Tab 5
            SettingsView()
                .tabItem {
                    Text("Settings")
                    Image(systemName: "gearshape")
                }
        }
        .onAppear() {
            log.warning("*** NEW LAUNCHING ***")
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
            .environmentObject(ObserversViewModel())
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
            
