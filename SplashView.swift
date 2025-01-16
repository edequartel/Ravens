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

  @EnvironmentObject var obsObserversViewModel: ObserversViewModel
  @EnvironmentObject var observationUser : ObservationsViewModel

  @State private var isLanguageDataLoaded = false
  @State private var isFirstLanguageDataLoaded = false
  @State private var isSecondLanguageDataLoaded = false
  @State private var isSpeciesGroupDataLoaded = false
  @State private var isRegionDataLoaded = false
  @State private var isRegionListDataLoaded = false
  @State private var isUserDataLoaded = false
  @State private var isObservationsLocationDataLoaded = false
  @State private var isGeoJSONDataLoaded = false
  @State private var isObservationLoaded = false

  var body: some View {
    VStack {
      Text("Ravens")
        .font(.system(size: 48))
        .foregroundColor(.gray)
        .bold()

      LottieView(lottieFile: "ravenssun.json")
        .frame(width: 150, height: 150)
    }
    .onAppear {
      log.error("*** NEW LAUNCHING SPLASHVIEW ***")
      handleOnAppear()
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
      log.error("userViewModel data loaded: \(userViewModel.user?.id ?? 0)")
      obsObserversViewModel.observerName = userViewModel.user?.name ?? ""
      obsObserversViewModel.observerId = userViewModel.user?.id ?? 0

      observationUser.fetchDataInit(
        settings: settings,
        entity: .user,
        token: keyChainViewModel.token,
        id: obsObserversViewModel.observerId,
        completion: {
          log.error("fetch observationUser.fetchDataInit complete")
          isUserDataLoaded = true
          checkDataLoaded()
        }
      )
    }
  }




}


//log.error("-update refresh")
//
//observationUser.fetchDataInit(
//  settings: settings,
//  entity: .user,
//  token: keyChainviewModel.token,
//  id: observerId,
//  completion: { log.info("fetch data complete") } )
