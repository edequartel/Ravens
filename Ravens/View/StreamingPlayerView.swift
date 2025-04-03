//
//  StreamingPlayerView.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/03/2024.
//

import SwiftUI
import SwiftAudioEx

struct StreamingQueuPlayerView: View {
    var audio: [String]

    let qPlayer = QueuedAudioPlayer()
    
    @State private var isPlaying = false

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    for audioUrl in audio {
                        let audioItem = DefaultAudioItem(audioUrl: audioUrl, sourceType: .stream)
                        qPlayer.add(item: audioItem, playWhenReady: true)
                    }
                }) {
                    Image(systemName: "play.circle")
                        .font(.system(size: 30))
                }
                
                Button(action: {
                    qPlayer.pause()
                }) {
                    Image(systemName: "pause.circle")
                        .font(.system(size: 30))
                }
                Button(action: {
                    qPlayer.previous()
                }) {
                    Image(systemName: "backward.end.circle")
                        .font(.system(size: 30))
                }
                
                Button(action: {
                    qPlayer.next()
                }) {
                    Image(systemName: "forward.end.circle")
                        .font(.system(size: 30))
                }
                Button(action: {
                    qPlayer.stop()
                }) {
                    Image(systemName: "stop.circle")
                        .font(.system(size: 30))
                }
            }
            .padding(5)
            .border(Color.blue, width: 2) // Set the border color and width
        }
        .onAppear {
            qPlayer.nowPlayingInfoController.set(keyValue: NowPlayingInfoProperty.isLiveStream(true))
        }
    }
}

#Preview {
    StreamingQueuPlayerView(audio: ["https://waarneming.nl/media/sound/235293.mp3",
                                    "https://waarneming.nl/media/sound/235293.mp3"])
}

struct StreamingPlayerView: View {
    var audio: String

    let player = AudioPlayer()
    
    var body: some View {
        HStack {
            Button(action: {
                let audioItem = DefaultAudioItem(audioUrl: audio, sourceType: .stream)
                player.load(item: audioItem, playWhenReady: true) // Load the item and start playing when the player is ready.
            }) {
                Image(systemName: "play.circle")
                    .font(.system(size: 30))
            }
            Button(action: {
                player.stop()
            }) {
                Image(systemName: "stop.circle")
                    .font(.system(size: 30))
            }
        }
    }
}

#Preview {
    StreamingPlayerView(audio: "https://waarneming.nl/media/sound/235293.mp3")
}
