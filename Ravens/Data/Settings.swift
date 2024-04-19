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

struct Explorer: Codable {
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
    
    @Published var currentLocation: CLLocation? = CLLocationManager().location
    @Published var selectedDate: Date = Date()
    
    @Published var isConnected: Bool = false
    
    @Published var isFirstAppear: Bool = true
    @Published var isFirstAppearObsView: Bool = true
    
    @AppStorage("userId") var userId: Int = 0
    
    @AppStorage("MapStyleChoice") var mapStyleChoice: MapStyleChoice = .standard
    
    @AppStorage("SavedExplorers") var savedExplorers: String = "" //to jsonData later
    
    @AppStorage("Explorers") var Explorers: Data? //changed to Data to handle jsonData

    init() {
        log.info("init Settings")
    }
    
    func saveTheExplorers(array: [Explorer]) {
        // Convert the array to JSON data
        if let encodedData = try? JSONEncoder().encode(array) {
            // Save the data to AppStorage
            Explorers = encodedData
        }
    }

    func readTheExplorers() -> [Explorer] {
        // Retrieve the data from AppStorage
        if let data = Explorers,
           let array = try? JSONDecoder().decode([Explorer].self, from: data) {
            // Convert the data back to an array of Explorer
            return array
        }
        return []
    }
    
    func explorerExists(id: Int) -> Bool {
        // Retrieve the array of explorers from AppStorage
        let storedExplorers = readTheExplorers()
        
        // Check if there is an explorer with the given id in the array
        for explorer in storedExplorers {
            if explorer.id == id {
                return true
            }
        }
        
        // If no explorer with the given id is found, return false
        return false
    }
    
//    let newExplorer = Explorer(id: 3, name: "Explorer 3", age: 40)
//    addAndSaveExplorer(newExplorer: newExplorer)
    
    func addAndSaveExplorer(newExplorer: Explorer) {
        // Retrieve the array of explorers from AppStorage
        var storedExplorers = readTheExplorers()
        
        // Add the new explorer to the array
        storedExplorers.append(newExplorer)
        
        // Save the updated array to AppStorage
        saveTheExplorers(array: storedExplorers)
    }
    
//    struct ExplorersPicker: View {
//        @State private var selectedExplorerId: Int = 0
//        @ObservedObject var explorers: ExplorersData
//
//        var body: some View {
//            Picker("Select Explorer", selection: $selectedExplorerId) {
//                ForEach(explorers.list, id: \.id) { explorer in
//                    Text("\(explorer.name)").tag(explorer.id)
//                }
//            }
//        }
//    }
    
    
    //
    
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
    
    func saveExplorers(array: [Int]) {
            // Convert the array to a string
            let arrayString = array.map { String($0) }.joined(separator: ",")

            // Save the string to AppStorage
            savedExplorers = arrayString
        }

    func readExplorers(array: inout [Int]) {
            // Retrieve the string from AppStorage
            let arrayString = savedExplorers

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


