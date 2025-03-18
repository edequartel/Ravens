//
//  BirdRowView.swift
//  XC
//
//  Created by Eric de Quartel on 07/03/2025.
//

import SwiftUI
import Alamofire
import Kingfisher
import AVFoundation
import SwiftAudioEx

// MARK: - BirdRowView
struct BirdRowView: View {
  let bird: Bird
  @ObservedObject var audioPlayerManager: AudioPlayerManager
  @EnvironmentObject var accessibilityManager: AccessibilityManager
  @Binding var currentlyPlayingBirdID: String?
  @State private var isLoadingAudio = false
  let birdName : String
  @Binding var selectedBird: Bird?


  var isPlayingThisBird: Bool {
    currentlyPlayingBirdID == bird.id && audioPlayerManager.isPlaying
  }

  var body: some View {
    Button(action: {
      if isPlayingThisBird {
        audioPlayerManager.stopAudio()
        currentlyPlayingBirdID = nil
        isLoadingAudio = false
      } else {
        if currentlyPlayingBirdID != nil {
          audioPlayerManager.stopAudio()
        }
        currentlyPlayingBirdID = bird.id
        isLoadingAudio = true
        audioPlayerManager.playAudio(from: bird.file) {
          isLoadingAudio = false
        }
      }
    }) {
      VStack(alignment: .leading, spacing: 5) {
        HStack {
          VStack {
            HStack {
              Image(systemName: "\(bird.q?.lowercased() ?? "").square.fill")
                .font(.caption)
                .foregroundColor(.gray)
              Text("XC\(bird.id)")
                .font(.caption)
                .bold(true)
              Text("\(bird.type ?? "")")
                .font(.caption)
              Spacer()
            }

            HStack {
              Text("\(bird.rec ?? "")")
                .font(.caption)
              Spacer()
            }

          }
          Spacer()
          if isLoadingAudio {
            ProgressView()
              .progressViewStyle(CircularProgressViewStyle())
          } else if isPlayingThisBird {
            Image(systemName: "waveform")
              .font(.title)
              .foregroundColor(.gray)
          }
        }
      }
      .frame(maxWidth: .infinity, minHeight: 40)
      .padding(.horizontal, 10)
      .padding(.vertical, 4)
      .contentShape(Rectangle())
    }
    .swipeActions(edge: .trailing, allowsFullSwipe: false) {

      Button(action: {
        if let url = modifyURL(from: bird.url) {
          UIApplication.shared.open(url)
        } else {
          print("Invalid URL")
        }
      }) {
        Text("XC")
      }

      .tint(Color(red: 0.5, green: 0.0, blue: 0.0)) // Dark red tint

      Button(action: {
        selectedBird = bird
      }) {
        Label("Info", systemImage: "info.circle")
      }
      .tint(.blue)



    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(birdName) \(bird.type ?? "")")
    .onDisappear {
      // Stop audio when leaving the BirdListView
      if isPlayingThisBird {
        audioPlayerManager.stopAudio()
      }
    }
  }
}

// MARK: - SoundTypePickerView
struct SoundTypePickerView: View {
  @Binding var typeSound: String

  let soundOptions = ["mixed", "call", "song", "alarm call", "flight call", "night calls", "begging calls"]

  var body: some View {
    Picker("Select", selection: $typeSound) {
      ForEach(soundOptions, id: \.self) { sound in
        Text(sound).tag(sound)
      }
    }
    .pickerStyle(.menu)
  }
}

// MARK: - Preview
struct BirdListView_Previews: PreviewProvider {
  static var previews: some View {
    BirdListView(scientificName: "Limosa limosa", nativeName: "Grutto")
  }
}
