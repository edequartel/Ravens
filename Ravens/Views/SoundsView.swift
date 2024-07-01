////
////  ContentView.swift
////  TestSoundableStream
////
////  Created by Eric de Quartel on 20/03/2024.
////
//

import SwiftUI
import SwiftAudioEx
import SwiftyBeaver

// Define your Player class
class Player: ObservableObject {
    let log = SwiftyBeaver.self
    let queuedAudioPlayer: QueuedAudioPlayer
    
    @Published var status: AudioPlayerState = .idle
    
    init() {
        queuedAudioPlayer = QueuedAudioPlayer()
        queuedAudioPlayer.event.stateChange.addListener(self, handleAudioPlayerStateChange)
    }
    
    func handleAudioPlayerStateChange(state: AudioPlayerState) {
        DispatchQueue.main.async {
            self.status = state
            self.log.error("State: \(state)")
            if let artist = self.queuedAudioPlayer.currentItem?.getArtist() {
                self.log.error("Artist: \(artist)")
            }
        }
    }
    
    func play(_ audioUrls: [String]) {
        for audioUrl in audioUrls {
            let audioItem = DefaultAudioItem(
                audioUrl: audioUrl,
                sourceType: .stream
            )
            queuedAudioPlayer.add(item: audioItem, playWhenReady: true)
        }
    }
    
    func pause() {
        queuedAudioPlayer.pause()
    }
    
    func stop() {
        queuedAudioPlayer.stop()
    }
    
    func previous() {
        queuedAudioPlayer.previous()
    }
    
    func next() {
        queuedAudioPlayer.next()
    }
}

// Define your PlayerControlsView
struct PlayerControlsView: View {
    @EnvironmentObject var player: Player
    @Environment(\.presentationMode) var presentationMode
    
    var audio: [String]
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                closeButton
            }
            HStack {
                Spacer()
                if player.status != .playing {
                    playButton
                } else {
                    stopButton
                }
                pauseButton
                if audio.count > 1 {
                    previousButton
                    nextButton
                }
                Spacer()
            }
        }
        .padding()
    }

    private var playButton: some View {
        Button(action: {
            player.play(audio)
        }) {
            Image(systemName: "play.fill")
                .iconStyle
        }
    }

    private var stopButton: some View {
        Button(action: {
            player.stop()
        }) {
            Image(systemName: "stop.fill")
                .iconStyle
        }
    }

    private var pauseButton: some View {
        Button(action: {
            player.pause()
        }) {
            Image(systemName: "pause.fill")
                .iconStyle
        }
    }

    private var previousButton: some View {
        Button(action: {
            player.previous()
        }) {
            Image(systemName: "backward.fill")
                .iconStyle
        }
    }

    private var nextButton: some View {
        Button(action: {
            player.next()
        }) {
            Image(systemName: "forward.fill")
                .iconStyle
        }
    }

    private var closeButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "xmark")
                .iconStyle
        }
//        .buttonStyle(.plain)
//        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension Image {
    var iconStyle: some View {
        self.font(.system(size: 20)).frame(width: 50)
    }
}

// Uncomment and use your ContentView
//struct ContentView: View {
//    @EnvironmentObject var player: Player
//
//    var body: some View {
//        VStack {
//            PlayerControlsView(audio: ["https://waarneming.nl/media/sound/235291.mp3"])
//            PlayerControlsView(audio: ["https://waarneming.nl/media/sound/235783.wav"])
//        }
//    }
//}

// Previews
struct PlayerControlsView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerControlsView(audio: [])
            .environmentObject(Player())
    }
}

//import SwiftUI
//import SwiftAudioEx
//import SwiftyBeaver
//
//class Player: ObservableObject {
//    let log = SwiftyBeaver.self
//    let queuedAudioPlayer: QueuedAudioPlayer
//    
//    @Published var status: AudioPlayerState = .idle
//    
//    init() {
//        queuedAudioPlayer = QueuedAudioPlayer()
//        queuedAudioPlayer.event.stateChange.addListener(self, handleAudioPlayerStateChange)
//    }
//    
//    func handleAudioPlayerStateChange(state: AudioPlayerState) {
//        // Handle the event
//        log.error(">>> \(state)")
//        log.error(">>> \(queuedAudioPlayer.currentItem?.getArtist() ?? "0")")
//        DispatchQueue.main.async {
//            self.status = state
//        }
//    }
//    
//    func play(_ audioUrls: [String]) {
////        queuedAudioPlayer.stop()
////        queuedAudioPlayer.clear()
//        for audioUrl in audioUrls {
//            let audioItem = DefaultAudioItem(
//                audioUrl: audioUrl,
//                sourceType: .stream
//            )
//            queuedAudioPlayer.add(item: audioItem, playWhenReady: true)
//            log.info("playing \(audioUrl)")
//        }
//    }
//    
//    func pause() {
//        queuedAudioPlayer.pause()
//        log.info("paused")
//    }
//    
//    func stop() {
//        queuedAudioPlayer.stop()
//        log.info("stopped")
//    }
//    
//    func previous() {
//        queuedAudioPlayer.previous()
//        log.info("previous")
//    }
//    
//    func next() {
//        queuedAudioPlayer.next()
//        log.info("next")
//    }
//}
//
//struct PlayerControlsView: View {
//    @EnvironmentObject var player: Player
//    @Environment(\.presentationMode) var presentationMode
//    
//    var audio: [String]
//    
//    var body: some View {
//        HStack {
//            VStack {
//                HStack{
//                    Spacer()
//                    
//                    if player.status != .playing {
//                        Button(action: {
//                            player.play(audio)
//                        }) {
//                            Image(systemName: "play.fill")
//                                .font(.system(size: 30))
//                                .frame(width: 50)
//                        }
//                    } else {
//                        Button(action: {
//                            player.stop()
//                        }) {
//                            Image(systemName: "stop.fill")
//                                .font(.system(size: 30))
//                                .frame(width: 50)
//                        }
//                        
//                        
//                    }
//                    Button(action: {
//                        player.pause()
//                    }) {
//                        Image(systemName: "pause.fill")
//                            .font(.system(size: 30))
//                            .frame(width: 50)
//                    }
//                    
//                    if (audio.count > 1) {
//                        Button(action: {
//                            player.previous()
//                        }) {
//                            Image(systemName: "backward.fill")
//                                .font(.system(size: 30))
//                                .frame(width: 50)
//                        }
//                        
//                        Button(action: {
//                            player.next()
//                        }) {
//                            Image(systemName: "forward.fill")
//                                .font(.system(size: 30))
//                                .frame(width: 50)
//                        }
//                        
//                    }
//                    Spacer()
//                }
//                .overlay(alignment: .topTrailing) {
//                    closeButton
//                }
//            }
//            .padding(5)
//        }
//    }
//
//    
//    private var closeButton: some View {
//         Button {
//            presentationMode.wrappedValue.dismiss()
//         } label: {
//             Image(systemName: "xmark")
//                 .font(.headline)
//         }
//         .buttonStyle(.bordered)
//         .clipShape(Circle())
//         .padding()
//     }
//}
//
//struct PlayerControlsView_Previews: PreviewProvider {
//    static var previews: some View {
//        PlayerControlsView(audio: [])
//            .environmentObject(Player())
//    }
//}
//
////struct ContentView: View {
////    @EnvironmentObject var player: Player
////
////    var audio1 = ["https://waarneming.nl/media/sound/235291.mp3",
////                  "https://waarneming.nl/media/sound/235292.mp3",
////                  "https://waarneming.nl/media/sound/235293.mp3"]
////
////    var audio2 = ["https://waarneming.nl/media/sound/235783.wav",
////                  "https://waarneming.nl/media/sound/235293.mp3",
////                  "https://waarneming.nl/media/sound/235770.mp3"]
////
////    var audio3 = ["https://waarneming.nl/media/sound/235783.wav",
////                  "https://waarneming.nl/media/sound/235293.mp3",
////                  "https://waarneming.nl/media/sound/235770.mp3"]
////
////
////    var body: some View {
////        VStack {
////            Text("\(player.statePlayer)")
////            PlayerControlsView(audio: audio1)
////            PlayerControlsView(audio: audio2)
////            PlayerControlsView(audio: audio3)
////        }
////        .padding(5)
////    }
////}
