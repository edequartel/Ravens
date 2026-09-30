//
//  BookMarksViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 15/05/2024.
//

import Foundation
import SwiftyBeaver

struct BookMark: Codable, Identifiable {
  var id: UUID = UUID()  // Unique identifier for SwiftUI List operations
  var speciesID: Int // bookmarkID
}

@MainActor
class BookMarksViewModel: ObservableObject {
  let log = SwiftyBeaver.self
  @Published var records: [BookMark] = []

  private let collectionName: String
  
  init(fileName: String) {
    self.collectionName = fileName
    loadRecords()
  }

  func loadRecords() {
    records = SwiftDataJSONCollectionStore.shared.loadRecords(named: collectionName, as: [BookMark].self)
  }

  func saveRecords() {
    SwiftDataJSONCollectionStore.shared.saveRecords(records, named: collectionName)
  }

  func isSpeciesIDInRecords(speciesID: Int) -> Bool {
    return records.contains(where: { $0.speciesID == speciesID })
  }

  func appendRecord(speciesID: Int) {
    print("appendRecord(\(speciesID))")
    guard !records.contains(where: { $0.speciesID == speciesID }) else {
      return
    }
    let newRecord = BookMark(speciesID: speciesID)
    records.append(newRecord)
    saveRecords()
  }

  func removeRecord(speciesID: Int) {
    print("removeRecord(\(speciesID))")
    if let index = records.firstIndex(where: { $0.speciesID == speciesID }) {
      records.remove(at: index)
      saveRecords()
    } else {
      log.info("BookMarksViewModel Record with speciesID \(speciesID) does not exist.")
    }
  }
}
