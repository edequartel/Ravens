//
//  ObsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 04/09/2024.
//

import SwiftUI

struct ObsView: View {
  var obs: Observation

  @EnvironmentObject var bookMarksViewModel: BookMarksViewModel
  @Binding var imageURLStr: String?
  @Binding var selectedObservationSound: Observation?

  var body: some View {
    VStack {
      if showView {
        Text("ObsView").font(.customTiny)
      }

      VStack {
        ObsDetailsRowView(obs: obs, bookMarksViewModel: bookMarksViewModel)

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
      }
      .padding(16)
//      Spacer()
      NotesView(obs: obs)
        .padding(8)
//      PhotoGridView(photos: obs.photos ?? [], imageURLStr: $imageURLStr)
//        .padding(8)
          Spacer()
      HorizontalLine()
      PhotoGridView(photos: obs.photos ?? [], imageURLStr: $imageURLStr)
        .padding(8)
//          HorizontalLine()
      PlayerControlsView(sounds: obs.sounds ?? [])
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
