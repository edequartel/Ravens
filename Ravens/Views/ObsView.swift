//
//  ObsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 04/09/2024.
//

import SwiftUI

struct PlayButtonView: View {
    var body: some View {
        Button(action: {
            // Add your play audio action here
            print("Play button pressed")
        }) {
            Image(systemName: "play.fill") // SF Symbol for play button
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40) // Icon size
                .foregroundColor(.white) // Icon color
                .padding(20) // Padding around the icon
                .background(
                    Circle()
                        .fill(
                            LinearGradient(gradient: Gradient(colors: [.blue, .purple]),
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                        )
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                ) // Circular gradient background with shadow
        }
        .buttonStyle(PlainButtonStyle()) // Remove default button styling
    }
}

struct ObsView: View {
  var obs: Observation

  @EnvironmentObject var bookMarksViewModel: BookMarksViewModel
  @Binding var imageURLStr: String?
  @Binding var selectedObservationSound: Observation?
  @State var selectedObservationSoundXXX: Observation?

  var body: some View {
    VStack {
      if showView {
        Text("ObsView").font(.customTiny)
      }
      
      HStack {
        Image(systemName: "circle.fill")
          .foregroundColor(RarityColor(value: obs.rarity))
        Text("\(obs.species_detail.name)")// \(obs.species_detail.id)")
          .font(.title)
          .bold()
          .lineLimit(1) // Set the maximum number of lines to 1
          .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
        Spacer()
      }
      .padding(8)

      VStack {
//        ObsDetailsRowView(obs: obs, bookMarksViewModel: bookMarksViewModel)
//          .padding(8)
        PhotoGridView(photos: obs.photos ?? [], imageURLStr: $imageURLStr)
          .padding(8)

        if obs.sounds?.count ?? 0 > 0 {
          Button(action: {
            // Add your play audio action here
            selectedObservationSoundXXX = obs
            print("Play button pressed")
          }) {
            Image(systemName: "play.fill") // SF Symbol for play button

          }
          .buttonStyle(PlainButtonStyle()) // Remove default button styling
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(8)
          .background(Color(UIColor.systemGray6))
        }

        VStack {
          HStack {
            Text("\(obs.species_detail.scientific_name)")
              .foregroundColor(.gray)
              .font(.footnote)
              .italic()
              .lineLimit(1) // Set the maximum number of lines to 1
              .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
            Spacer()
          }

          HStack {
            Text("\(obs.date) \(obs.time ?? "")")
            Text("\(obs.number) x")
            Spacer()
          }

          VStack {
            HStack {
              Text("\(obs.user_detail?.name ?? "noName")")
                .footnoteGrayStyle()
              Spacer()
              Image(systemName: SFObserverFill)
                .foregroundColor(.black)
            }
          }

          VStack {
            HStack {
              Text("Location \(obs.location ?? -1) fetchData")
                .footnoteGrayStyle()
//              Text("(obs.")
              Spacer()
            }
          }
        }
        .padding(8)

      }
//      .padding(16)
//      Spacer()
      NotesView(obs: obs)
        .padding(8)
        .background(Color(UIColor.systemGray6))

          Spacer()
      HorizontalLine()

        .padding(8)
//          HorizontalLine()

//      PlayerControlsView(sounds: obs.sounds ?? [])
    }
    .sheet(item: $selectedObservationSoundXXX) { item in
      PlayerControlsView(sounds: item.sounds ?? [])
        .presentationDetents([.fraction(0.25), .medium, .large])
        .presentationDragIndicator(.visible)
    }
  }
}

//      VStack {
//        Text("sex \(obs.sex)")
//        Text("accuracy \(String(describing: obs.accuracy))")
//        Text("escape \(obs.is_escape)")
//        Text("certain \(obs.is_certain)")
//        Text("life stage \(obs.life_stage)")
//        Text("method \(String(describing: obs.method))")
//        Text("substrate \(obs.substrate)")
//        Text("related species \(obs.related_species)")
//        Text("obscurity \(obs.obscurity)")
//      }
//      .font(.customTiny)

//#Preview {
//  ObsView(obs: .constant(nil))
//}
