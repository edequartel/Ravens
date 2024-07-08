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
    private var queuedAudioPlayer: QueuedAudioPlayer //PRIVATE VAR AND NOT LET
    
    @Published var status: AudioPlayerState = .idle
    @Published var title: String = "unknown"
    @Published var artist: String = "unknown"
    
    @Published var currentTime: Double = 0
    @Published var currentIndex: Int = 0
    @Published var duration: Double = 0
    //    @Published var isPlaying: Bool = false
    //    @Published var playBackEnd: String = "unknown"
    
    //    @Published var playbackEventData: PlaybackEndedReason = .playedUntilEnd
    
    init() {
        queuedAudioPlayer = QueuedAudioPlayer()
        queuedAudioPlayer.nowPlayingInfoController.set(keyValue: NowPlayingInfoProperty.isLiveStream(true))
        queuedAudioPlayer.event.stateChange.addListener(self, handleAudioPlayerStateChange)
        queuedAudioPlayer.event.updateDuration.addListener(self, handleDuration)
        queuedAudioPlayer.event.secondElapse.addListener(self, handleSecondElapse)
        queuedAudioPlayer.event.currentItem.addListener(self, handleData)
        
        //        queuedAudioPlayer.event.playbackEnd.addListener(self, handlePlayBackEnd)
        //        queuedAudioPlayer.event.receiveChapterMetadata.addListener(self, handleCommonMetadata)
        //        queuedAudioPlayer.event.receiveTimedMetadata.addListener(self, handleTimedMetadata)
    }
    
    //    deinit() {
    //        queuedAudioPlayer?.event.receiveTimedMetadata.removeListener(self)
    //    }
    //
    private func handleAudioPlayerStateChange(state: AudioPlayerState) {
        log.error("state change, \(state)")
        DispatchQueue.main.async {
            self.status = state
            if state == .ended {
                self.stop()
            }
        }
    }
    
    private func handleDuration(duration: Double) {
        log.error("duration, \(duration)")
        DispatchQueue.main.async {
            self.duration = duration
        }
    }
    
    private func handleSecondElapse(currentTime: Double) {
        DispatchQueue.main.async {
            self.currentTime = currentTime
        }
    }
    
    private func handleData(CurrentItemEventData:
                            ( item: AudioItem?,
                              index: Int?,
                              lastItem: AudioItem?,
                              lastIndex: Int?,
                              lastPosition: Double?
                            )) {
        DispatchQueue.main.async {
            self.currentIndex = CurrentItemEventData.index ?? 0
        }
    }
    
    
    //    private func handlePlayBackEnd(playbackEventData: PlaybackEndedReason) {
    //        DispatchQueue.main.async {
    //            self.playbackEventData = playbackEventData
    //        }
    //    }
    
    //    private func handleTimedMetadata(metadata: [AVTimedMetadataGroup]) {
    //        DispatchQueue.main.async {
    //            self.title = metadata.
    //        }
    //    }
    
    
    //    private func handleCommonMetadata(metadata: [AVMetadataItem]) {
    //        DispatchQueue.main.async {
    //            self.title = metadata[0].
    //        }
    //    }
    
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
        log.error("playing")
    }
    
    func pause() {
        queuedAudioPlayer.pause()
        log.error("paused")
    }
    
    func stop() {
        queuedAudioPlayer.stop()
        log.error("stopped")
    }
    
    func previous() {
        queuedAudioPlayer.previous()
        log.error("previous")
    }
    
    func next() {
        queuedAudioPlayer.next()
        log.error("next")
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
    
    var audio: [String]
//    var audio1 = ["https://waarneming.nl/media/sound/235291.mp3",
//                  "https://waarneming.nl/media/sound/235292.mp3",
//                  "https://waarneming.nl/media/sound/235293.mp3"]
    
    var body: some View {
//        HStack {
            VStack {
                
                VStack {
                    if audio.count > 1 {
                        HStack {
                            Spacer()
                            Text("\(player.currentIndex+1)-\(audio.count)")
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
                

                HStack{
                    Spacer()
                    
                    if (audio.count > 1) {
                        Button(action: {
                            player.previous()
                            player.play()
                        }) {
                            Image(systemName: "backward.end.circle.fill")
                                .font(.system(size: 30))
                                .frame(width: 50)
                        }
                    }
                    
                    
                    if ((player.status != .playing))// && (player.status != .loading) && (player.status != .buffering))
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
                    
//                    Button(action: {
//                        player.stop()
//                    }) {
//                        Image(systemName: "stop.circle.fill")
//                            .font(.system(size: 30))
//                            .frame(width: 50)
//                    }
                    
                    if (audio.count > 1) {
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
//        }
//        .overlay(alignment: .topTrailing) {
//            closeButton
//        }
//        .padding(20)
        .onAppear {
            player.fill(audio)
        }
        .onDisappear {
            player.stop()
        }
//        .overlay(alignment: .topTrailing) {
//            closeButton
//        }
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
        PlayerControlsView(audio: [])
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
