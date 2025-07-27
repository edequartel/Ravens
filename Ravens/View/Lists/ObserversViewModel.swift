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
  
  @Published var observerId: Int = 0
  @Published var observerName: String? = "noName"
  
  let filePath: URL
  
  init() {
    log.info("init ObserversViewModel")
    
    let fileManager = FileManager.default
    let fileName = "observers.json"
    
    if let ubiquityURL = fileManager.url(forUbiquityContainerIdentifier: nil)?
      .appendingPathComponent("Documents") {
      try? fileManager.createDirectory(at: ubiquityURL, withIntermediateDirectories: true)
      self.filePath = ubiquityURL.appendingPathComponent(fileName)
      log.info("Using iCloud path: \(filePath.path)")
    } else {
      let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
      self.filePath = documentsPath.appendingPathComponent(fileName)
      log.warning("iCloud unavailable, using local path: \(filePath.path)")
    }
    
    if !fileManager.fileExists(atPath: filePath.path) {
      let initialContent = "[]"
      do {
        try initialContent.write(to: filePath, atomically: true, encoding: .utf8)
        log.info("File created successfully at path: \(filePath.path)")
      } catch {
        log.error("Failed to create file. Error: \(error.localizedDescription)")
      }
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
