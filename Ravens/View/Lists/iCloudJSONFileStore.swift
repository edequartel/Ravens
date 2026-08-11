//
//  iCloudJSONFileStore.swift
//  Ravens
//
//  Created by Codex on 11/08/2026.
//

import Foundation
import SwiftyBeaver

enum ICloudJSONFileStore {
  private static let documentsFolderName = "Documents"

  static func url(for fileName: String, log: SwiftyBeaver.Type) -> URL {
    let fileManager = FileManager.default
    let localURL = localDocumentsURL(fileName: fileName, fileManager: fileManager)

    guard let iCloudDocumentsURL = fileManager.url(forUbiquityContainerIdentifier: nil)?
      .appendingPathComponent(documentsFolderName, isDirectory: true) else {
      log.warning("iCloud unavailable, using local JSON path: \(localURL.path)")
      ensureJSONFileExists(at: localURL, fileManager: fileManager, log: log)
      return localURL
    }

    do {
      try fileManager.createDirectory(at: iCloudDocumentsURL, withIntermediateDirectories: true)
    } catch {
      log.error("Could not create iCloud Documents folder: \(error.localizedDescription)")
      ensureJSONFileExists(at: localURL, fileManager: fileManager, log: log)
      return localURL
    }

    let iCloudURL = iCloudDocumentsURL.appendingPathComponent(fileName)
    migrateLocalJSONIfNeeded(from: localURL, to: iCloudURL, fileManager: fileManager, log: log)
    ensureJSONFileExists(at: iCloudURL, fileManager: fileManager, log: log)
    startDownloadingIfNeeded(iCloudURL, fileManager: fileManager, log: log)

    log.info("Using iCloud JSON path: \(iCloudURL.path)")
    return iCloudURL
  }

  private static func localDocumentsURL(fileName: String, fileManager: FileManager) -> URL {
    fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
      .appendingPathComponent(fileName)
  }

  private static func migrateLocalJSONIfNeeded(
    from localURL: URL,
    to iCloudURL: URL,
    fileManager: FileManager,
    log: SwiftyBeaver.Type
  ) {
    guard fileManager.fileExists(atPath: localURL.path),
          hasUsableContent(at: localURL),
          !hasUsableContent(at: iCloudURL) else {
      return
    }

    do {
      if fileManager.fileExists(atPath: iCloudURL.path) {
        try fileManager.removeItem(at: iCloudURL)
      }
      try fileManager.copyItem(at: localURL, to: iCloudURL)
      log.info("Migrated local JSON to iCloud: \(iCloudURL.lastPathComponent)")
    } catch {
      log.error("Could not migrate local JSON to iCloud: \(error.localizedDescription)")
    }
  }

  private static func ensureJSONFileExists(
    at url: URL,
    fileManager: FileManager,
    log: SwiftyBeaver.Type
  ) {
    guard !fileManager.fileExists(atPath: url.path) || !hasUsableContent(at: url) else {
      return
    }

    do {
      try "[]".write(to: url, atomically: true, encoding: .utf8)
    } catch {
      log.error("Could not create JSON file \(url.lastPathComponent): \(error.localizedDescription)")
    }
  }

  private static func hasUsableContent(at url: URL) -> Bool {
    guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
          let fileSize = attributes[.size] as? NSNumber else {
      return false
    }

    return fileSize.intValue > 0
  }

  private static func startDownloadingIfNeeded(
    _ url: URL,
    fileManager: FileManager,
    log: SwiftyBeaver.Type
  ) {
    do {
      try fileManager.startDownloadingUbiquitousItem(at: url)
    } catch {
      log.warning("Could not start iCloud download for \(url.lastPathComponent): \(error.localizedDescription)")
    }
  }
}
