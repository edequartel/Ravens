// File: XenoCantoAPI.swift

import SwiftUI
import Alamofire
import Kingfisher
import AVFoundation
import SwiftAudioEx

// MARK: - BirdListView
struct BirdListView: View {
  @StateObject private var viewModel = BirdViewModel()
  @State private var typeSound: String = "mixed"
  @StateObject private var audioPlayerManager = AudioPlayerManager()
  @EnvironmentObject var accessibilityManager: AccessibilityManager
  @State private var currentlyPlayingBirdID: String? = nil
  @State private var selectedBird: Bird?

  let scientificName: String
  var nativeName: String?

  var body: some View {
    VStack {

      HStack {
        Text("Sound")

        Spacer()
        SoundTypePickerView(typeSound: $typeSound)
      }
      .padding()
      HorizontalLine()
      Group {
        if viewModel.isLoading {
          ProgressView("Loading data...")
            .progressViewStyle(CircularProgressViewStyle())
        } else if let errorMessage = viewModel.errorMessage {
          Text("Error: \(errorMessage)")
        } else {
          VStack {
            List(viewModel.birds.filter {
              isMP3(filename: $0.fileName ?? "") &&
              ($0.type == typeSound || typeSound == "mixed")
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
      }
      Spacer()

    }

    .sheet(item: $selectedBird) { bird in
      BirdDetailView(bird: bird, nativeName: nativeName)
        .presentationDetents([.fraction(0.7)]) // Enables swipe-down to dismiss
        .presentationDragIndicator(.visible) // Shows a handle at the top
    }

    .onAppear {
      viewModel.fetchBirds(name: scientificName)
    }
  }

  func isMP3(filename: String) -> Bool {
    let pattern = #"^.+\.mp3$"#
    return filename.range(of: pattern, options: .regularExpression) != nil
  }
}


