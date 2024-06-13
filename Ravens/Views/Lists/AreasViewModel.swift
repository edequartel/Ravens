//
//  LocationViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 20/05/2024.
//

import Foundation
import MapKit
import SwiftyBeaver


struct Area: Codable, Identifiable {
    var id: UUID = UUID()  // Unique identifier for SwiftUI List operations
    var name: String
    var areaID: Int //locatiobID
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
}


import SwiftUI

class AreasViewModel: ObservableObject {
    let log = SwiftyBeaver.self
    
    @Published var records: [Area] = []
    let filePath: URL
    
    init() {
        log.info("init AreasViewModel")
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        filePath = documentsPath.appendingPathComponent("areas.json")
        
        loadRecords()
    }
    
    func loadRecords() {
        do {
            let data = try Data(contentsOf: filePath)
            records = try JSONDecoder().decode([Area].self, from: data)
            log.info("Loaded \(records.count) areas")
        } catch {
            print("Error loading data: \(error)")
        }
    }
    
    func saveRecords() {
        do {
            let data = try JSONEncoder().encode(records)
            try data.write(to: filePath, options: .atomicWrite)
        } catch {
            print("Error saving data: \(error)")
        }
    }
    
    func isIDInRecords(areaID: Int) -> Bool {
        return records.contains(where: { $0.areaID == areaID })
    }
    
    func appendRecord(areaName: String, areaID: Int, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        guard !records.contains(where: { $0.areaID == areaID }) else {
            print("Record with areaID \(areaID) already exists.")
            return
        }
        let newRecord = Area(name: areaName, areaID: areaID, latitude: latitude, longitude: longitude)
        records.append(newRecord)
        saveRecords()
    }
    
    
    func removeRecord(areaID: Int) {
        print("removeRecord \(areaID)")
        if let index = records.firstIndex(where: { $0.areaID == areaID }) {
            records.remove(at: index)
            saveRecords()
        } else {
            print("Record with areaID \(areaID) does not exist.")
        }
    }
}

import SwiftUI
import SwiftyBeaver

struct AreasView: View {
    let log = SwiftyBeaver.self
    @EnvironmentObject private var areasViewModel: AreasViewModel
    @EnvironmentObject private var settings: Settings
    
    @EnvironmentObject private var observationsLocationViewModel: ObservationsLocationViewModel
    @EnvironmentObject private var geoJSONViewModel: GeoJSONViewModel
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var newAreaID = 0
    
    var body: some View {
        VStack {
            List {
                ForEach(areasViewModel.records.sorted { $0.name < $1.name }) { record in
                    HStack{
                        Button("\(record.name) \(record.latitude)") {
                            settings.locationName = record.name
                            settings.locationId = record.areaID
                            settings.isLocationIDChanged = true
                            self.presentationMode.wrappedValue.dismiss()
                            
                        }
                        .lineLimit(1)
                        Spacer()
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button() {
                            print("Delete")
                            areasViewModel.removeRecord(areaID: record.areaID)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                    }
                }
                
            }
        }
        .onAppear {
            areasViewModel.loadRecords()
        }
    }
    
    
    
}
