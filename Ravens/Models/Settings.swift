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
    
    @AppStorage("selectedSpeciesGroup") var selectedSpeciesGroup = 460
    
    @AppStorage("selectedGroup") var selectedGroup = 1
    @AppStorage("selectedGroupId") var selectedGroupId = 1
    @AppStorage("inBetween") var selectedInBetween = "waarneming.nl"
    @AppStorage("tokenKey") var tokenKey = ""
    
    @AppStorage("savedBookmarks") private var savedBookmarks: String = ""
    @AppStorage("isBookMarksVisible") var isBookMarkVisible: Bool = false
    
    @AppStorage("selectedRegion") var selectedRegion = 200

    
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
    @Published var initialLoad = true
    @Published var initialLoadLocation = true
    

    @Published var userId: Int = 0 
    @Published var userName = "unknown"
    
    @Published var locationId: Int = 0
    @Published var locationName: String = "Unknown Location"
    
    @Published var tappedCoordinate: CLLocationCoordinate2D?
    
    @AppStorage("selectedLanguage") var selectedLanguageStored = "nl"
    
    @Published var selectedLanguage: String = "nl" {
        didSet {
            selectedLanguageStored = selectedLanguage
        }
    }

    
    init() {
        log.info("** init Settings **")
    }
    
    func endPoint() -> String {
       return "https://"+selectedInBetween+"/api/v1/"
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


