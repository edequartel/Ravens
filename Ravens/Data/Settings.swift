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
    

    
    @AppStorage("selectedRegion") var selectedRegion = 200
    @AppStorage("selectedLanguage") var selectedLanguage = "nl"
    
    @AppStorage("days") var days: Int = 5
    @AppStorage("radius") var radius: Int = 500
    
    @AppStorage("poiOn") var poiOn: Bool = true
    @AppStorage("selectedRarity") var selectedRarity = 1
    
    @Published var currentLocation: CLLocation? = CLLocationManager().location
    @Published var selectedDate: Date = Date()
    
    init() {
        log.info("init Settings")
    }
    
    func endPoint() -> String {
       return "https://"+selectedInBetween+"/api/v1/"
    }
}

//@Model 
class NoUserData {
//    var bookMarks: [Int] = []
    var name : String
    
    init(name: String = "") {
        self.name = name
    }
}

