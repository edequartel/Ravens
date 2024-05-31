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
    @State private var dataLoaded = false
    // Assume speciesViewModel and settings are available here

    var body: some View {
        if dataLoaded {
            // Your main content view here
            RavensView()
        } else {
            SplashScreen(dataLoaded: $dataLoaded)
        }
    }
}

struct RavensView: View {
    let log = SwiftyBeaver.self
//    
//    var items = Array(0..<10)
//    
//    @EnvironmentObject var settings: Settings
//   
////    @StateObject var locationManager = LocationManagerModel()
//    
//    @StateObject private var keyChainviewModel = KeychainViewModel()
//    @StateObject private var observationsViewModel = ObservationsViewModel()
//
//    @EnvironmentObject var observationsSpeciesViewModel: ObservationsSpeciesViewModel
//    @EnvironmentObject var userViewModel: UserViewModel
//    
//    
//    @EnvironmentObject var speciesViewModel: SpeciesViewModel //mag later worden verwijderd
////    @StateObject var page: Page = .first()
//    
//    @State private var locationId: Int?
//    
    var body: some View {
        TabView {
////            Text(speciesViewModel.speciesSecondLanguage[0].name)
////            RegionListsView()
////                .tabItem {
////                    Text("RegionLists")
////                    Image(systemName: "square")
////                }//   
////            RegionsView()
////                .tabItem {
////                    Text("Regions")
////                    Image(systemName: "square")
////                }//
////            SpeciesGroupsView()
////                .tabItem {
////                    Text("SpeciesGroups")
////                    Image(systemName: "square")
////                }//
////            WindowView()
////                .tabItem {
////                    Text("Records")
////                    Image(systemName: "square")
////                }
////            ShareTextView()
////            .tabItem {
////                Text("Records")
////                Image(systemName: "square")
////                            }
//            // Tab 0
//            //            TestMeView()
//            //                .tabItem {
//            //                    Text("Records")
//            //                    Image(systemName: "square")
//            //                }
//            
//            //            FileListView()
//            //                .tabItem {
//            //                    Text("Records")
//            //                    Image(systemName: "square")
//            //                }
//            //
//            //            ObserversView()
//            //                .tabItem {
//            //                    Text("Records")
//            //                    Image(systemName: "square")
//            //                }
//            
//            // Tab 1
////            WikipediaView()
////                .tabItem {
////                    Text("Radius")
////                    Image(systemName: "circle")
////                }
//            
//            // Tab 1
////            if settings.radiusPreference {
////                RadiusView()
////                    .tabItem {
////                        Text("Radius")
////                        Image(systemName: "circle")
////                    }
////            } else {
////                LocationView()
////                    .tabItem {
////                        Text("Area")
////                        Image(systemName: "pentagon")
////                    }
////            }
////            
//            
//            // Tab 3
////            TabUserObservationsView()
////                .tabItem {
////                    Text("Us")
////                    Image(systemName: "person.2.fill")
////                }
//
////            
////            // Tab 4
            SpeciesView()
                .tabItem {
                    Text("Species")
                    Image(systemName: "tree")
                }
//            // Tab 5
            SettingsView()
                .tabItem {
                    Text("Settings")
                    Image(systemName: "gearshape")
                }
        }
        .onAppear() {
            log.error("*** NEW LAUNCHING RAVENS ***")
        }
    }
}

struct SplashScreen: View {
    let log = SwiftyBeaver.self
    
    @Binding var dataLoaded: Bool
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var languagesViewModel: LanguagesViewModel
    @EnvironmentObject var speciesViewModel: SpeciesViewModel
    @EnvironmentObject var speciesGroupViewModel: SpeciesGroupsViewModel
    @EnvironmentObject var regionsViewModel: RegionsViewModel
    @EnvironmentObject var regionListViewModel: RegionListViewModel
    @EnvironmentObject var observationsSpeciesViewModel: ObservationsSpeciesViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    @State private var isLanguageDataLoaded = false
    @State private var isFirstLanguageDataLoaded = false
    @State private var isSecondLanguageDataLoaded = false
    @State private var isSpeciesGroupDataLoaded = false
    @State private var isRegionDataLoaded = false
    @State private var isRegionListDataLoaded = false
    @State private var isObservationsSpeciesDataLoaded = false
    @State private var isUserDataLoaded = false
    
    var body: some View {
        Text("Loading data...")
            .onAppear {
                log.error("*** NEW LAUNCHING SPLASHSCREEN ***")
                
                CLLocationManager().requestWhenInUseAuthorization()
                
                languagesViewModel.fetchLanguageData(completion: {
                    print("Language data loaded")
                    isLanguageDataLoaded = true
                    checkDataLoaded()
                })
                speciesViewModel.fetchDataFirst(
                    language: settings.selectedLanguage,
                    for: settings.selectedRegionListId,
                    completion: {
                        print("First language data loaded")
                        isFirstLanguageDataLoaded = true
                        checkDataLoaded()
                    })
                speciesViewModel.fetchDataSecondLanguage(
                    language: settings.selectedSecondLanguage,
                    for: settings.selectedRegionListId,
                    completion: {
                        print("Second language data loaded")
                        isSecondLanguageDataLoaded = true
                        checkDataLoaded()
                    })
                speciesGroupViewModel.fetchData(
                    language: settings.selectedLanguage,
                    completion: {
                        print("Species group data loaded")
                        isSpeciesGroupDataLoaded = true
                        checkDataLoaded()
                    })
                regionsViewModel.fetchData(
                    language: settings.selectedLanguage,
                    completion: {
                        print("Region data loaded")
                        isRegionDataLoaded = true
                        checkDataLoaded()
                    })
                regionListViewModel.fetchData(
                    language: settings.selectedLanguage,
                    completion: {
                        print("RegionList data loaded")
                        isRegionListDataLoaded = true
                        checkDataLoaded()
                    })
                observationsSpeciesViewModel.fetchData(
                    language: settings.selectedLanguage,
                    speciesId: 1,
                    limit: 10,
                    offset: 0,
                    date: Date(),
                    days: 10,
                    completion: {
                        print("ObservationsSpecies data loaded")
                        isObservationsSpeciesDataLoaded = true
                        checkDataLoaded()
                    })
                userViewModel.fetchUserData(
                    completion: {
                        print("User data loaded")
                        isUserDataLoaded = true
                        checkDataLoaded()
                    })

            }
    }
    
    private func checkDataLoaded() {
        if isFirstLanguageDataLoaded &&
            isSecondLanguageDataLoaded &&
            isSpeciesGroupDataLoaded &&
            isLanguageDataLoaded && 
            isRegionDataLoaded &&
            isRegionListDataLoaded &&
            isObservationsSpeciesDataLoaded &&
            isUserDataLoaded {
                self.dataLoaded = true
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
            .environmentObject(ObservationsSpeciesViewModel())
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

