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
  @State private var dataLoaded = false
  @EnvironmentObject var keyChainviewModel: KeychainViewModel

  init() {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = UIColor(.clear)
    appearance.shadowColor = .clear // Ensures no shadow color is applied

    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
  }

  var body: some View {
    if (keyChainviewModel.token.isEmpty) {

      VStack {
        HStack{
          Text("Login waarneming.nl")
            .bold()
            .font(.title)
            .padding()
          Spacer()
        }
        LoginView()
      }
      .onAppear() {
        log.error("isEmpty")
      }
    } else {

      if dataLoaded {
        RavensView()
          .onAppear() {
            log.info("dataLoaded")
          }
      } else {
        SplashScreen(dataLoaded: $dataLoaded)
          .onAppear() {
            log.info("SplashScreen")
          }
      }
    }
  }
}


struct RavensView: View {
  let log = SwiftyBeaver.self
  @EnvironmentObject var settings: Settings
  @State private var selectedSpeciesID: Int?

  let viewModel = RecordingsListViewModel() //later aanpassen??

  var body: some View {
    VStack {
      TabView {
        // Tab 1
        TabLocationView(selectedSpeciesID: $selectedSpeciesID)
        .tabItem {
          Text("Area")
          Image(systemName: SFAreaFill)
        }
        // Tab 2
        TabUserObservationsView(selectedSpeciesID: $selectedSpeciesID)
        .tabItem {
          Text("Us")
          Image(systemName: "person.2.fill")
        }
        // Tab 3
        TabSpeciesView(
          selectedSpeciesID: $selectedSpeciesID)
        .tabItem {
          Text("Species")
          Image(systemName: "tree")
        }
        // Tab 4
//        myImageView()
        HTMLView()
          .tabItem {
            Text("Recent")
            Image(systemName: "timer")
          }
        SettingsView()
          .tabItem {
            Text("Settings")
            Image(systemName: "gearshape")
          }
        //Tab 5
//////        CreateView()
//        PositionOnMapView(lat: 37.7749, long: -122.4194)
////        XantoView(viewModel: viewModel)
//////////        AddObservationView()
//          .tabItem {
//            Text("Add")
//            Image(systemName: "plus.circle")
//          }
      }

      .sheet(item: $selectedSpeciesID) { item in
        SpeciesDetailsView(speciesID: item)
      }
      .onAppear() {
        log.error("*** NEW LAUNCHING RAVENS ***")
      }
    }
    
  }
}


struct SplashScreen: View {
  let log = SwiftyBeaver.self

  @Binding var dataLoaded: Bool

  @EnvironmentObject var locationManagerModel: LocationManagerModel

  @EnvironmentObject var settings: Settings
  @EnvironmentObject var languagesViewModel: LanguagesViewModel
  @EnvironmentObject var speciesViewModel: SpeciesViewModel
  @EnvironmentObject var speciesGroupViewModel: SpeciesGroupsViewModel
  @EnvironmentObject var regionsViewModel: RegionsViewModel
  @EnvironmentObject var regionListViewModel: RegionListViewModel
  @EnvironmentObject var userViewModel: UserViewModel

  @State private var isLanguageDataLoaded = false
  @State private var isFirstLanguageDataLoaded = false
  @State private var isSecondLanguageDataLoaded = false
  @State private var isSpeciesGroupDataLoaded = false
  @State private var isRegionDataLoaded = false
  @State private var isRegionListDataLoaded = false
  @State private var isUserDataLoaded = false

  @State private var isObservationsLocationDataLoaded = false
  @State private var isLocationIdDataLoaded = false
  @State private var isGeoJSONDataLoaded = false
  @EnvironmentObject var observationsLocationViewModel: ObservationsLocationViewModel
  @EnvironmentObject var locationIdViewModel: LocationIdViewModel
  @EnvironmentObject var geoJSONViewModel: GeoJSONViewModel


  var body: some View {
    VStack {
      //      ProgressView()
      //            Text("Loading data...")
      //                  LottieView(lottieFile: "birds.json")
      LottieView(lottieFile: "dataloading.json")
        .frame(width: 100, height: 100)
    }
    .onAppear {
      log.info("*** NEW LAUNCHING SPLASHSCREEN ***")

      CLLocationManager().requestWhenInUseAuthorization()

      //?? deze standaard slechts 1 keer laden,
      //?? betekend ergens opslaan, todo
      languagesViewModel.fetchLanguageData(
        settings: settings,
        completion: {
          log.info("languagesViewModel Language data loaded")
          isLanguageDataLoaded = true
          checkDataLoaded()
        })

      speciesGroupViewModel.fetchData(
        settings: settings,
        completion: {
          log.info("speciesGroupViewModel group data loaded")
          isSpeciesGroupDataLoaded = true
          checkDataLoaded()
        })

      regionsViewModel.fetchData(
        settings: settings,
        completion: {
          log.info("regionsViewModel data loaded")
          isRegionDataLoaded = true
          checkDataLoaded()
        })

      regionListViewModel.fetchData(
        settings: settings,
        completion: {
          log.info("regionListViewModel data loaded")
          isRegionListDataLoaded = true
          checkDataLoaded()
        })


      speciesViewModel.fetchDataFirst(
        settings: settings,
        completion: {
          log.info("speciesViewModel First language data loaded")
          isFirstLanguageDataLoaded = true
          checkDataLoaded()
        })

      speciesViewModel.fetchDataSecondLanguage(
        settings: settings,
        completion: {
          log.info("speciesViewModel Second language data loaded")
          isSecondLanguageDataLoaded = true
          checkDataLoaded()
        })

      //iedere keer
      userViewModel.fetchUserData(
        settings: settings,
        completion: {
          log.info("1. userViewModel data loaded: \(userViewModel.user?.id ?? 0)")
          isUserDataLoaded = true
          settings.userId = userViewModel.user?.id ?? 0
          settings.userName = userViewModel.user?.name ?? ""
        })

      if locationManagerModel.checkLocation() {
        let location = locationManagerModel.getCurrentLocation()
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
          })
      }
    }
  }

  private func checkDataLoaded() {
    if isFirstLanguageDataLoaded &&
        isSecondLanguageDataLoaded &&
        isSpeciesGroupDataLoaded &&
        isLanguageDataLoaded &&
        isRegionDataLoaded &&
        isRegionListDataLoaded &&
        isUserDataLoaded &&
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



