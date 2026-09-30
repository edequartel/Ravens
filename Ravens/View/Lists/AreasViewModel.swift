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
  var areaID: Int // locatiobID
  var latitude: CLLocationDegrees = 0
  var longitude: CLLocationDegrees = 0
}

@MainActor
class AreasViewModel: ObservableObject {
  let log = SwiftyBeaver.self

  @Published var records: [Area] = []
  private let collectionName: String

  init() {
    log.info("init AreasViewModel")

    let fileName = "areas.json"

    self.collectionName = fileName
    loadRecords()
  }

  func loadRecords() {
    records = SwiftDataJSONCollectionStore.shared.loadRecords(named: collectionName, as: [Area].self)
    log.info("Loaded \(records.count) areas")
  }

  func saveRecords() {
    SwiftDataJSONCollectionStore.shared.saveRecords(records, named: collectionName)
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
