//
//  SettingsViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 09/01/2024.
//

import Foundation
import SwiftUI
import MapKit

let longitude = 5.243376
let latitude = 52.023861

class Settings: ObservableObject {
    @AppStorage("selectedSpeciesGroup") var selectedSpeciesGroup = 460
    @AppStorage("selectedRegion") var selectedRegion = 20
    @AppStorage("selectedGroup") var selectedGroup = 1
    @AppStorage("selectedGroupId") var selectedGroupId = 1
    @AppStorage("selectedGroupString") var selectedGroupString = "unknown"
    
    @AppStorage("days") var days: Int = 5
    @AppStorage("radius") var radius: Int = 500
    
    @AppStorage("poiOn") var poiOn: Bool = true
    
    @Published var currentLocation: CLLocation? = CLLocationManager().location
    
    @Published var selectedDate: Date = Date()
}
