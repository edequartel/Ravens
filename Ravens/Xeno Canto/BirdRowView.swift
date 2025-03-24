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
    currentlyPlayingBirdID == bird.id_species && audioPlayerManager.isPlaying
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
        currentlyPlayingBirdID = bird.id_species
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
                .foregroundColor(.gray)

              Text("XC\(bird.id_species)")
                .bold()

              Text("\(bird.length ?? "")")
                .foregroundColor(.gray)

              Spacer()
            }

            HStack {
              localizedSoundTypes(from: bird.type ?? "")
                .bold()
                .lineLimit(1)
                .truncationMode(.tail)
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
            Image(systemSymbol: .waveform)
              .font(.title)
              .foregroundColor(.blue)
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
        Image(systemSymbol: .infoCircle)
      }
      .tint(.orange)



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

  func localizedSoundTypes(from string: String) -> Text {
    let validOptions = Set(SoundOption.allCases.map { $0.rawValue })

    let parts = string
      .split(separator: ",")
      .map { $0.trimmingCharacters(in: .whitespaces) }
      .filter { validOptions.contains($0) }

    let localizedParts = parts.map { LocalizedStringKey($0) }

    return localizedParts
      .enumerated()
      .map { index, key in
        index == 0 ? Text(key) : Text(", ") + Text(key)
      }
      .reduce(Text(""), +)
  }
}

enum SoundOption: String, CaseIterable {
  case mixed
  case song
  case call
  case imitation
  case aberrant
  case advertisementCall = "advertisement call"
  case agonisticCall = "agonistic call"
  case alarmCall = "alarm call"
  case beggingCall = "begging call"
  case callingSong = "calling song"
  case courtshipSong = "courtship song"
  case dawnSong = "dawn song"
  case defensiveCall = "defensive call"
  case distressCall = "distress call"
  case disturbanceSong = "disturbance song"
  case drumming
  case duet
  case echolocation
  case feedingBuzz = "feeding buzz"
  case femaleSong = "female song"
  case flightCall = "flight call"
  case flightSong = "flight song"
  case matingCall = "mating call"
  case mechanicalSound = "mechanical sound"
  case nocturnalFlightCall = "nocturnal flight call"
  case nightCall = "night call"
  case releaseCall = "release call"
  case rivalrySong = "rivalry song"
  case searchingSong = "searching song"
  case socialCall = "social call"
  case subsong
  case territorialCall = "territorial call"


  var intValue: Int? {
    return SoundOption.allCases.firstIndex(of: self)
  }

  var localized: LocalizedStringKey {
    LocalizedStringKey(self.rawValue)
  }
}

// MARK: - SoundTypePickerView
struct SoundTypePickerView: View {
  @Binding var selectedSound: SoundOption

  var body: some View {
    Form {
      Section(soundXC) {
        List {
          ForEach(SoundOption.allCases, id: \.self) { sound in
            Button(action: {
              selectedSound = sound
            }) {
              HStack {
                Text(sound.localized)
                Spacer()
                if selectedSound == sound {
                  Image(systemSymbol: .checkmark)
                }
              }
            }
            .foregroundColor(.primary)
          }
        }
      }
    }
    .navigationBarTitleDisplayMode(.inline)
  }
}

// MARK: - Preview
struct BirdListView_Previews: PreviewProvider {
  static var previews: some View {
    BirdListView(scientificName: "Limosa limosa", nativeName: "Grutto")
  }
}
