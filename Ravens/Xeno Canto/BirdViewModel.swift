//
//  ViewModel.swift
//  XC
//
//  Created by Eric de Quartel on 25/11/2024.
//
import SwiftUI

class BirdViewModel: ObservableObject {
  @Published var birds: [Bird] = []
  @Published var totalRecordings: Int = 0
  @Published var totalPages: Int = 0
  @Published var currentPage: Int = 0
  @Published var totalSpecies: Int = 0
  @Published var isLoading = false
  @Published var errorMessage: String?

  var hasFetchedBirds: Bool = false // for progressview
  private let birdSoundService: BirdSoundService

  init(birdSoundService: BirdSoundService = BirdSoundService()) {
    self.birdSoundService = birdSoundService
  }

  func fetchBirds(name: String, onComplete: ((_ numRecordings: Int) -> Void)? = nil) {
    isLoading = true
    errorMessage = nil

    Task {
      do {
        let recordings = try await birdSoundService.recordings(for: name)
        await MainActor.run {
          self.birds = recordings
          self.totalRecordings = recordings.count
          self.totalPages = 1
          self.currentPage = 1
          self.totalSpecies = recordings.isEmpty ? 0 : 1
          self.isLoading = false
          self.hasFetchedBirds = true
          onComplete?(recordings.count)
        }
      } catch {
        await MainActor.run {
          self.isLoading = false
          self.errorMessage = "Failed to fetch birds: \(error.localizedDescription)"
          onComplete?(0) // or use -1 if you want to indicate failure explicitly
        }
      }
    }
  }
}
