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
  @State private var isGeoJSONDataLoaded = false

  var body: some View {
    VStack {
      Text("Ravens")
          .font(.system(size: 48))
          .foregroundColor(.gray)
          .bold()


      LottieView(lottieFile: "ravenssun.json")
        .frame(width: 150, height: 150)
    }

    .onChange(of: keyChainviewModel.token.isEmpty) { oldValue, newValue in
        if !newValue { // `newValue` is false when the token is not empty
            log.error("Token detected, loading data")
            loadData()
        } else {
            log.error("Token not found, waiting for login")
        }
    }

    .onAppear {
      log.error("*** NEW LAUNCHING SPLASHVIEW ***")

      if !keyChainviewModel.token.isEmpty {
        loadData()
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
        isUserDataLoaded 
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
        log.info("speciesViewModel First language data loaded")
        speciesViewModel.parseHTMLFromURL(settings: settings, completion: {
          log.error("html is parsed from start")
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
  }
}


struct AnotherView: View {
  @ObservedObject var viewModel: KeychainViewModel

  var body: some View {
    Text("Token: \(viewModel.token)")
  }
}
