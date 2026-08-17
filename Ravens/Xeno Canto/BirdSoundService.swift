//
//  BirdSoundService.swift
//  Ravens
//

import Foundation

final class BirdSoundService {
  private let xenoCantoService: XenoCantoServicing
  private let taxonomyResolver: TaxonomyResolving

  init(
    xenoCantoService: XenoCantoServicing = XenoCantoService(),
    taxonomyResolver: TaxonomyResolving = TaxonomyResolver()
  ) {
    self.xenoCantoService = xenoCantoService
    self.taxonomyResolver = taxonomyResolver
  }

  func recordings(for scientificName: String) async throws -> [XenoCantoRecording] {
    debugLog("Xeno-canto lookup: \(scientificName)")
    let directRecordings = try await xenoCantoService.recordings(for: scientificName)
    if !directRecordings.isEmpty {
      debugLog("Found \(directRecordings.count) recordings.")
      return directRecordings
    }

    debugLog("No recordings found.")
    debugLog("Resolving taxonomy via GBIF...")

    let candidates: [String]
    do {
      candidates = try await taxonomyResolver.candidateNames(for: scientificName)
    } catch {
      debugLog("GBIF taxonomy lookup failed: \(error.localizedDescription)")
      return []
    }

    for candidate in candidates where candidate.caseInsensitiveCompare(scientificName) != .orderedSame {
      debugLog("Alternative scientific name: \(candidate)")
      debugLog("Xeno-canto lookup: \(candidate)")

      let recordings = try await xenoCantoService.recordings(for: candidate)
      if !recordings.isEmpty {
        debugLog("Found \(recordings.count) recordings.")
        return recordings
      }

      debugLog("No recordings found.")
    }

    return []
  }

  private func debugLog(_ message: String) {
    #if DEBUG
    print(message)
    #endif
  }
}
