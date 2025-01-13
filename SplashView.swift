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

  @EnvironmentObject var locationIdViewModel: LocationIdViewModel
  @EnvironmentObject var geoJSONViewModel: GeoJSONViewModel

  @EnvironmentObject var keyChainViewModel: KeychainViewModel

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
    .onChange(of: keyChainViewModel.token.isEmpty) { oldValue, newValue in
      log.error("**NEW TOKEN** \(newValue)")
      handleTokenChange(newValue)
    }
    .onAppear {
      log.error("*** NEW LAUNCHING SPLASHVIEW ***")
      isUserDataLoaded = true
      handleOnAppear()
    }
  }

  private func handleTokenChange(_ isTokenEmpty: Bool) {
    if !isTokenEmpty {
      log.error("Token detected, loading data")
      Task {
        log.error("SPLASHVIEW change loaddata")
        await loadData()
      }
    } else {
      log.error("Token not found, waiting for login")
    }
  }

  private func handleOnAppear() {
    log.error("**handle onAppear**")
    if !keyChainViewModel.token.isEmpty {
      log.error("SPLASHVIEW onAppear loaddata")
      Task {
        await loadData()
      }
    }
  }

  private func checkDataLoaded() {
    let allDataLoaded = isFirstLanguageDataLoaded &&
                        isSecondLanguageDataLoaded &&
                        isSpeciesGroupDataLoaded &&
                        isLanguageDataLoaded &&
                        isRegionDataLoaded &&
                        isRegionListDataLoaded &&
                        isUserDataLoaded

    if allDataLoaded {
      self.dataLoaded = true
      log.info("All required data loaded. Setting dataLoaded to true.")
    }
  }

  func loadData() async {
    await withTaskGroup(of: Void.self) { group in
      group.addTask { await loadLanguagesData() }
      group.addTask { await loadSpeciesGroupData() }
      group.addTask { await loadRegionsData() }
      group.addTask { await loadRegionListData() }
      group.addTask { await loadSpeciesFirstLanguageData() }
      group.addTask { await loadSpeciesSecondLanguageData() }
      group.addTask { await loadUserData() }
    }
  }

  private func loadLanguagesData() async {
    languagesViewModel.fetchLanguageData(settings: settings) {
      log.info("languagesViewModel Language data loaded")
      isLanguageDataLoaded = true
      checkDataLoaded()
    }
  }

  private func loadSpeciesGroupData() async {
    speciesGroupViewModel.fetchData(settings: settings) {
      log.info("speciesGroupViewModel group data loaded")
      isSpeciesGroupDataLoaded = true
      checkDataLoaded()
    }
  }

  private func loadRegionsData() async {
    regionsViewModel.fetchData(settings: settings) {
      log.info("regionsViewModel data loaded")
      isRegionDataLoaded = true
      checkDataLoaded()
    }
  }

  private func loadRegionListData() async {
    regionListViewModel.fetchData(settings: settings) {
      log.info("regionListViewModel data loaded")
      isRegionListDataLoaded = true
      checkDataLoaded()
    }
  }

  private func loadSpeciesFirstLanguageData() async {
    speciesViewModel.fetchDataFirst(settings: settings) {
      log.info("speciesViewModel First language data loaded")
      speciesViewModel.parseHTMLFromURL(settings: settings) {
        log.info("HTML parsed from start")
        isFirstLanguageDataLoaded = true
        checkDataLoaded()
      }
    }
  }

  private func loadSpeciesSecondLanguageData() async {
    speciesViewModel.fetchDataSecondLanguage(settings: settings) {
      log.info("speciesViewModel Second language data loaded")
      isSecondLanguageDataLoaded = true
      checkDataLoaded()
    }
  }

  private func loadUserData() async {
    userViewModel.fetchUserData(settings: settings, token: keyChainViewModel.token) {
      log.info("userViewModel data loaded: \(userViewModel.user?.id ?? 0)")
      isUserDataLoaded = true
      settings.userId = userViewModel.user?.id ?? 0
      settings.userName = userViewModel.user?.name ?? ""
      checkDataLoaded()
    }
  }
}

//struct AnotherView: View {
//  @ObservedObject var viewModel: KeychainViewModel
//
//  var body: some View {
//    Text("Token: \(viewModel.token)")
//  }
//}

////
////  SplashView.swift
////  Ravens
////
////  Created by Eric de Quartel on 12/11/2024.
////
//
//import SwiftUI
//import SwiftyBeaver
//import BackgroundTasks
//import UserNotifications
//import MapKit
//
//struct SplashView: View {
//  let log = SwiftyBeaver.self
//
//  @Binding var dataLoaded: Bool
//
//  @EnvironmentObject var locationManagerModel: LocationManagerModel
//  @EnvironmentObject var settings: Settings
//  @EnvironmentObject var languagesViewModel: LanguagesViewModel
//  @EnvironmentObject var speciesViewModel: SpeciesViewModel
//  @EnvironmentObject var speciesGroupViewModel: SpeciesGroupsViewModel
//  @EnvironmentObject var regionsViewModel: RegionsViewModel
//  @EnvironmentObject var regionListViewModel: RegionListViewModel
//  @EnvironmentObject var userViewModel: UserViewModel
//  @EnvironmentObject var keychainViewModel: KeychainViewModel
//  @EnvironmentObject var locationIdViewModel: LocationIdViewModel
//  @EnvironmentObject var geoJSONViewModel: GeoJSONViewModel
//
//  @EnvironmentObject var keyChainviewModel: KeychainViewModel
//
//  @State private var isLanguageDataLoaded = false
//  @State private var isFirstLanguageDataLoaded = false
//  @State private var isSecondLanguageDataLoaded = false
//  @State private var isSpeciesGroupDataLoaded = false
//  @State private var isRegionDataLoaded = false
//  @State private var isRegionListDataLoaded = false
//  @State private var isUserDataLoaded = false
//  @State private var isObservationsLocationDataLoaded = false
//  @State private var isGeoJSONDataLoaded = false
//
//  var body: some View {
//    VStack {
//      Text("Ravens")
//          .font(.system(size: 48))
//          .foregroundColor(.gray)
//          .bold()
//
//      LottieView(lottieFile: "ravenssun.json")
//        .frame(width: 150, height: 150)
//    }
//
//    .onChange(of: keyChainviewModel.token.isEmpty) { oldValue, newValue in
//        if !newValue { // `newValue` is false when the token is not empty
//            log.error("Token detected, loading data")
////            loadData()
//          Task {
//            log.error("SPLASHVIEW change loaddata")
//            await loadData()
//          }
//        } else {
//            log.error("Token not found, waiting for login")
//        }
//    }
//
//    .onAppear {
//      log.error("*** NEW LAUNCHING SPLASHVIEW ***")
//
//      if !keyChainviewModel.token.isEmpty {
//        log.error("SPLASHVIEW onAppear loaddata")
//        Task {
//          await loadData()
//        }
//      }
//    }
//  }
//
//  private func checkDataLoaded() {
//    if isFirstLanguageDataLoaded &&
//        isSecondLanguageDataLoaded &&
//        isSpeciesGroupDataLoaded &&
//        isLanguageDataLoaded &&
//        isRegionDataLoaded &&
//        isRegionListDataLoaded //&&
//        && isUserDataLoaded
//    {
//      self.dataLoaded = true
//    }
//  }
//
//  func loadData() async {
//    languagesViewModel.fetchLanguageData(
//      settings: settings,
//      completion: {
//        log.info("languagesViewModel Language data loaded")
//        isLanguageDataLoaded = true
//        checkDataLoaded()
//      })
//
//    speciesGroupViewModel.fetchData(
//      settings: settings,
//      completion: {
//        log.info("speciesGroupViewModel group data loaded")
//        isSpeciesGroupDataLoaded = true
//        checkDataLoaded()
//      })
//
//    regionsViewModel.fetchData(
//      settings: settings,
//      completion: {
//        log.info("regionsViewModel data loaded")
//        isRegionDataLoaded = true
//        checkDataLoaded()
//      })
//
//
//    regionListViewModel.fetchData(
//      settings: settings,
//      completion: {
//        log.info("regionListViewModel data loaded")
//        isRegionListDataLoaded = true
//        checkDataLoaded()
//      })
//
//    speciesViewModel.fetchDataFirst(
//      settings: settings,
//      completion: {
//        log.info("speciesViewModel First language data loaded")
//        speciesViewModel.parseHTMLFromURL(settings: settings, completion: {
//          log.error("html is parsed from start")
//          isFirstLanguageDataLoaded = true
//          checkDataLoaded()
//        })
//      })
//
//    speciesViewModel.fetchDataSecondLanguage(
//      settings: settings,
//      completion: {
//        log.info("speciesViewModel Second language data loaded")
//        isSecondLanguageDataLoaded = true
//        checkDataLoaded()
//      })
//
//    userViewModel.fetchUserData(
//      settings: settings,
//      completion: {
//        log.info("userViewModel data loaded: \(userViewModel.user?.id ?? 0)")
//        isUserDataLoaded = true
//        settings.userId = userViewModel.user?.id ?? 0
//        settings.userName = userViewModel.user?.name ?? ""
//        checkDataLoaded()
//      })
//  }
//}
//
//
//struct AnotherView: View {
//  @ObservedObject var viewModel: KeychainViewModel
//
//  var body: some View {
//    Text("Token: \(viewModel.token)")
//  }
//}
