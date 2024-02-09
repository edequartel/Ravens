//
//  SettingsViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 09/01/2024.
//

import Foundation
import SwiftUI
import MapKit

class Settings: ObservableObject {
    @AppStorage("selectedSpeciesGroup") var selectedSpeciesGroup = 460
    
    @AppStorage("selectedGroup") var selectedGroup = 1
    @AppStorage("selectedGroupId") var selectedGroupId = 1
//    @AppStorage("selectedGroupString") var selectedGroupString = "unknown"
    
    @AppStorage("selectedRegion") var selectedRegion = 200
    @AppStorage("selectedLanguage") var selectedLanguage = "nl"
    
    @AppStorage("days") var days: Int = 5
    @AppStorage("radius") var radius: Int = 500
    
    @AppStorage("poiOn") var poiOn: Bool = true
    @AppStorage("selectedRarity") var selectedRarity = 1
    
    @Published var currentLocation: CLLocation? = CLLocationManager().location
    @Published var selectedDate: Date = Date()
}


