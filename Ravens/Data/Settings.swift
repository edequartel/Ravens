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
    @AppStorage("selectedLanguage") var selectedLanguage = "nl"
    
    @AppStorage("days") var days: Int = 5
    @AppStorage("radius") var radius: Int = 500
    
    @AppStorage("poiOn") var poiOn: Bool = true
    @AppStorage("zoomActive") var zoomActive: Bool = true
    
    @AppStorage("selectedRarity") var selectedRarity = 1
    
    @Published var currentLocation: CLLocation? = CLLocationManager().location
    @Published var selectedDate: Date = Date()
    
    @Published var isConnected: Bool = false
    
    @AppStorage("MapStyleChoice") var mapStyleChoice: MapStyleChoice = .standard
    
    init() {
        log.info("init Settings")
    }
    
    func endPoint() -> String {
       return "https://"+selectedInBetween+"/api/v1/"
    }
    
    func saveBookMarks(array: [Int]) {
            // Convert the array to a string
            let arrayString = array.map { String($0) }.joined(separator: ",")

            // Save the string to AppStorage
            savedBookmarks = arrayString
        }

    func readBookmarks(array: inout [Int]) {
            // Retrieve the string from AppStorage
            let arrayString = savedBookmarks

            // Convert the string back to an array of integers
            array = arrayString
                .components(separatedBy: ",")
                .compactMap { Int($0) }
        }
    
    var mapStyle: MapStyle {
        switch mapStyleChoice {
        case .standard:
            return .standard
        case .hybrid:
            return .hybrid(elevation: .realistic)
        case .imagery:
            return .imagery
        }
    }
    
}

enum MapStyleChoice: String, CaseIterable {
    case standard = "Standaard"
    case hybrid = "Hibride"
    case imagery = "Afbeeldingen"
}
