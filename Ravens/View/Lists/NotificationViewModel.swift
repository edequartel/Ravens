//
//  NotificationViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 05/08/2025.
//

import Foundation
import SwiftyBeaver
import Combine
import Alamofire

struct Notification: Codable, Identifiable {
  var id: UUID = UUID()  // Unique identifier for SwiftUI List operations
  var speciesID: Int // bookmarkID
  var scientificName: String?
}

class NotificationsViewModel: ObservableObject {
  let log = SwiftyBeaver.self
  @Published var records: [Notification] = []

  let fileManager = FileManager.default
  let filePath: URL

  init(fileName: String) {
    let fileManager = FileManager.default

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

    if fileManager.fileExists(atPath: filePath.path) {
      log.info("File exists at path: \(filePath.path)")
      loadRecords()
    } else {
      log.info("File does not exist at path: \(filePath.path). Creating file...")
      let initialContent = "[]" // Default empty JSON content

      do {
        try initialContent.write(to: filePath, atomically: true, encoding: .utf8)
        log.info("File created successfully at path: \(filePath.path)")
      } catch {
        log.error("Failed to create file. Error: \(error.localizedDescription)")
      }
    }

    //
    startPolling()
  }

  func printAllSpeciesIDs() {
    for notification in records {
      print("Species ID: \(notification.speciesID)")
    }
  }

  func loadRecords() {
    do {
      let data = try Data(contentsOf: filePath)
      records = try JSONDecoder().decode([Notification].self, from: data)
    } catch {
      log.info("BookMarksViewModel Error loading data: \(error)")
    }
  }

  func saveRecords() {
    do {
      let data = try JSONEncoder().encode(records)
      try data.write(to: filePath, options: .atomicWrite)
    } catch {
      log.info("BookMarksViewModel Error saving data: \(error)")
    }
  }

  func isSpeciesIDInRecords(speciesID: Int) -> Bool {
    return records.contains(where: { $0.speciesID == speciesID })
  }

  func appendRecord(speciesID: Int) {
    print("appendRecord(\(speciesID))")
    guard !records.contains(where: { $0.speciesID == speciesID }) else {
      return
    }
    let newRecord = Notification(speciesID: speciesID)
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

  // --------------------------- this has to be in the background even when app is not active

  private let interval: TimeInterval = 20 // every 2 minutes
  @Published var observations: [Obs] = []
  private var timer: AnyCancellable?
  private let endpoint = "https://waarneming.nl/api/v1/species/122/observations/"
  private var lastObservationIDs: Set<Int> = []

  func startPolling() {
      timer = Timer
          .publish(every: interval, on: .main, in: .common) // 5 minutes
          .autoconnect()
          .sink { [weak self] _ in
              self?.fetchObservations()
          }

      fetchObservations() // Initial fetch
  }

  private func fetchObservations() {
    AF.request(endpoint)
      .validate()
      .responseDecodable(of: Observations.self) { response in
        switch response.result {
        case .success(let decodedResponse):
          let newObservations = decodedResponse.results ?? []
          let newOnes = newObservations.filter { obs in
            guard let id = obs.idObs else { return false }
            return !self.lastObservationIDs.contains(id)
          }

          if !newOnes.isEmpty {
            print("🆕 New observations:")
            newOnes.forEach {
              print("• speciesID: \(String(describing: $0.species)) at \(String(describing: $0.date)) \($0.time ?? "")")
            }
          } else {
            print("✅ No new observations.")
          }

          DispatchQueue.main.async {
            self.lastObservationIDs = Set(newObservations.compactMap { $0.idObs })
            self.observations = newObservations
          }

        case .failure(let error):
          print("❌ Alamofire decoding error: \(error)")
          if let data = response.data, let raw = String(data: data, encoding: .utf8) {
            print("🔍 Raw response:\n\(raw)")
          }
        }
      }
  }
}


