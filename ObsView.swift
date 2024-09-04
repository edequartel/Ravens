//
//  ObsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 04/09/2024.
//

import SwiftUI

struct ObsView: View {
    var obs: Observation
  
    var body: some View {
      Text("ObsView")
      Text("\(obs.species_detail.name)")
      VStack {
        HStack {
          Image(systemName: "circle.fill")
            .foregroundColor(RarityColor(value: obs.rarity))

//            if obs.photos?.count ?? 0 > 0 {
//              Image(systemName: "photo")
//            }

          if obs.sounds?.count ?? 0 > 0 {
            Image(systemName: "waveform")
          }

          Text("\(obs.species_detail.name)")// \(obs.species_detail.id)")
            .bold()
            .lineLimit(1) // Set the maximum number of lines to 1
            .truncationMode(.tail) // Use ellipsis in the tail if the text is truncated
          Spacer()
//          if bookMarksViewModel.isSpeciesIDInRecords(speciesID: obs.species_detail.id) {
            Image(systemName: SFSpeciesFill)
//          }
        }

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

//        if settings.showUser {
          VStack {
            HStack {
              Text("\(obs.user_detail?.name ?? "noName")")
                .footnoteGrayStyle()
              Spacer()
//              if observersViewModel.isObserverInRecords(userID: obs.user_detail?.id ?? 0) {
                Image(systemName: SFObserverFill)
                  .foregroundColor(.black)
              }
//            }
//          }
        }
        Spacer()

          if obs.notes?.count ?? 0 > 0 {
            HStack {
              Text("\(obs.notes ?? "unknown")")
                .italic()
              Spacer()
            }
          }


      }
      .padding(8)
    }

}

//#Preview {
//  ObsView(obs: .constant(nil))
//}
