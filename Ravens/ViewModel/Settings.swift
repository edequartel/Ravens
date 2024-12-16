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
  
    @AppStorage("hasLoadedObservationsUserView") var hasUserLoaded = false
    @AppStorage("hasLoadedObservationsLocationView") var hasLocationLoaded = false
    @AppStorage("hasLoadedObservationsSpeciesView") var hasSpeciesLoaded = false

    @Published var cameraAreaPosition: MapCameraPosition = .automatic {
        didSet {
            log.info("!!cameraAreaPosition saving it in cameraPosition: \(cameraAreaPosition)")
        }
    }
    
    @Published var locationCoordinate: CLLocationCoordinate2D? = nil {
        didSet {
            log.info("!!locationCoordinate saving it in locationCoordinate: \(locationCoordinate?.latitude ?? 0)")
        }
    }
    
    @AppStorage("tokenKey") var tokenKey = ""
    
    @AppStorage("savedBookmarks") private var savedBookmarks: String = ""
    @AppStorage("isBookMarksVisible") var isBookMarkVisible: Bool = false
    
    @AppStorage("selectedInBetween") var selectedInBetweenStored: String = "waarneming.nl"
    @Published var selectedInBetween: String = "waarneming.nl" {
        didSet {
            log.info("!!saving it in selectedInBetween: \(selectedInBetween)")
            selectedInBetweenStored = selectedInBetween
        }
    }
    
    @AppStorage("selectedRarity") var selectedRarityStored = 1
    @Published var selectedRarity = 1 {
        didSet {
            log.info("!!saving selectedRarity in storage: \(selectedRarity)")
            selectedRarityStored = selectedRarity
//            if !isInit {
//                isRadiusChanged = true
//            }
        }
    }
    
    @AppStorage("mapPreference") var mapPreferenceStored = false //VIP
    @Published var mapPreference = false {
        didSet {
            log.verbose("!!saving it in storage: \(mapPreference)")
            mapPreferenceStored = mapPreference
        }
    }
    
    
    @AppStorage("MapStyleChoice") var mapStyleChoice: MapStyleChoice = .standard


//    @AppStorage("isLocationIDChanged") var isLocationIDChangedStored: Bool = false
//    @Published var isLocationIDChanged: Bool = false {
//        didSet {
//            log.info("!!saving isLocationIDChanged in storage: \(isLocationIDChanged)")
//            isLocationIDChangedStored = isLocationIDChanged
//        }
//    }

    @Published var currentLocation: CLLocation? = nil //CLLocationManager().location
    {
        didSet {
            log.info("!!currentLocation saving it in currentLocation: \(currentLocation?.coordinate.latitude ?? 0)")
        }
    }
    
    
//    @Published var isRadiusChanged = false {
//        didSet {
//            log.info("!!isRadiusChanged saving it radiusChanged: \(isRadiusChanged)")
//        }
//    }
    
    @Published var initialAreaLoad = true {
        didSet {
            log.info("!!initialLoadArea saving it initialLoadArea: \(initialAreaLoad)")
        }
    }
    
    @Published var isAreaChanged = false {
        didSet {
            log.error("!!isAreaChanged saving it areaChanged: \(isAreaChanged)")
        }
    }
    
    @Published var initialSpeciesLoad = true {
        didSet {
            log.error("!!initialSpeciesLoad saving it to speciesLoad: \(initialSpeciesLoad)")
        }
    }

    @Published var userId: Int = 0
    @Published var userName = "unknown"
    
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
            if !isInit {
//                isRadiusChanged = true
                isAreaChanged = true
            }
        }
    }
    
    @AppStorage("selectedSpeciesGroupId") var selectedSpeciesGroupIdStored = 1
    @Published var selectedSpeciesGroupId = 1 {
        didSet {
            log.info("!!saving selectedSpeciesGroupId in storage: \(selectedSpeciesGroupId)")
            selectedSpeciesGroupIdStored = selectedSpeciesGroupId
            if !isInit {
//                isRadiusChanged = true
                isAreaChanged = true
            }
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
            if !isInit {
//                isRadiusChanged = true
                isAreaChanged = true
            }
        }
    }

    @AppStorage("selectedSecondLanguage") var selectedSecondLanguageStored = "en"
    @Published var selectedSecondLanguage: String = "en" {
        didSet {
            log.info("!!saving it in storage: \(selectedSecondLanguage)")
            selectedSecondLanguageStored = selectedSecondLanguage
            if !isInit {
//                isRadiusChanged = true
                isAreaChanged = true
            }
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
        selectedRarity = selectedRarityStored
        selectedInBetween = selectedInBetweenStored

        isInit = false

        hasUserLoaded = false
        hasLocationLoaded = false
        hasSpeciesLoaded = false
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


