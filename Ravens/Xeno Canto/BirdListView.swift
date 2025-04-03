// File: XenoCantoAPI.swift

import SwiftUI
import Alamofire
import Kingfisher
import AVFoundation
import SwiftAudioEx

// MARK: - BirdListView
struct BirdListView: View {
  @StateObject private var viewModel = BirdViewModel()
  @State private var selectedSound: SoundOption = .mixed
  @StateObject private var audioPlayerManager = AudioPlayerManager()
  @EnvironmentObject var accessibilityManager: AccessibilityManager
  @State private var currentlyPlayingBirdID: String?
  @State private var selectedBird: Bird?
  @State private var firstTime: Bool = true
  @State private var statusFetch: Int = -1

  let scientificName: String
  var nativeName: String?

  var body: some View {
    NavigationStack {
    VStack {
      HorizontalLine()
      if statusFetch == 0 {
        Text(noRecordings)
      }

      Group {
        if viewModel.isLoading {
          ProgressView(loadindData)
            .progressViewStyle(CircularProgressViewStyle())
        } else if let errorMessage = viewModel.errorMessage {
          Text("Error: \(errorMessage)")
        } else {
          List(viewModel.birds.filter {
            isMP3(filename: $0.fileName ?? "") &&
            (
              selectedSound == .mixed ||
              ($0.type?
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .contains(selectedSound.rawValue) == true)
            )
          }) { bird in
            BirdRowView(
              bird: bird,
              audioPlayerManager: audioPlayerManager,
              currentlyPlayingBirdID: $currentlyPlayingBirdID,
              birdName: bird.english ?? "",
              selectedBird: $selectedBird
            )
          }
          .listStyle(PlainListStyle())
        }
      }

      Spacer()
    }
  }

    .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          NavigationLink(destination: SoundTypePickerView(selectedSound: $selectedSound)
          ) {
            Image(systemSymbol: .ellipsisCircle)
              .uniformSize()
              .accessibility(label: Text(typeSoundsList))
          }
        }
    }

    .sheet(item: $selectedBird) { bird in
      BirdDetailView(bird: bird, nativeName: nativeName)
        .presentationDetents([.fraction(0.8)])
        .presentationDragIndicator(.visible)
    }

    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle(nativeName ?? "")
    .onAppear {
      if firstTime {
        viewModel.fetchBirds(name: scientificName) { nrOfSounds in
          statusFetch = nrOfSounds
        }
        firstTime = false
      }
    }
  }

  func isMP3(filename: String) -> Bool {
    let pattern = "^.+\\.mp3$"
    return filename.range(of: pattern, options: .regularExpression) != nil
  }
}
