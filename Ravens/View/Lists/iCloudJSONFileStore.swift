//
//  iCloudJSONFileStore.swift
//  Ravens
//
//  Created by Codex on 11/08/2026.
//

import Foundation
import SwiftData
import SwiftyBeaver

@Model
final class PersistentJSONCollection {
  var name: String = ""
  var payload: Data = Data("[]".utf8)
  var updatedAt: Date = Date()

  init(name: String, payload: Data = Data("[]".utf8), updatedAt: Date = Date()) {
    self.name = name
    self.payload = payload
    self.updatedAt = updatedAt
  }
}

enum RavensModelContainer {
  static let shared: ModelContainer = {
    let schema = Schema([
      PersistentJSONCollection.self
    ])

    let cloudKitDatabase: ModelConfiguration.CloudKitDatabase
    if let bundleIdentifier = Bundle.main.bundleIdentifier {
      cloudKitDatabase = .private("iCloud.\(bundleIdentifier)")
    } else {
      cloudKitDatabase = .automatic
    }

    let configuration = ModelConfiguration(
      schema: schema,
      isStoredInMemoryOnly: false,
      cloudKitDatabase: cloudKitDatabase
    )

    do {
      return try ModelContainer(for: schema, configurations: [configuration])
    } catch {
      fatalError("Could not create SwiftData model container: \(error)")
    }
  }()
}

@MainActor
final class SwiftDataJSONCollectionStore {
  static let shared = SwiftDataJSONCollectionStore()

  private let log = SwiftyBeaver.self
  private let modelContext: ModelContext
  private let fileManager = FileManager.default

  private init(modelContainer: ModelContainer = RavensModelContainer.shared) {
    self.modelContext = ModelContext(modelContainer)
  }

  func loadRecords<T: Codable>(named collectionName: String, as type: [T].Type) -> [T] {
    migrateLegacyJSONIfNeeded(named: collectionName)

    guard let data = collection(named: collectionName)?.payload else {
      return []
    }

    do {
      return try JSONDecoder().decode(type, from: data)
    } catch {
      log.info("SwiftData decode failed for \(collectionName): \(error)")
      return []
    }
  }

  func saveRecords<T: Codable>(_ records: [T], named collectionName: String) {
    do {
      let data = try JSONEncoder().encode(records)
      let record: PersistentJSONCollection
      if let existingRecord = collection(named: collectionName) {
        record = existingRecord
      } else {
        record = PersistentJSONCollection(name: collectionName)
        modelContext.insert(record)
      }

      record.payload = data
      record.updatedAt = Date()

      try modelContext.save()
    } catch {
      log.info("SwiftData save failed for \(collectionName): \(error)")
    }
  }

  private func collection(named collectionName: String) -> PersistentJSONCollection? {
    let descriptor = FetchDescriptor<PersistentJSONCollection>(
      predicate: #Predicate { $0.name == collectionName }
    )

    do {
      let records = try modelContext.fetch(descriptor)
      if records.count > 1 {
        mergeDuplicateCollections(records, named: collectionName)
      }
      return records.first
    } catch {
      log.info("SwiftData fetch failed for \(collectionName): \(error)")
      return nil
    }
  }

  private func mergeDuplicateCollections(_ records: [PersistentJSONCollection], named collectionName: String) {
    guard let keeper = records.max(by: { $0.updatedAt < $1.updatedAt }) else {
      return
    }

    for record in records where record !== keeper {
      modelContext.delete(record)
    }

    do {
      try modelContext.save()
    } catch {
      log.info("SwiftData duplicate cleanup failed for \(collectionName): \(error)")
    }
  }

  private func migrateLegacyJSONIfNeeded(named collectionName: String) {
    guard collection(named: collectionName) == nil,
          let legacyData = bestLegacyData(for: collectionName) else {
      return
    }

    let record = PersistentJSONCollection(name: collectionName, payload: legacyData, updatedAt: Date())
    modelContext.insert(record)

    do {
      try modelContext.save()
      log.info("Migrated \(collectionName) JSON into SwiftData")
    } catch {
      log.info("SwiftData migration failed for \(collectionName): \(error)")
    }
  }

  private func bestLegacyData(for fileName: String) -> Data? {
    let candidates = [
      iCloudDocumentsURL(fileName: fileName),
      localDocumentsURL(fileName: fileName)
    ].compactMap { $0 }

    for url in candidates {
      guard hasUsableContent(at: url),
            let data = try? Data(contentsOf: url),
            (try? JSONSerialization.jsonObject(with: data)) != nil else {
        continue
      }
      return data
    }

    return nil
  }

  private func iCloudDocumentsURL(fileName: String) -> URL? {
    fileManager.url(forUbiquityContainerIdentifier: nil)?
      .appendingPathComponent("Documents", isDirectory: true)
      .appendingPathComponent(fileName)
  }

  private func localDocumentsURL(fileName: String) -> URL {
    fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
      .appendingPathComponent(fileName)
  }

  private func hasUsableContent(at url: URL) -> Bool {
    guard let attributes = try? fileManager.attributesOfItem(atPath: url.path),
          let fileSize = attributes[.size] as? NSNumber else {
      return false
    }

    return fileSize.intValue > 0
  }
}
