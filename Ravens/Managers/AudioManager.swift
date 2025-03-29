//
//  AudioManager.swift
//  XC
//
//  Created by Eric de Quartel on 11/03/2025.
//
// MARK: - AudioPlayerManager
import SwiftUI
import Alamofire
import Kingfisher
import AVFoundation
import SwiftAudioEx

class AudioPlayerManager: ObservableObject {
  let player = AudioPlayer()
  @Published var isPlaying: Bool = false

  init() {
    player.event.stateChange.addListener(self) { [weak self] state in
      DispatchQueue.main.async {
        self?.isPlaying = state == .playing
      }
    }
  }

  func playAudio(from urlString: String?, completion: (() -> Void)? = nil) {
    //        print("playAudio \(String(describing: urlString))")
    guard let urlString = urlString, let url = URL(string: urlString) else {
      print("Invalid URL")
      completion?()
      return
    }

    let audioItem = DefaultAudioItem(audioUrl: url.absoluteString, sourceType: .stream)
    player.load(item: audioItem, playWhenReady: true)

    // Call completion when the audio starts playing
    player.event.stateChange.addListener(self) { [weak self] state in
      DispatchQueue.main.async {
        if state == .playing {
          self?.isPlaying = true
          completion?()
        }
      }
    }
  }

  func stopAudio() {
    player.stop()
  }
}


