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

//class AccessibilitySettings: ObservableObject {
//    @Published var isVoiceOverEnabled: Bool = false
//    private var cancellable: AnyCancellable?
//
//    init() {
//        self.cancellable = NotificationCenter.default.publisher(for: UIAccessibility.voiceOverStatusDidChangeNotification)
//            .sink { [weak self] _ in
//                self?.isVoiceOverEnabled = UIAccessibility.isVoiceOverRunning
//            }
//        self.isVoiceOverEnabled = UIAccessibility.isVoiceOverRunning
//    }
//}

class Settings: ObservableObject {
    let log = SwiftyBeaver.self
    
//    @AppStorage("showObsPictures") var showObsPictures: Bool = false
//    @AppStorage("showObsAudio") var showObsAudio: Bool = true
    @AppStorage("hidePictures") var hidePictures: Bool = false

    
    @Published var cameraRadiusPosition: MapCameraPosition = .automatic {
        didSet {
            log.info("!!cameraRadiusPosition saving it in cameraPosition: \(cameraRadiusPosition)")
        }
    }
    
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
//    @AppStorage("isLatestVisible") var isLatestVisible: Bool = false
    
    @AppStorage("selectedInBetween") var selectedInBetweenStored: String = "waarneming.nl"
    @Published var selectedInBetween: String = "waarneming.nl" {
        didSet {
            log.info("!!saving it in selectedInBetween: \(selectedInBetween)")
            selectedInBetweenStored = selectedInBetween
        }
    }
    
    
    @AppStorage("accessibility") var accessibilityStored: Bool = false
    @Published var accessibility: Bool = false {
        didSet {
            log.info("!!saving it in storage: \(accessibility)")
            accessibilityStored = accessibility
        }
    }
    
    
//    @AppStorage("days") var daysStored: Int = 5
//    @Published var days: Int = 5 {
//        didSet {
//            log.info("!!saving it in storage: \(days)")
//            daysStored = days
//            if !isInit {
//                isRadiusChanged = true
//                isAreaChanged = true
//                initialSpeciesLoad = true
//            }
//        }
//    }
    
    @AppStorage("listpreference") var listPreference: Bool = false
    
//    @AppStorage("obsSource") var obsSource: String = "waarneming.nl"
    

//    @AppStorage("savePhotos") var savePhotos: Bool = false
    @AppStorage("showUser") var showUser: Bool = false
    @AppStorage("poiOn") var poiOn: Bool = true
    @AppStorage("infinity") var infinity: Bool = false
    
    @AppStorage("selectedRarity") var selectedRarityStored = 1
    @Published var selectedRarity = 1 {
        didSet {
            log.info("!!saving selectedRarity in storage: \(selectedRarity)")
            selectedRarityStored = selectedRarity
            if !isInit {
                isRadiusChanged = true
            }
        }
    }
    
    
    
    @AppStorage("radiusPreference") var radiusPreference = true
    
    @AppStorage("mapPreference") var mapPreferenceStored = false //VIP
    @Published var mapPreference = false {
        didSet {
            log.verbose("!!saving it in storage: \(mapPreference)")
            mapPreferenceStored = mapPreference
        }
    }
    
    
    @AppStorage("MapStyleChoice") var mapStyleChoice: MapStyleChoice = .standard

    @AppStorage("Explorers") var explorers: Data? //changed to Data to handle jsonData

    @Published var selectedDate: Date = Date() {
        didSet {
            log.info("!!saving selectedDate it in storage: \(selectedDate)")
            if !isInit {
                isRadiusChanged = true
                isAreaChanged = true
                initialSpeciesLoad = true
            }
        }
    }
    
    @AppStorage("isLocationIDChanged") var isLocationIDChangedStored: Bool = false
    @Published var isLocationIDChanged: Bool = false {
        didSet {
            log.info("!!saving isLocationIDChanged in storage: \(isLocationIDChanged)")
            isLocationIDChangedStored = isLocationIDChanged
        }
    }
    
    @Published var isConnected: Bool = false
    @Published var isFirstAppear: Bool = true
    @Published var isFirstAppearObsView: Bool = true
    
    @Published var currentLocation: CLLocation? = nil //CLLocationManager().location
    {
        didSet {
            log.info("!!currentLocation saving it in currentLocation: \(currentLocation?.coordinate.latitude ?? 0)")
        }
    }
    
    
    @Published var initialRadiusLoad = true {
        didSet {
            log.info("!!initialRadiusLoad saving it initialRadiusLoad: \(initialRadiusLoad)")
        }
    }
    
    @Published var isRadiusChanged = false {
        didSet {
            log.info("!!isRadiusChanged saving it radiusChanged: \(isRadiusChanged)")
        }
    }
    
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
    
    
    @AppStorage("radius") var radiusStored: Int = 500 //init op 500m
    @Published var radius: Int = 500 {
        didSet {
            log.info("!!radius saving it in storage: \(radius)")
            radiusStored = radius
            if !isInit { isRadiusChanged = true }
        }
    }
    
    
    @Published var initialUsersLoad = true
    @Published var initialLoadLocation = true

    

    @Published var userId: Int = 0
    @Published var userName = "unknown"
    
    @Published var locationId: Int = 0
    @Published var locationName: String = "Unknown Location"
    
    @Published var tappedCoordinate: CLLocationCoordinate2D?
    
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
                isRadiusChanged = true
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
                isRadiusChanged = true
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
                isRadiusChanged = true
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
                isRadiusChanged = true
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
    
    @Published var circlePos: CLLocationCoordinate2D? = nil {
        didSet {
            log.info("!!circlePos saving it in circlePos: \(circlePos?.latitude ?? 0)")
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
        accessibility = accessibilityStored
        
        //for updating published values
//        days = daysStored
        radius = radiusStored //haal de radius op uit de storage
        isInit = false
    }
}

enum MapStyleChoice: String, CaseIterable {
    case standard = "Standard"
    case hybrid = "Hibrid"
    //case imagery = "Imagery"
}


