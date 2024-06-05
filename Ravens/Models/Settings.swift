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
    
    @AppStorage("days") var days: Int = 5
    @AppStorage("listpreference") var listPreference: Bool = false
    @AppStorage("radius") var radius: Int = 500
    @AppStorage("savePhotos") var savePhotos: Bool = false
    @AppStorage("showUser") var showUser: Bool = false
    @AppStorage("poiOn") var poiOn: Bool = true
    @AppStorage("infinity") var infinity: Bool = true
    @AppStorage("selectedRarity") var selectedRarity = 1

    @AppStorage("radiusPreference") var radiusPreference = true
    
    
    @AppStorage("MapStyleChoice") var mapStyleChoice: MapStyleChoice = .standard

    @AppStorage("Explorers") var explorers: Data? //changed to Data to handle jsonData

    @Published var selectedDate: Date = Date()
    @Published var isConnected: Bool = false
    @Published var isFirstAppear: Bool = true
    @Published var isFirstAppearObsView: Bool = true
    @Published var currentLocation: CLLocation? = CLLocationManager().location
//    @Published var initialLoad = true
    @Published var initialLoadLocation = true
    

    @Published var userId: Int = 0 
    @Published var userName = "unknown"
    
    @Published var locationId: Int = 0
    @Published var locationName: String = "Unknown Location"
    
    @Published var tappedCoordinate: CLLocationCoordinate2D?
    
    
    init() {
        log.error("** init Settings **")
        selectedLanguage = selectedLanguageStored
        selectedSecondLanguage = selectedSecondLanguageStored
        
        selectedRegionListId = selectedRegionListIdStored
        selectedSpeciesGroup = selectedSpeciesGroupStored 
        selectedSpeciesGroupId = selectedSpeciesGroupIdStored
        
        selectedSpeciesGroupName = selectedSpeciesGroupNameStored        
    }
    
    @AppStorage("selectedSpeciesGroupName") var selectedSpeciesGroupNameStored: String = ""
    @Published var selectedSpeciesGroupName: String = "" {
        didSet {
            log.verbose("!!saving it in storage: \(selectedSpeciesGroupName)")
            selectedSpeciesGroupNameStored = selectedSpeciesGroupName
        }
    }
    
    
    @AppStorage("selectedRegionListId") var selectedRegionListIdStored = 5001
    @Published var selectedRegionListId = 1 {
        didSet {
            log.verbose("!!saving it in storage: \(selectedRegionListId)")
            selectedRegionListIdStored = selectedRegionListId
        }
    }
    
    @AppStorage("selectedSpeciesGroup") var selectedSpeciesGroupStored = 1
    @Published var selectedSpeciesGroup = 1 {
        didSet {
            log.verbose("!!saving it in storage: \(selectedSpeciesGroup)")
            selectedSpeciesGroupStored = selectedSpeciesGroupId
        }
    }
    
    @AppStorage("selectedSpeciesGroupId") var selectedSpeciesGroupIdStored = 1
    @Published var selectedSpeciesGroupId = 1 {
        didSet {
            log.verbose("!!saving it in storage: \(selectedSpeciesGroupId)")
            selectedSpeciesGroupIdStored = selectedSpeciesGroupId
        }
    }
    
    @AppStorage("selectedRegionId") var selectedRegionIdStored = 200
    @Published var selectedRegionId = 200 {
        didSet {
            log.verbose("!!saving it in storage: \(selectedRegionId)")
            selectedRegionIdStored = selectedRegionId
        }
    }
    
    @AppStorage("selectedLanguage") var selectedLanguageStored = "nl"
    @Published var selectedLanguage: String = "nl" {
        didSet {
            log.verbose("!!saving it in storage: \(selectedLanguage)")
            selectedLanguageStored = selectedLanguage
        }
    }

    @AppStorage("selectedSecondLanguage") var selectedSecondLanguageStored = "en"
    @Published var selectedSecondLanguage: String = "en" {
        didSet {
            log.verbose("!!saving it in storage: \(selectedSecondLanguage)")
            selectedSecondLanguageStored = selectedSecondLanguage
        }
    }
    
    var mapStyle: MapStyle {
        switch mapStyleChoice {
        case .standard:
            return .standard(elevation: .realistic)
        case .hybrid:
            return .hybrid(elevation: .realistic)
//        case .imagery:
//            return .imagery(elevation: .realistic)
        }
    }
    
}

enum MapStyleChoice: String, CaseIterable {
    case standard = "Standard"
    case hybrid = "Hibrid"
    //case imagery = "Imagery"
}


