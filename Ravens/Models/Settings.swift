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

class Settings: ObservableObject {
    let log = SwiftyBeaver.self
    
    @AppStorage("tokenKey") var tokenKey = ""
    
    @AppStorage("savedBookmarks") private var savedBookmarks: String = ""
    @AppStorage("isBookMarksVisible") var isBookMarkVisible: Bool = false
    
    @AppStorage("selectedInBetween") var selectedInBetween: String = "waarneming.nl"
    
    @AppStorage("days") var daysStored: Int = 5
    @Published var days: Int = 5 {
        didSet {
            log.info("!!saving it in storage: \(days)")
            daysStored = days
            if !isInit {
                isRadiusChanged = true
                isAreaChanged = true
                initialSpeciesLoad = true
            }
        }
    }
    
    @AppStorage("listpreference") var listPreference: Bool = false
    
//    @AppStorage("obsSource") var obsSource: String = "waarneming.nl"
    

    @AppStorage("savePhotos") var savePhotos: Bool = false
    @AppStorage("showUser") var showUser: Bool = false
    @AppStorage("poiOn") var poiOn: Bool = true
//    @AppStorage("infinity") var infinity: Bool = true
    
    @AppStorage("selectedRarity") var selectedRarityStored = 1
    @Published var selectedRarity = 1 {
        didSet {
            log.info("!!saving selectedRarity in storage: \(selectedRarity)")
            selectedRarityStored = selectedRarity
            if !isInit { isRadiusChanged = true }
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
            log.error("!!saving isLocationIDChanged in storage: \(isLocationIDChanged)")
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
            log.error("!!initialLoadArea saving it initialLoadArea: \(initialAreaLoad)")
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
            log.error("!!radius saving it in storage: \(radius)")
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
            log.error("!!saving selectedSpeciesGroup in storage: \(selectedSpeciesGroup)")
            selectedSpeciesGroupStored = selectedSpeciesGroup
            if !isInit { isRadiusChanged = true }
        }
    }
    
    @AppStorage("selectedSpeciesGroupId") var selectedSpeciesGroupIdStored = 1
    @Published var selectedSpeciesGroupId = 1 {
        didSet {
            log.error("!!saving selectedSpeciesGroupId in storage: \(selectedSpeciesGroupId)")
            selectedSpeciesGroupIdStored = selectedSpeciesGroupId
            if !isInit { isRadiusChanged = true }
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
            if !isInit { isRadiusChanged = true }
        }
    }

    @AppStorage("selectedSecondLanguage") var selectedSecondLanguageStored = "en"
    @Published var selectedSecondLanguage: String = "en" {
        didSet {
            log.info("!!saving it in storage: \(selectedSecondLanguage)")
            selectedSecondLanguageStored = selectedSecondLanguage
            if !isInit { isRadiusChanged = true }
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
        
        //
//        isLocationIDChanged = true
//        initialAreaLoad = true
//        isAreaChanged = true
        
        
        //for updating published values
        days = daysStored
        radius = radiusStored //haal de radius op uit de storage
        isInit = false
    }
}

enum MapStyleChoice: String, CaseIterable {
    case standard = "Standard"
    case hybrid = "Hibrid"
    //case imagery = "Imagery"
}


