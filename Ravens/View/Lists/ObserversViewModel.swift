//
//  RecordsViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/05/2024.
//

import Foundation
import SwiftyBeaver

struct Observer: Codable, Identifiable {
    var id: UUID = UUID()  // Unique identifier for SwiftUI List operations
    var name: String
    var group: String?
    var userID: Int
}

class ObserversViewModel: ObservableObject {
    let log = SwiftyBeaver.self
    
  @Published var records: [Observer] = []

  @Published var observerId: Int = 1111
  @Published var observerName: String = "deze gebruiken want deze is published"

    let filePath: URL
    
    init() {
        log.info("init ObserversViewModel")
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        filePath = documentsPath.appendingPathComponent("observers.json")
        
        // Check if the file exists
        if !fileManager.fileExists(atPath: filePath.path) {
            // If the file does not exist, create it
            fileManager.createFile(atPath: filePath.path, contents: nil, attributes: nil)
        }
        
        loadRecords()
    }
    
    func loadRecords() {
        do {
            let data = try Data(contentsOf: filePath)
            records = try JSONDecoder().decode([Observer].self, from: data)
            log.info("Loaded \(records.count) observers")
        } catch {
            log.info("Error loading data observers.json - is empty")
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
    
    func isObserverInRecords(userID: Int) -> Bool {
        return records.contains(where: { $0.userID == userID })
    }
    
    func appendRecord(name: String, userID: Int) {
        guard !records.contains(where: { $0.userID == userID }) else {
            print("Record with userID \(userID) already exists.")
            return
        }
        let newRecord = Observer(name: name.replacingOccurrences(of: "_", with: " "), userID: userID)
        records.append(newRecord)
        saveRecords()
    }
    
    func removeRecord(userID: Int) {
        if let index = records.firstIndex(where: { $0.userID == userID }) {
            records.remove(at: index)
            saveRecords()
        } else {
            print("Record with userID \(userID) does not exist.")
        }
    }
}

