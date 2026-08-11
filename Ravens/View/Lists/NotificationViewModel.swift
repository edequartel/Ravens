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

  let filePath: URL

  init(fileName: String) {
    self.filePath = ICloudJSONFileStore.url(for: fileName, log: log)
    loadRecords()

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

  // --- this has to be in the background even when app is not active

  private let interval: TimeInterval = 300 // 900 // every 15 minutes
  @Published var observations: [Obs] = []
  private var timer: AnyCancellable?
  private var lastObservationIDs: Set<Int> = []
  private var hasFetchedOnce = false

  func startPolling() {
      timer = Timer
          .publish(every: interval, on: .main, in: .common) // 5 minutes
          .autoconnect()
          .sink { [weak self] _ in
            self?.fetchObservations(speciesId: 122)
          }

      fetchObservations(speciesId: 122) // Initial fetch
  }

  private func fetchObservations(speciesId: Int) {
    let endpoint = "https://waarneming.nl/api/v1/species/\(speciesId)/observations/?date_after=2025-08-05&date_before=2025-08-07"
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

//          if self.hasFetchedOnce {
            if !newOnes.isEmpty {
              LogStore.shared.log("🆕 New observations:")
              newOnes.forEach {
                LogStore.shared.log("•\($0.species ?? 0) at \($0.date) - \($0.time ?? "?")")
              }
            } else {
              LogStore.shared.log("✅ No new observations.")
            }
//          } else {
//            self.hasFetchedOnce = true
//          }

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
