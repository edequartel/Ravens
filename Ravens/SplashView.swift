//
//  SplashView.swift
//  Ravens
//
//  Created by Eric de Quartel on 12/11/2024.
//

import SwiftUI
import SwiftyBeaver
import BackgroundTasks
import UserNotifications
import MapKit

struct SplashView: View {
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
  @EnvironmentObject var keychainViewModel: KeychainViewModel
  @EnvironmentObject var observationsLocationViewModel: ObservationsLocationViewModel
  @EnvironmentObject var locationIdViewModel: LocationIdViewModel
  @EnvironmentObject var geoJSONViewModel: GeoJSONViewModel

  @EnvironmentObject var keyChainviewModel: KeychainViewModel

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

  var body: some View {
    VStack {
      LottieView(lottieFile: "dataloading.json")
        .frame(width: 100, height: 100)
    }


    .onChange(of: keyChainviewModel.token.isEmpty) { _ in
      log.info("--------->>token changed")
      loadData() //laadqData When token is not empty
    }

    .onAppear {
      log.info("*** NEW LAUNCHING SPLASHVIEW ***")
      CLLocationManager().requestWhenInUseAuthorization()
      loadData()
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

  private func loadData() {
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
        print("speciesViewModel First language data loaded")
        speciesViewModel.parseHTMLFromURL(settings: settings, completion: {
          print("html is parsed from start")
          isFirstLanguageDataLoaded = true
          checkDataLoaded()
        })
      })

    speciesViewModel.fetchDataSecondLanguage(
      settings: settings,
      completion: {
        log.info("speciesViewModel Second language data loaded")
        isSecondLanguageDataLoaded = true
        checkDataLoaded()
      })

    userViewModel.fetchUserData(
      settings: settings,
      completion: {
        log.info("userViewModel data loaded: \(userViewModel.user?.id ?? 0)")
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
            log.error("location \(location)")
          }
          print("locationIdViewModel data loaded")
          isLocationIdDataLoaded = true
          checkDataLoaded()
        })
    }

  }

}

struct AnotherView: View {
  @ObservedObject var viewModel: KeychainViewModel

  var body: some View {
    Text("Token: \(viewModel.token)")
  }
}
