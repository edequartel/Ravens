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

struct Explorer: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
}

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
    @AppStorage("savePhotos") var savePhotos: Bool = false
    @AppStorage("poiOn") var poiOn: Bool = true
    @AppStorage("infinity") var infinity: Bool = true
    @AppStorage("selectedRarity") var selectedRarity = 1
    @AppStorage("userId") var userId: Int = 0
    @AppStorage("MapStyleChoice") var mapStyleChoice: MapStyleChoice = .standard

    @AppStorage("Explorers") var explorers: Data? //changed to Data to handle jsonData

    @Published var selectedDate: Date = Date()
    @Published var isConnected: Bool = false
    @Published var isFirstAppear: Bool = true
    @Published var isFirstAppearObsView: Bool = true
    @Published var currentLocation: CLLocation? = CLLocationManager().location
    @Published var initialLoad = true
    @Published var initialLoadLocation = true
    
    @Published var locationId: Int = 0
    @Published var locationStr: String = "NoLocation"
    
    @Published var tappedCoordinate: CLLocationCoordinate2D?

    
    init() {
        log.info("init Settings")
    }
    
    func saveExplorers(array: [Explorer]) {
        // Convert the array to JSON data
        if let encodedData = try? JSONEncoder().encode(array) {
            // Save the data to AppStorage
            explorers = encodedData
        }
    }

    func readExplorers() -> [Explorer] {
        // Retrieve the data from AppStorage
        if let data = explorers,
           let array = try? JSONDecoder().decode([Explorer].self, from: data) {
            // Convert the data back to an array of Explorer
            return array
        }
        return []
    }
    
    func printExplorers() {
        if let data = explorers,
           let jsonString = String(data: data, encoding: .utf8) {
            print("JSON content of explorers: \(jsonString)")
        } else {
            print("Unable to get JSON content of explorers.")
        }
    }
    
    func removeAndSaveExplorer(id: Int) {
        // Retrieve the array of explorers from AppStorage
        var storedExplorers = readExplorers()
        
        // Filter out the explorer with the given id
        storedExplorers = storedExplorers.filter { $0.id != id }
        
        // Save the updated array to AppStorage
        saveExplorers(array: storedExplorers)
    }
    
    func explorerExists(id: Int) -> Bool {
        // Retrieve the array of explorers from AppStorage
        let storedExplorers = readExplorers()
        
        // Check if there is an explorer with the given id in the array
        for explorer in storedExplorers {
            if explorer.id == id {
                return true
            }
        }
        
        // If no explorer with the given id is found, return false
        return false
    }
    
    func addAndSaveExplorer(newExplorer: Explorer) {
        // Retrieve the array of explorers from AppStorage
        var storedExplorers = readExplorers()
        
        // Add the new explorer to the array
        storedExplorers.append(newExplorer)
        
        // Save the updated array to AppStorage
        saveExplorers(array: storedExplorers)
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
            return .standard(elevation: .realistic)
        case .hybrid:
            return .hybrid(elevation: .realistic)
        case .imagery:
            return .imagery(elevation: .realistic)
        }
    }
    
}

enum MapStyleChoice: String, CaseIterable {
    case standard = "Standard"
    case hybrid = "Hibrid"
    case imagery = "Imagery"
}


