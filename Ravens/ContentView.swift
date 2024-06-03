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
    
    var body: some View {
        if dataLoaded {
            RavensView()
        } else {
            SplashScreen(dataLoaded: $dataLoaded)
        }
    }
}

struct RavensView: View {
    let log = SwiftyBeaver.self
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        TabView {
            // Tab 1
//            if settings.radiusPreference {
//                RadiusView()
//                    .tabItem {
//                        Text("Radius")
//                        Image(systemName: "circle")
//                    }
//            } else {
                LocationView()
                    .tabItem {
                        Text("Area")
                        Image(systemName: "pentagon")
                    }
//            }
            // Tab 2
            TabUserObservationsView()
                .tabItem {
                    Text("Us")
                    Image(systemName: "person.2.fill")
                }
            // Tab 3
            SpeciesView()
                .tabItem {
                    Text("Species")
                    Image(systemName: "tree")
                }
            // Tab 4
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
    
    @EnvironmentObject var locationManager: LocationManagerModel
    
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var languagesViewModel: LanguagesViewModel
    @EnvironmentObject var speciesViewModel: SpeciesViewModel
    @EnvironmentObject var speciesGroupViewModel: SpeciesGroupsViewModel
    @EnvironmentObject var regionsViewModel: RegionsViewModel
    @EnvironmentObject var regionListViewModel: RegionListViewModel
    @EnvironmentObject var observationsSpeciesViewModel: ObservationsSpeciesViewModel
    
    @EnvironmentObject var userViewModel: UserViewModel
    
    @EnvironmentObject var observationsUserViewModel: ObservationsUserViewModel
    @EnvironmentObject var observationsViewModel: ObservationsViewModel
    @EnvironmentObject var observationsLocationViewModel: ObservationsLocationViewModel
    @EnvironmentObject var locationIdViewModel: LocationIdViewModel
    @EnvironmentObject var geoJSONViewModel: GeoJSONViewModel
    
    @State private var isLanguageDataLoaded = false
    @State private var isFirstLanguageDataLoaded = false
    @State private var isSecondLanguageDataLoaded = false
    @State private var isSpeciesGroupDataLoaded = false
    @State private var isRegionDataLoaded = false
    @State private var isRegionListDataLoaded = false
    @State private var isObservationsSpeciesDataLoaded = false
    @State private var isUserDataLoaded = false
    @State private var isObservationsUserDataLoaded = false
    @State private var isObservationsDataLoaded = false
    @State private var isObservationsLocationDataLoaded = false
    @State private var isLocationIdDataLoaded = false
    @State private var isGeoJSONDataLoaded = false
    
    let serialQueue = DispatchQueue(label: "com.yourapp.serialQueue")
    
    var body: some View {
        VStack {
            Text("Loading data...")
        }
        .onAppear {
            log.error("*** NEW LAUNCHING SPLASHSCREEN ***")
            
            CLLocationManager().requestWhenInUseAuthorization()
            
            Task {
                do {
                    try await languagesViewModel.fetchLanguageData()
                    log.error("languagesViewModel Language data loaded")
                    isLanguageDataLoaded = true
                    checkDataLoaded()
                } catch {
                    // Handle your error here
                    log.error("Failed to load language data: \(error)")
                }
                
                do {
                    try await speciesViewModel.fetchDataFirst(
                        language: settings.selectedLanguage,
                        for: settings.selectedRegionListId)
                    log.error("speciesViewModel First language data loaded")
                    isFirstLanguageDataLoaded = true
                    checkDataLoaded()
                } catch {
                    // Handle your error here
                    log.error("Failed to load species data: \(error)")
                }
                
                do {
                    try await speciesViewModel.fetchDataSecondLanguage(
                        language: settings.selectedSecondLanguage,
                        for: settings.selectedRegionListId)
                    log.error("speciesViewModel Second language data loaded")
                    isSecondLanguageDataLoaded = true
                    checkDataLoaded()
                } catch {
                    // Handle your error here
                    log.error("Failed to load species data: \(error)")
                }
                
                
            }
                    
                    
            
            
//            speciesViewModel.fetchDataFirst(
//                language: settings.selectedLanguage,
//                for: settings.selectedRegionListId,
//                completion: {
//                    log.info("speciesViewModel First language data loaded")
//                    isFirstLanguageDataLoaded = true
//                    checkDataLoaded()
//                })
//            
//            speciesViewModel.fetchDataSecondLanguage(
//                language: settings.selectedSecondLanguage,
//                for: settings.selectedRegionListId,
//                completion: {
//                    log.info("speciesViewModel Second language data loaded")
//                    isSecondLanguageDataLoaded = true
//                    checkDataLoaded()
//                })
            
            
                    
                    speciesGroupViewModel.fetchData(
                        language: settings.selectedLanguage,
                        completion: {
                            log.info("speciesGroupViewModel group data loaded")
                            isSpeciesGroupDataLoaded = true
                            checkDataLoaded()
                        })
                    
                    regionsViewModel.fetchData(
                        language: settings.selectedLanguage,
                        completion: {
                            log.info("regionsViewModel data loaded")
                            isRegionDataLoaded = true
                            checkDataLoaded()
                        })
                    
                    regionListViewModel.fetchData(
                        language: settings.selectedLanguage,
                        completion: {
                            log.info("regionListViewModel data loaded")
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
                            log.info("observationsSpeciesViewModel data loaded")
                            isObservationsSpeciesDataLoaded = true
                            checkDataLoaded()
                        })
                    
                    userViewModel.fetchUserData(
                        completion: {
                            log.error("1. userViewModel data loaded: \(userViewModel.user?.id ?? 0)")
                            isUserDataLoaded = true
                            settings.userId = userViewModel.user?.id ?? 0
                            settings.userName = userViewModel.user?.name ?? ""
                            
                            observationsUserViewModel.fetchData(
                                language: settings.selectedLanguage,
                                userId: userViewModel.user?.id ?? 0,
                                completion: {
                                    log.error("2. userViewModel data loaded")
                                    isObservationsUserDataLoaded = true
                                    checkDataLoaded()
                                })
                        })
                    
                    if locationManager.checkLocation() {
                        let location = locationManager.getCurrentLocation()
                        //for the radius
                        observationsViewModel.fetchData(
                            lat: location?.coordinate.latitude ?? 0,
                            long: location?.coordinate.longitude ?? 0,
                            settings: settings,
                            completion: {
                                log.error("observationsViewModel data loaded")
                                isObservationsDataLoaded = true
                                checkDataLoaded()
                            })
                        
                        
                        //get the location
                        locationIdViewModel.fetchLocations(
                            latitude: location?.coordinate.latitude ?? 0,
                            longitude: location?.coordinate.longitude ?? 0,
                            completion: { fetchedLocations in
                                log.info("locationIdViewModel data loaded")
                                // Use fetchedLocations here //actually it is one location
                                settings.locationName = fetchedLocations[0].name
                                for location in fetchedLocations {
                                    log.info(location)
                                }
                                isLocationIdDataLoaded = true
                                
                                //1. get the geoJSON for this area / we pick the first one = 0
                                geoJSONViewModel.fetchGeoJsonData(
                                    for: fetchedLocations[0].id,
                                    completion:
                                        {
                                            log.info("1. geoJSONViewModel data loaded")
                                            isGeoJSONDataLoaded = true
                                            
                                            //2. get the observations for this area
                                            observationsLocationViewModel.fetchData( //settings??
                                                locationId: fetchedLocations[0].id,
                                                limit: 100,
                                                offset: 0,
                                                settings:
                                                    settings,
                                                completion: {
                                                    log.info("2. observationsLocationViewModel data loaded")
                                                    isObservationsLocationDataLoaded = true
                                                    checkDataLoaded()
                                                })
                                            
                                        }
                                )
                            })
                    }
//                }
//            }
            
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
            isUserDataLoaded &&
            isObservationsUserDataLoaded &&
            isObservationsDataLoaded &&
            isObservationsLocationDataLoaded &&
            isGeoJSONDataLoaded &&
            isLocationIdDataLoaded 
           {
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
        ContentView()
            .environmentObject(Settings())
    }
}




//    ShareTextView()
//        .tabItem {
//            Text("Records")
//            Image(systemName: "square")
//        }
//    TestMeView()
//        .tabItem {
//            Text("Records")
//            Image(systemName: "square")
//        }
//
//    FileListView()
//        .tabItem {
//            Text("Records")
//            Image(systemName: "square")
//        }
//
//    ObserversView()
//        .tabItem {
//            Text("Records")
//            Image(systemName: "square")
//        }
//    WikipediaView()
//        .tabItem {
//            Text("Radius")
//            Image(systemName: "circle")
//        }

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

//{
//    
//
//languagesViewModel.fetchLanguageData(completion: {
//    log.info("languagesViewModel Language data loaded")
//    isLanguageDataLoaded = true
//    checkDataLoaded()
//})
//
//speciesViewModel.fetchDataFirst(
//    language: settings.selectedLanguage,
//    for: settings.selectedRegionListId,
//    completion: {
//        log.info("speciesViewModel First language data loaded")
//        isFirstLanguageDataLoaded = true
//        checkDataLoaded()
//    })
//
//speciesViewModel.fetchDataSecondLanguage(
//    language: settings.selectedSecondLanguage,
//    for: settings.selectedRegionListId,
//    completion: {
//        log.info("speciesViewModel Second language data loaded")
//        isSecondLanguageDataLoaded = true
//        checkDataLoaded()
//    })
//
//speciesGroupViewModel.fetchData(
//    language: settings.selectedLanguage,
//    completion: {
//        log.info("speciesGroupViewModel group data loaded")
//        isSpeciesGroupDataLoaded = true
//        checkDataLoaded()
//    })
//
//regionsViewModel.fetchData(
//    language: settings.selectedLanguage,
//    completion: {
//        log.info("regionsViewModel data loaded")
//        isRegionDataLoaded = true
//        checkDataLoaded()
//    })
//
//regionListViewModel.fetchData(
//    language: settings.selectedLanguage,
//    completion: {
//        log.info("regionListViewModel data loaded")
//        isRegionListDataLoaded = true
//        checkDataLoaded()
//    })
//
//observationsSpeciesViewModel.fetchData(
//    language: settings.selectedLanguage,
//    speciesId: 1,
//    limit: 10,
//    offset: 0,
//    date: Date(),
//    days: 10,
//    completion: {
//        log.info("observationsSpeciesViewModel data loaded")
//        isObservationsSpeciesDataLoaded = true
//        checkDataLoaded()
//    })
//
//userViewModel.fetchUserData(
//    completion: {
//        log.error("1. userViewModel data loaded: \(userViewModel.user?.id ?? 0)")
//        isUserDataLoaded = true
//        settings.userId = userViewModel.user?.id ?? 0
//        settings.userName = userViewModel.user?.name ?? ""
//        
//        observationsUserViewModel.fetchData(
//            language: settings.selectedLanguage,
//            userId: userViewModel.user?.id ?? 0,
//            completion: {
//                log.error("2. userViewModel data loaded")
//                isObservationsUserDataLoaded = true
//                checkDataLoaded()
//            })
//    })
//
//    if locationManager.checkLocation() {
//        let location = locationManager.getCurrentLocation()
//        //for the radius
//        observationsViewModel.fetchData(
//            lat: location?.coordinate.latitude ?? 0,
//            long: location?.coordinate.longitude ?? 0,
//            settings: settings,
//            completion: {
//                log.error("observationsViewModel data loaded")
//                isObservationsDataLoaded = true
//                checkDataLoaded()
//            })
//        
//        
//        //get the location
//        locationIdViewModel.fetchLocations(
//            latitude: location?.coordinate.latitude ?? 0,
//            longitude: location?.coordinate.longitude ?? 0,
//            completion: { fetchedLocations in
//                log.info("locationIdViewModel data loaded")
//                // Use fetchedLocations here //actually it is one location
//                settings.locationName = fetchedLocations[0].name
//                for location in fetchedLocations {
//                    log.info(location)
//                }
//                isLocationIdDataLoaded = true
//                
//                //1. get the geoJSON for this area / we pick the first one = 0
//                geoJSONViewModel.fetchGeoJsonData(
//                    for: fetchedLocations[0].id,
//                    completion:
//                        {
//                            log.info("1. geoJSONViewModel data loaded")
//                            isGeoJSONDataLoaded = true
//                            
//                            //2. get the observations for this area
//                            observationsLocationViewModel.fetchData( //settings??
//                                locationId: fetchedLocations[0].id,
//                                limit: 100,
//                                offset: 0,
//                                settings:
//                                    settings,
//                                completion: {
//                                    log.info("2. observationsLocationViewModel data loaded")
//                                    isObservationsLocationDataLoaded = true
//                                    checkDataLoaded()
//                                })
//                            
//                        }
//                )
//                
//                
//            })
//    }
//}
