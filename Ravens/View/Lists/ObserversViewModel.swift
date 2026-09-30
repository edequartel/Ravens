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

@MainActor
class ObserversViewModel: ObservableObject {
  let log = SwiftyBeaver.self
  
  @Published var records: [Observer] = []
  
  @Published var observerId: Int = 0
  @Published var observerName: String? = "noName"
  
  private let collectionName: String
  
  init() {
    log.info("init ObserversViewModel")
    
    let fileName = "observers.json"
    self.collectionName = fileName
    loadRecords()
  }

  func loadRecords() {
    records = SwiftDataJSONCollectionStore.shared.loadRecords(named: collectionName, as: [Observer].self)
    log.info("Loaded \(records.count) observers")
  }
  
  func saveRecords() {
    SwiftDataJSONCollectionStore.shared.saveRecords(records, named: collectionName)
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
