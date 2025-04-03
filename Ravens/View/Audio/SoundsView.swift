//  Accessible
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

struct PlayerControlsView: View {
  @EnvironmentObject var player: Player

  @Environment(\.presentationMode) var presentationMode

  @State private var sliderValue: Double = 0
  @State private var nrPlaying = 0

  var sounds: [String]
  //    var audio1 = ["https://waarneming.nl/media/sound/235292.mp3",
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
            .accessibilityHidden(true)

          HStack {
            Text(String(format: "%.2f", player.currentTime))
            Spacer()
            Text(String(format: "%.2f", player.duration))
          }
          .font(.caption)
          .foregroundColor(.gray)
          .accessibilityLabel("\(player.currentTime) of \(player.duration)")
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
            .accessibilityLabel(next)
          }

          if player.status != .playing {
            Button(action: {
              player.play()
            }) {
              Image(systemName: "play.circle.fill")
                .font(.system(size: 50))
                .frame(width: 50)
            }
            .accessibilityLabel(play)

          } else {
            Button(action: {
              player.pause()
            }) {
              Image(systemName: "pause.circle.fill")
                .font(.system(size: 50))
                .frame(width: 50)
            }
            .accessibilityLabel(pause)
          }

          if sounds.count > 1 {
            Button(action: {
              player.next()
              player.play()
            }) {
              Image(systemName: "forward.end.circle.fill")
                .font(.system(size: 30))
                .frame(width: 50)
            }
            .accessibilityLabel(next)
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
