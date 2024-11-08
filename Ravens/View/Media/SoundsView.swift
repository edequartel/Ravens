//
//  ContentView.swift
//  TestSoundableStream
//
//  Created by Eric de Quartel on 20/03/2024.
//
import SwiftUI
import SwiftAudioEx
import SwiftyBeaver
import Foundation
import MediaPlayer

class Player: ObservableObject {
  let log = SwiftyBeaver.self
  private var queuedAudioPlayer: QueuedAudioPlayer

  @Published var status: AudioPlayerState = .idle
  @Published var title: String = "unknown"
  @Published var artist: String = "unknown"

  @Published var currentTime: Double = 0
  @Published var currentIndex: Int = 0
  @Published var duration: Double = 0

  init() {
    queuedAudioPlayer = QueuedAudioPlayer()
    queuedAudioPlayer.nowPlayingInfoController.set(keyValue: NowPlayingInfoProperty.isLiveStream(true))
    queuedAudioPlayer.event.stateChange.addListener(self, handleAudioPlayerStateChange)
    queuedAudioPlayer.event.updateDuration.addListener(self, handleDuration)
    queuedAudioPlayer.event.secondElapse.addListener(self, handleSecondElapse)
    queuedAudioPlayer.event.currentItem.addListener(self, handleData)
  }

  private func handleData(
    currentItemEventData:
    ( item: AudioItem?,
      index: Int?,
      lastItem: AudioItem?,
      lastIndex: Int?,
      lastPosition: Double?
    )) {
    DispatchQueue.main.async {
      self.currentIndex = currentItemEventData.index ?? 0
    }
  }

  private func handleAudioPlayerStateChange(state: AudioPlayerState) {
    log.info("state change, \(state)")
    DispatchQueue.main.async {
      self.status = state
      if state == .ended {
        self.stop()
      }
    }
  }

  private func handleDuration(duration: Double) {
    log.info("duration, \(duration)")
    DispatchQueue.main.async {
      self.duration = duration
    }
  }

  private func handleSecondElapse(currentTime: Double) {
    DispatchQueue.main.async {
      self.currentTime = currentTime
    }
  }

  func fill(_ audioUrls: [String]) {
    queuedAudioPlayer.clear()
    for audioUrl in audioUrls {
      let audioItem = DefaultAudioItem(
        audioUrl: audioUrl,
        sourceType: .stream
      )
      log.error("fill \(audioUrl)")
      queuedAudioPlayer.add(item: audioItem, playWhenReady: true)
    }
  }

  func play() {
    queuedAudioPlayer.play()
    log.info("playing")
  }

  func pause() {
    queuedAudioPlayer.pause()
    log.info("paused")
  }

  func stop() {
    queuedAudioPlayer.stop()
    log.info("stopped")
  }

  func previous() {
    queuedAudioPlayer.previous()
    log.info("previous")
  }

  func next() {
    queuedAudioPlayer.next()
    log.info("next")
  }
}

extension View {
  @ViewBuilder
  func hidden(_ shouldHide: Bool) -> some View {
    switch shouldHide {
    case true:
      self.hidden()
    case false:
      self
    }
  }
}

struct PlayerControlsView: View {
  @EnvironmentObject var player: Player

  @Environment(\.presentationMode) var presentationMode

  @State private var sliderValue: Double = 0
  @State private var nrPlaying = 0

  var sounds: [String]
  //    var audio1 = ["https://xeno-canto.org/sounds/uploaded/GYAUIPUVNM/XC928304-Troglodytes-troglodytes_240819_063924_00.wav",
  //                  "https://waarneming.nl/media/sound/235292.mp3",
  //                  "https://waarneming.nl/media/sound/235293.mp3"]

  var body: some View {
    if !(sounds.isEmpty) {

      VStack {
        VStack {
          if sounds.count > 1 {
            HStack {
              Spacer()
              Text("\(player.currentIndex+1)-\(sounds.count)")
            }
            .font(.caption)
            .foregroundColor(.gray)
          }

          Slider(value: $player.currentTime, in: 0...player.duration)
            .disabled(true)
          HStack {
            Text(String(format: "%.2f", player.currentTime))
            Spacer()
            Text(String(format: "%.2f", player.duration))
          }
          .font(.caption)
          .foregroundColor(.gray)
        }
        .padding(10)

        HStack {
          Spacer()

          if sounds.count > 1 {
            Button(action: {
              player.previous()
              player.play()
            }) {
              Image(systemName: "backward.end.circle.fill")
                .font(.system(size: 30))
                .frame(width: 50)
            }
          }

          if player.status != .playing // && (player.status != .loading) && (player.status != .buffering))
          {
            Button(action: {
              player.play()
            }) {
              Image(systemName: "play.circle.fill")
                .font(.system(size: 50))
                .frame(width: 50)
            }
          } else {
            Button(action: {
              player.pause()
            }) {
              Image(systemName: "pause.circle.fill")
                .font(.system(size: 50))
                .frame(width: 50)
            }
          }

          if (sounds.count > 1) {
            Button(action: {
              player.next()
              player.play()
            }) {
              Image(systemName: "forward.end.circle.fill")
                .font(.system(size: 30))
                .frame(width: 50)
            }
          }
          Spacer()
        }
        .padding(10)
      }
      .padding(5)
      .onAppear {
        player.fill(sounds)
      }
      .onDisappear {
        player.stop()
      }
      .frame(maxHeight: 300)
    } else { EmptyView().frame(maxHeight: 300) }
  }




  private var closeButton: some View {
    Button {
      presentationMode.wrappedValue.dismiss()
    } label: {
      Image(systemName: "xmark")
        .font(.headline)
    }
    .buttonStyle(.bordered)
    .clipShape(Circle())
    .padding()
  }
}

struct PlayerControlsView_Previews: PreviewProvider {
  static var previews: some View {
    PlayerControlsView(sounds: [])
      .environmentObject(Player())
  }
}

//struct ContentView: View {
//    @EnvironmentObject var player: Player
//
//    var audio1 = ["https://waarneming.nl/media/sound/235291.mp3",
//                  "https://waarneming.nl/media/sound/235292.mp3",
//                  "https://waarneming.nl/media/sound/235293.mp3"]
//
//    var audio2 = ["https://waarneming.nl/media/sound/235783.wav",
//                  "https://waarneming.nl/media/sound/235293.mp3",
//                  "https://waarneming.nl/media/sound/235770.mp3"]
//
//    var audio3 = ["https://waarneming.nl/media/sound/235783.wav",
//                  "https://waarneming.nl/media/sound/235293.mp3",
//                  "https://waarneming.nl/media/sound/235770.mp3"]
//
//
//    var body: some View {
//        VStack {
//            Text("\(player.statePlayer)")
//            PlayerControlsView(audio: audio1)
//            PlayerControlsView(audio: audio2)
//            PlayerControlsView(audio: audio3)
//        }
//        .padding(5)
//    }
//}
