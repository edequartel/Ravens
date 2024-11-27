//
//  PlayerModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 27/11/2024.
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
