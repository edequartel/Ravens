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
  @State private var currentlyPlayingBirdID: String? = nil
  @State private var selectedBird: Bird?

  let scientificName: String
  var nativeName: String?

  var body: some View {
    VStack {
        SoundTypePickerView(selectedSound: $selectedSound)
          .padding(.horizontal)

      HorizontalLine()

      Group {
        if viewModel.isLoading {
          ProgressView("Loading data...")
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
              birdName: bird.en ?? "",
              selectedBird: $selectedBird
            )
          }
          .listStyle(PlainListStyle())
        }
      }

      Spacer()
    }
    .sheet(item: $selectedBird) { bird in
      BirdDetailView(bird: bird, nativeName: nativeName)
        .presentationDetents([.fraction(0.7)])
        .presentationDragIndicator(.visible)
    }
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle(nativeName ?? "")
    .onAppear {
      viewModel.fetchBirds(name: scientificName)
    }
  }

  func isMP3(filename: String) -> Bool {
    let pattern = "^.+\\.mp3$"
    return filename.range(of: pattern, options: .regularExpression) != nil
  }
}

