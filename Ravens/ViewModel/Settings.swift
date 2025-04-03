//
//  SettingsViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 09/01/2024.
//

import Foundation
import SwiftUI
import SwiftData
import MapKit
import SwiftyBeaver
import Combine

class Settings: ObservableObject {
  let log = SwiftyBeaver.self

  // radius
  @AppStorage("radius") var radiusStored = 1000
  @Published var radius: Int = 1000 {
    didSet {
      radiusStored = radius
    }
  }

  @AppStorage("timePeriodRadius") var timePeriodRadiusStored: TimePeriod = .fourWeeks
  @Published var timePeriodRadius: TimePeriod? = .twoDays {
    didSet {
      timePeriodRadiusStored = timePeriodRadius ?? .twoDays
    }
  }

  @AppStorage("timePeriodUser") var timePeriodUserStored: TimePeriod = .fourWeeks
  @Published var timePeriodUser: TimePeriod? = .twoWeeks {
    didSet {
      timePeriodUserStored = timePeriodUser ?? .twoDays
    }
  }
  
  @AppStorage("timePeriodLocation") var timePeriodLocationStored: TimePeriod = .halfYear
  @Published var timePeriodLocation: TimePeriod? = .twoWeeks {
    didSet {
      timePeriodLocationStored = timePeriodLocation ?? .fourWeeks
    }
  }
  @AppStorage("timePeriodSpeciesStored") var timePeriodSpeciesStored: TimePeriod = .twoWeeks
  @Published var timePeriodSpecies: TimePeriod? = .twoWeeks {
    didSet {
      timePeriodSpeciesStored = timePeriodSpecies ?? .twoWeeks
    }
  }

  // user are loaded
  @Published var hasUserLoaded = false
  @Published var hasLocationLoaded = false
  @Published var hasSpeciesLoaded = false

  @Published var cameraAreaPosition: MapCameraPosition = .automatic {
    didSet {
      log.info("!!cameraAreaPosition saving it in cameraPosition: \(cameraAreaPosition)")
    }
  }

  @Published var locationCoordinate: CLLocationCoordinate2D? {
    didSet {
      log.info("!!locationCoordinate saving it in locationCoordinate: \(locationCoordinate?.latitude ?? 0)")
    }
  }

  @AppStorage("isBookMarksVisible") var isBookMarkVisible: Bool = false

  @AppStorage("selectedInBetween") var selectedInBetweenStored: String = "waarneming.nl"
  @Published var selectedInBetween: String = "waarneming.nl" {
    didSet {
      log.info("!!saving it in selectedInBetween: \(selectedInBetween)")
      selectedInBetweenStored = selectedInBetween
    }
  }

  @AppStorage("mapPreference") var mapPreferenceStored = false
  @Published var mapPreference = false {
    didSet {
      log.verbose("!!saving it in storage: \(mapPreference)")
      mapPreferenceStored = mapPreference
    }
  }

  @AppStorage("MapStyleChoice") var mapStyleChoice: MapStyleChoice = .standard

  @Published var currentLocation: CLLocation? {
    didSet {
      log.info("!!currentLocation saving it in currentLocation: \(currentLocation?.coordinate.latitude ?? 0)")
    }
  }

  @Published var initialSpeciesLoad = true {
    didSet {
      log.error("!!initialSpeciesLoad saving it to speciesLoad: \(initialSpeciesLoad)")
    }
  }

  @Published var locationId: Int = 0
  @Published var locationName: String = "Unknown Location"

  @AppStorage("selectedSpeciesGroupName") var selectedSpeciesGroupNameStored: String = ""
  @Published var selectedSpeciesGroupName: String = "" {
    didSet {
      log.info("!!saving it in storage: \(selectedSpeciesGroupName)")
      selectedSpeciesGroupNameStored = selectedSpeciesGroupName
    }
  }

  @AppStorage("selectedRegionListId") var selectedRegionListIdStored = 5001
  @Published var selectedRegionListId = 1 {
    didSet {
      log.info("!!saving it in storage: \(selectedRegionListId)")
      selectedRegionListIdStored = selectedRegionListId
    }
  }

  @AppStorage("selectedSpeciesGroup") var selectedSpeciesGroupStored = 1
  @Published var selectedSpeciesGroup = 1 {
    didSet {
      log.info("!!saving selectedSpeciesGroup in storage: \(selectedSpeciesGroup)")
      selectedSpeciesGroupStored = selectedSpeciesGroup
    }
  }

  @AppStorage("selectedSpeciesGroupId") var selectedSpeciesGroupIdStored = 1
  @Published var selectedSpeciesGroupId = 1 {
    didSet {
      log.info("!!saving selectedSpeciesGroupId in storage: \(selectedSpeciesGroupId)")
      selectedSpeciesGroupIdStored = selectedSpeciesGroupId
    }
  }

  @AppStorage("selectedRegionId") var selectedRegionIdStored = 200
  @Published var selectedRegionId = 200 {
    didSet {
      log.info("!!saving it in storage: \(selectedRegionId)")
      selectedRegionIdStored = selectedRegionId
    }
  }

  @AppStorage("selectedLanguage") var selectedLanguageStored = "nl"
  @Published var selectedLanguage: String = "nl" {
    didSet {
      log.info("!!saving it in storage: \(selectedLanguage)")
      selectedLanguageStored = selectedLanguage
    }
  }

  @AppStorage("selectedSecondLanguage") var selectedSecondLanguageStored = "en"
  @Published var selectedSecondLanguage: String = "en" {
    didSet {
      log.info("!!saving it in storage: \(selectedSecondLanguage)")
      selectedSecondLanguageStored = selectedSecondLanguage
    }
  }

  var mapStyle: MapStyle {
    switch mapStyleChoice {
    case .standard:
      return .standard(elevation: .realistic)
    case .hybrid:
      return .hybrid(elevation: .realistic)
    }
  }

  var isInit: Bool = true
  init() {
    log.info("** init Settings **")
    selectedLanguage = selectedLanguageStored
    selectedSecondLanguage = selectedSecondLanguageStored

    selectedRegionListId = selectedRegionListIdStored
    selectedSpeciesGroup = selectedSpeciesGroupStored
    selectedSpeciesGroupId = selectedSpeciesGroupIdStored

    selectedSpeciesGroupName = selectedSpeciesGroupNameStored

    mapPreference = mapPreferenceStored

    selectedInBetween = selectedInBetweenStored

    isInit = false

    radius = radiusStored

    timePeriodRadius = timePeriodRadiusStored
    timePeriodUser = timePeriodUserStored
    timePeriodLocation = timePeriodLocationStored
    timePeriodSpecies = timePeriodSpeciesStored
  }
}

enum MapStyleChoice: String, CaseIterable {
  case standard
  case hybrid
  //    case imagery

  var localized: LocalizedStringKey {
    LocalizedStringKey(self.rawValue)
  }
}
