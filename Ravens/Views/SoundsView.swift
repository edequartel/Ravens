//
//  ContentView.swift
//  TestSoundableStream
//
//  Created by Eric de Quartel on 20/03/2024.
//

import SwiftUI
import SwiftAudioEx
import SwiftyBeaver

class Player: ObservableObject {
    let log = SwiftyBeaver.self
    let queuedAudioPlayer: QueuedAudioPlayer
    
    @Published var status: AudioPlayerState = .idle
    
    init() {
        queuedAudioPlayer = QueuedAudioPlayer()
        queuedAudioPlayer.event.stateChange.addListener(self, handleAudioPlayerStateChange)
    }
    
    func handleAudioPlayerStateChange(state: AudioPlayerState) {
        // Handle the event
        log.info("\(state)")
        DispatchQueue.main.async {
            self.status = state
        }
    }
    
    func play(_ audioUrls: [String]) {
//        queuedAudioPlayer.stop()
        queuedAudioPlayer.clear()
        for audioUrl in audioUrls {
            let audioItem = DefaultAudioItem(audioUrl: audioUrl, sourceType: .stream)
            queuedAudioPlayer.add(item: audioItem, playWhenReady: true)
            log.info("playing \(audioUrl)")
        }
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

struct PlayerControlsView: View {
    @EnvironmentObject var player: Player
    var audio: [String]
    
    var body: some View {
        HStack {
            if player.status != .playing {
                Button(action: {
                    player.play(audio)
                }) {
                    Image(systemName: "play.circle")
                        .font(.system(size: 30))
                }
            } else {
                HStack {
                    Button(action: {
                        player.stop()
                    }) {
                        Image(systemName: "stop.circle")
                            .font(.system(size: 30))
                    }
//                    Button(action: {
//                        player.pause()
//                    }) {
//                        Image(systemName: "pause.fill")
//                            .font(.system(size: 30))
//                    }
                    
                }
            }
            //
            //
            //            Button(action: {
            //                player.stop()
            //            }) {
            //                Image(systemName: "stop.circle")
            //                    .font(.system(size: 30))
            //            }
            
            
        }
        .padding(5)
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
