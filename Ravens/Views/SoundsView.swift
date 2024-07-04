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
    private var queuedAudioPlayer: QueuedAudioPlayer //PRIVATE VAR AND NOT LET
    
    @Published var status: AudioPlayerState = .idle
    
    init() {
        queuedAudioPlayer = QueuedAudioPlayer()
        queuedAudioPlayer.event.stateChange.addListener(self, handleAudioPlayerStateChange)
    }
    
    func handleAudioPlayerStateChange(state: AudioPlayerState) {
        // Handle the event
        log.error(">>> \(state)")
//        log.error(">>> \(queuedAudioPlayer.currentItem?.getArtist() ?? "0")")
        DispatchQueue.main.async {
            self.status = state
        }
    }
    
    
    
    func play(_ audioUrls: [String]) {
//        queuedAudioPlayer.stop()
        queuedAudioPlayer.clear()
        for audioUrl in audioUrls {
            let audioItem = DefaultAudioItem(
                audioUrl: audioUrl,
                sourceType: .stream
            )
            log.error("fill \(audioUrl)")
            queuedAudioPlayer.add(item: audioItem, playWhenReady: true)
//            log.error("fill)")
        }
    }
    
//    func play() {
//        //        queuedAudioPlayer.stop()
//                queuedAudioPlayer.clear()
//                for audioUrl in audioUrls {
//                    let audioItem = DefaultAudioItem(
//                        audioUrl: audioUrl,
//                        sourceType: .stream
//                    )
//                    log.error("fill \(audioUrl)")
//                    queuedAudioPlayer.add(item: audioItem, playWhenReady: true)
//        //            log.error("fill)")
//                }
//    }
    
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
    
    var audio: [String]
//    var audio1 = ["https://waarneming.nl/media/sound/235291.mp3",
//                  "https://waarneming.nl/media/sound/235292.mp3",
//                  "https://waarneming.nl/media/sound/235293.mp3"]
    
    var body: some View {
        HStack {
            VStack {
                HStack{
                    Spacer()
                    
                    
//                    Button(action: {
//                        player.fill(audio)
//                    }) {
//                        Image(systemName: "circle")
//                            .font(.system(size: 30))
//                            .frame(width: 50)
//                    }
                    
                    Button(action: {
                        player.play(audio)
                    }) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 30))
                            .frame(width: 50)
                    }
                    //                    .hidden(player.status == .playing || player.status == .buffering || player.status == .loading)
                    
                    Button(action: {
                        player.stop()
                    }) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 30))
                            .frame(width: 50)
                        
                    }
                    //                    .hidden(player.status == .idle)
                    
                    Button(action: {
                        player.pause()
                    }) {
                        Image(systemName: "pause.fill")
                            .font(.system(size: 30))
                            .frame(width: 50)
                    }
                    
                    //                    if (audio.count > 1) {
                    Button(action: {
                        player.previous()
                    }) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 30))
                            .frame(width: 50)
                    }
                    
                    Button(action: {
                        player.next()
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 30))
                            .frame(width: 50)
                    }
                    //
                    //                    }
                    Spacer()
                }
                //                .overlay(alignment: .topTrailing) {
                //                    closeButton
                //                }
            }
            .padding(5)
        }
        .padding(20)
    }
    
    
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
